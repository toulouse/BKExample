// Copyright 2014-present 650 Industries. All rights reserved.

#import "BKCameraRollViewController.h"

@import AssetsLibrary;
@import QuartzCore;

#import <pop/POP.h>
#import <BKCameraController/BKCameraController.h>
#import <BKHitSlop/BKHitSlop.h>
#import <BKRecursiveDescription/BKRecursiveDescription.h>

// Copied header. TODO: unhack once pop exposes observation
#import "POPAnimatorPrivate.h"

#import "BKCameraControlView.h"
#import "BKCameraControlViewCoordinator.h"
#import "BKCameraRollAssetsController.h"
#import "BKCameraRollFloorController.h"
#import "BKCameraRollFloorView.h"
#import "BKCameraRollViewSpec.h"
#import "BKDrawerHandleArrow.h"
#import "BKIcons.h"
#import "UIButton+Bouncy.h"

const struct BKCameraRollSpecs BKCameraRollSpecs = {
    .buttonHitSlop = {-10, -10, -10, -10},
    .buttonSize = {40, 40},
    .leftButtonAreaInsets = {0, 20, 10, 0},
    .rightButtonAreaInsets = {0, 0, 10, 20},

    .closedDrawerHeight = 204.0,
    .drawerHandleHeight = 44.0,  // Same height as a navigation bar
    .topFloorInset = 26.0,
    .bottomFloorInset = 14.0,
    .floorUndersizeMargin = 0.0,

    .drawerViewCornerRadius = 4.0,
    .drawerHandleShadowOffset = {0.0, 0.0},
    .drawerHandleShadowOpacity = 0.4,
    .drawerHandleShadowRadius = 0.5,

    .cellsPerRow = 4,
    .rowScrollBias = 3.0/5.0,
    .drawerSpringBounciness = 6.0,
    .drawerSpringSpeedNormal = 12.0,
    .drawerSpringSpeedFast = 20.0,
};

static NSString * const kBKCameraRollDrawerOffsetProperty = @"drawerOffset";
static NSString * const kBKCameraRollFloorContentInsetProperty = @"floorContentInset";

@interface BKCameraRollViewController () <BKCameraControlContainer, BKCameraControlViewDelegate, BKCameraRollAssetsControllerDelegate, POPAnimatorObserving>
@end

@implementation BKCameraRollViewController {
    BKCameraController *_cameraController;
    BKCameraRollAssetsController *_assetsController;
    BKCameraRollFloorController *_floorController;
    BKCameraControlViewCoordinator *_controlViewCoordinator;

    BKCameraRollViewSpec *_viewSpec;
    BOOL _needsRefresh;

    BOOL _prefersStatusBarHidden;

    // Views
    BKCameraControlView *_controlView;
    UIView *_drawerView;
    UIView *_drawerHandleView;
    BKDrawerHandleArrow *_drawerHandleArrow;
    UIButton *_acceptButton;

    // Drawer tracking
    BOOL _trackingPan;
    CGFloat _initialDrawerOffset;

    // Springs / Animation
    POPSpringAnimation *_drawerSpring;
    POPSpringAnimation *_floorSpring;

    POPAnimatableProperty *_drawerOffsetProperty;
    POPAnimatableProperty *_floorContentInsetProperty;

    // Collection
    NSIndexPath *_selectedItem;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _cameraController = [[BKCameraController alloc] initWithInitialPosition:AVCaptureDevicePositionBack autoFlashEnabled:YES];

        _assetsController = [[BKCameraRollAssetsController alloc] init];
        _assetsController.delegate = self;

        _floorController = [[BKCameraRollFloorController alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    _viewSpec = [[BKCameraRollViewSpec alloc] init];

    _controlView = [[BKCameraControlView alloc] initWithCameraController:_cameraController];
    _controlView.delegate = self;

    _controlViewCoordinator = [[BKCameraControlViewCoordinator alloc] initWithControlView:_controlView
                                                                               anchorView:self.view];

    // Floor view
    [_floorController didLoad];
    [self.view addSubview:_floorController.view];

    // Drawer view
    _drawerView = [[UIView alloc] init];
    _drawerView.layer.cornerRadius = BKCameraRollSpecs.drawerViewCornerRadius;
    [self.view addSubview:_drawerView];

    // Drawer handle view
    _drawerHandleView = [[UIView alloc] init];
    _drawerHandleView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.98];
    _drawerHandleView.layer.shadowOffset = BKCameraRollSpecs.drawerHandleShadowOffset;
    _drawerHandleView.layer.shadowOpacity = BKCameraRollSpecs.drawerHandleShadowOpacity;
    _drawerHandleView.layer.shadowRadius = BKCameraRollSpecs.drawerHandleShadowRadius;
    [_drawerView addSubview:_drawerHandleView];

    // Arrow inside the drawer handle
    _drawerHandleArrow = [[BKDrawerHandleArrow alloc] init];
    _drawerHandleArrow.direction = [self _directionForDrawerPosition:_viewSpec.drawerPosition];
    [_drawerHandleView.layer addSublayer:_drawerHandleArrow.layer];

    // Assets collection view
    [_assetsController didLoad];
    [_drawerView insertSubview:_assetsController.view belowSubview:_drawerHandleView];

    // Video preview
    _assetsController.controlView = _controlView;

    // Accept button
    UIImage *acceptImage = [BKIcons circleWithSize:BKCameraRollSpecs.buttonSize
                                      fillColor:[UIColor grayColor]
                                      strokeColor:[UIColor blackColor]
                                        lineWidth:4];
    _acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _acceptButton.adjustsImageWhenHighlighted = NO;
    _acceptButton.bouncy = YES;
    _acceptButton.bk_hitSlop = BKCameraRollSpecs.buttonHitSlop;
    _acceptButton.layer.masksToBounds = NO;
    [_acceptButton setImage:acceptImage forState:UIControlStateNormal];
    [_acceptButton addTarget:self action:@selector(_buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_acceptButton];

    // Drawer stuff
    [_assetsController.view.panGestureRecognizer addTarget:self action:@selector(_assetsPanned:)];

     UIPanGestureRecognizer *drawerHandlePanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_drawerHandlePanned:)];
    [drawerHandlePanRecognizer requireGestureRecognizerToFail:_assetsController.view.panGestureRecognizer];
    [_drawerHandleView addGestureRecognizer:drawerHandlePanRecognizer];

    UITapGestureRecognizer *drawerHandleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_drawerHandleTapped:)];
    [_drawerHandleView addGestureRecognizer:drawerHandleTapRecognizer];

    // Spring setup
    [self _setupSprings];

    // Force collection view sizing so we can calculate the cell sizing
    _viewSpec.floorContentInset = [_viewSpec floorContentInsetForDrawerPosition:BKCameraRollDrawerPositionOpened];
    _viewSpec.drawerOffset = [_viewSpec drawerOffsetForDrawerPosition:BKCameraRollDrawerPositionOpened];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];

    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_assetsController.view.collectionViewLayout;
    CGFloat totalInteritemSpacing = layout.minimumInteritemSpacing * (BKCameraRollSpecs.cellsPerRow - 1);
    CGFloat cellWidth = (CGRectGetWidth(_assetsController.view.bounds) - totalInteritemSpacing) / BKCameraRollSpecs.cellsPerRow;
    layout.itemSize = CGSizeMake(cellWidth, cellWidth);
}

- (void)viewWillAppear:(BOOL)animated
{
    [[POPAnimator sharedAnimator] addObserver:self];
    [_cameraController startCaptureSession];
    [_assetsController loadAssetsWithCompletion:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[POPAnimator sharedAnimator] removeObserver:self];
    [_cameraController stopCaptureSession];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)prefersStatusBarHidden
{
    return _prefersStatusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}

#pragma mark - Layout stuff

- (void)viewWillLayoutSubviews
{
    _viewSpec.bounds = self.view.bounds;
    [self _setNeedsRefresh];
    [self _refreshIfNeeded];
}

- (void)_setNeedsRefresh
{
    _needsRefresh = YES;
}

- (void)_refreshIfNeeded
{
    if (_needsRefresh) {
        [_viewSpec layout];

        _drawerView.frame = _viewSpec.drawerFrame;
        _floorController.view.frame = _viewSpec.bounds;

        _acceptButton.alpha = _viewSpec.acceptSpec.alpha;
        _acceptButton.bounds = _viewSpec.acceptSpec.bounds;
        _acceptButton.center = _viewSpec.acceptSpec.center;

        if (_viewSpec.drawerPosition == BKCameraRollDrawerPositionHidden) {
            _controlViewCoordinator.progress = _viewSpec.percentHiddenState;
            _floorController.view.alpha = 1 - _viewSpec.percentHiddenState;
        } else {
            _controlViewCoordinator.progress = 1.0 - _viewSpec.percentHiddenState;
            _floorController.view.alpha = 1;
        }

        if (_viewSpec.drawerPosition != BKCameraRollDrawerPositionHidden) {
            _controlView.percentCameraState = 0.0;
        } else {
            _controlView.percentCameraState = _viewSpec.percentHiddenState;
        }

        CGRect drawerHandleRect, assetsRect;
        CGRectDivide(_drawerView.bounds, &drawerHandleRect, &assetsRect, BKCameraRollSpecs.drawerHandleHeight, CGRectMinYEdge);
        _drawerHandleView.frame = drawerHandleRect;
        _drawerHandleArrow.layer.position = _drawerHandleView.center;

        _assetsController.view.frame = _drawerView.bounds;
        _assetsController.view.contentInset = _viewSpec.drawerInsets;
        _assetsController.view.scrollIndicatorInsets = _viewSpec.drawerInsets;

        _needsRefresh = NO;
    }
}

- (void)_buttonPressed:(id)sender
{
    if (sender == _acceptButton && _selectedItem) {
        ALAsset *asset = _assetsController.assets[_selectedItem.item - 1];
        [self _didAcceptAsset:asset];
    }
}

- (void)_leavePhotoExperience
{
    [_controlViewCoordinator beginInteractiveTransitionFromContainer:self toContainer:_assetsController];
    [self _updateDrawerPosition:_viewSpec.previousDrawerPosition animated:YES];

    if (_selectedItem) {
        ALAsset *asset = _assetsController.assets[_selectedItem.item - 1];
        _floorController.asset = asset;

        [_assetsController.view selectItemAtIndexPath:_selectedItem animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
}

- (void)_didAcceptAsset:(ALAsset *)asset
{
    NSLog(@"ALAsset: %@", [asset description]);

    // Example usage of recursive description
    NSLog(@"Recursive description of view spec: %@", [_viewSpec bk_recursiveDescription]);
    NSLog(@"Recursive description of control view: %@", [_controlView bk_recursiveDescription]);
}

#pragma mark - Spring stuff

- (void)_setupSprings
{
    // Properties
    _drawerOffsetProperty = [POPAnimatableProperty propertyWithName:kBKCameraRollDrawerOffsetProperty initializer:^(POPMutableAnimatableProperty *prop) {
        // read value, feed data to Pop
        prop.readBlock = ^(id obj, CGFloat values[]) {
            values[0] = [obj drawerOffset];
        };
        // write value, get data from Pop, and apply it to the view
        prop.writeBlock = ^(id obj, const CGFloat values[]) {
            ((BKCameraRollViewSpec *)obj).drawerOffset = values[0];
            [self _setNeedsRefresh];
        };
        // dynamics threshold
        prop.threshold = 0.5;
    }];

    _floorContentInsetProperty = [POPAnimatableProperty propertyWithName:kBKCameraRollFloorContentInsetProperty initializer:^(POPMutableAnimatableProperty *prop) {
        // read value, feed data to Pop
        prop.readBlock = ^(id obj, CGFloat values[]) {
            BKCameraRollViewSpec *viewSpec = (BKCameraRollViewSpec *)obj;
            values[0] = viewSpec.floorContentInset.top;
            values[1] = viewSpec.floorContentInset.left;
            values[2] = viewSpec.floorContentInset.bottom;
            values[3] = viewSpec.floorContentInset.right;
        };
        // write value, get data from Pop, and apply it to the view
        prop.writeBlock = ^(id obj, const CGFloat values[]) {
            BKCameraRollViewSpec *viewSpec = (BKCameraRollViewSpec *)obj;
            viewSpec.floorContentInset = UIEdgeInsetsMake(values[0], values[1], values[2], values[3]);
            [self _setNeedsRefresh];
        };
        // dynamics threshold
        prop.threshold = 0.5;
    }];

    // Drawer spring
    _drawerSpring = [POPSpringAnimation animation];
    _drawerSpring.property = _drawerOffsetProperty;
    _drawerSpring.springBounciness = BKCameraRollSpecs.drawerSpringBounciness;
    _drawerSpring.springSpeed = BKCameraRollSpecs.drawerSpringSpeedNormal;

    __typeof__(self) __weak weakSelf = self;
    _drawerSpring.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        __typeof__(self) strongSelf = weakSelf;
        strongSelf->_drawerSpring.springBounciness = BKCameraRollSpecs.drawerSpringBounciness;
        strongSelf->_drawerSpring.springSpeed = BKCameraRollSpecs.drawerSpringSpeedNormal;
        if (!strongSelf->_controlViewCoordinator.finished) {
            [strongSelf->_controlViewCoordinator finishInteractiveTransition];
        }
    };

    // Floor spring
    _floorSpring = [POPSpringAnimation animation];
    _floorSpring.property = _floorContentInsetProperty;
    _floorSpring.springBounciness = BKCameraRollSpecs.drawerSpringBounciness;
    _floorSpring.springSpeed = BKCameraRollSpecs.drawerSpringSpeedNormal;
}

#pragma mark - Pan gesture methods

- (void)_assetsPanned:(UIPanGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged) {
        if (!_trackingPan && [self _shouldStartTrackingPan:sender]) {
            _trackingPan = YES;
            _initialDrawerOffset = _viewSpec.drawerOffset;
            // Setting the translation point of the recognizer affects the content offset of the assets view so instead
            // we do our own bookkeeping by subtracting the initial translation point
            _initialDrawerOffset -= [sender translationInView:_drawerView.superview].y;

            [_viewSpec pop_removeAnimationForKey:kBKCameraRollDrawerOffsetProperty];
            [_viewSpec pop_removeAnimationForKey:kBKCameraRollFloorContentInsetProperty];

            [_drawerHandleArrow setDirection:BKDrawerHandleArrowDirectionNeutral animated:YES];
        }

        if (_trackingPan) {
            CGFloat drawerOffset = _initialDrawerOffset + [sender translationInView:_drawerView.superview].y;
            CGFloat closedDrawerOffset = [_viewSpec drawerOffsetForDrawerPosition:BKCameraRollDrawerPositionClosed];
            if (drawerOffset > closedDrawerOffset) {
                drawerOffset = closedDrawerOffset;
                _trackingPan = NO;
                [_drawerHandleArrow setDirection:BKDrawerHandleArrowDirectionUp animated:YES];
            }

            CGFloat drawerMovement = drawerOffset - _viewSpec.drawerOffset;
            if (drawerMovement != 0) {
                _viewSpec.drawerOffset += drawerMovement;
                [self _setNeedsRefresh];

                // Cancel out the drawer movement because the pan gesture is already scrolling the assets
                CGPoint scrollOffset = _assetsController.view.contentOffset;
                scrollOffset.y += drawerMovement;
                _assetsController.view.contentOffset = scrollOffset;
            }
        }
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        if (_trackingPan) {
            _trackingPan = NO;
            [self _animateDrawerToDestination:sender];
        }
    }

    [self _refreshIfNeeded];
}

- (BOOL)_shouldStartTrackingPan:(UIPanGestureRecognizer *)recognizer
{
    // Pushing the handle up
    if ([recognizer locationInView:_drawerHandleView].y < BKCameraRollSpecs.drawerHandleHeight) {
        return YES;
    }

    // Pulling the handle down
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint velocity = [recognizer velocityInView:_assetsController.view];
        CGFloat overscroll = _assetsController.view.contentOffset.y + _assetsController.view.contentInset.top;
        CGFloat closedDrawerOffset = [_viewSpec drawerOffsetForDrawerPosition:BKCameraRollDrawerPositionClosed];
        return velocity.y > 0 && overscroll <= 0 && _viewSpec.drawerOffset < closedDrawerOffset;
    }
    return NO;
}

- (void)_drawerHandlePanned:(UIPanGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        _initialDrawerOffset = _viewSpec.drawerOffset;
        [sender setTranslation:CGPointZero inView:_drawerView.superview];

        [_viewSpec pop_removeAnimationForKey:kBKCameraRollDrawerOffsetProperty];
        [_viewSpec pop_removeAnimationForKey:kBKCameraRollFloorContentInsetProperty];

        [_drawerHandleArrow setDirection:BKDrawerHandleArrowDirectionNeutral animated:YES];
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        CGFloat drawerOffset = _initialDrawerOffset + [sender translationInView:_drawerView.superview].y;
        if (drawerOffset != _viewSpec.drawerOffset) {
            _viewSpec.drawerOffset = drawerOffset;
            [self _setNeedsRefresh];
        }
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [self _animateDrawerToDestination:sender];
    }

    [self _refreshIfNeeded];
}

- (void)_animateDrawerToDestination:(UIPanGestureRecognizer *)recognizer
{
    CGPoint velocity = [recognizer velocityInView:_drawerView.superview];
    CGFloat yVelocity = velocity.y;

    BKCameraRollDrawerPosition position;
    if (yVelocity < 0) {
        CGFloat closedDrawerOffset = [_viewSpec drawerOffsetForDrawerPosition:BKCameraRollDrawerPositionClosed];
        position = (_viewSpec.drawerOffset <= closedDrawerOffset) ? BKCameraRollDrawerPositionOpened : BKCameraRollDrawerPositionClosed;
    } else {
        CGFloat openedDrawerOffset = [_viewSpec drawerOffsetForDrawerPosition:BKCameraRollDrawerPositionOpened];
        position = (_viewSpec.drawerOffset >= openedDrawerOffset) ? BKCameraRollDrawerPositionClosed : BKCameraRollDrawerPositionOpened;
    }

    [self _updateDrawerPosition:position animated:YES];
    _drawerSpring.velocity = @(yVelocity);
}

#pragma mark - Tap gesture methods

- (void)_drawerHandleTapped:(UITapGestureRecognizer *)sender
{
    if (_viewSpec.drawerPosition == BKCameraRollDrawerPositionOpened) {
        [self _updateDrawerPosition:BKCameraRollDrawerPositionClosed animated:YES];
    } else if (_viewSpec.drawerPosition == BKCameraRollDrawerPositionClosed) {
        [self _updateDrawerPosition:BKCameraRollDrawerPositionOpened animated:YES];
    }
}

#pragma mark - POPAnimatorObserving methods

- (void)animatorDidAnimate:(POPAnimator *)animator
{
    [self _refreshIfNeeded];
}

#pragma mark - BKCameraRollAssetsControllerDelegate methods

- (void)assetsControllerDidSelectCamera:(BKCameraRollAssetsController *)controller
{
    [_controlViewCoordinator beginInteractiveTransitionFromContainer:_assetsController toContainer:self];
    [self _scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] withBias:0];
    [self _updateDrawerPosition:BKCameraRollDrawerPositionHidden animated:YES];

    [_assetsController.view deselectItemAtIndexPath:_selectedItem animated:NO];
}

- (void)assetsController:(BKCameraRollAssetsController *)controller didSelectAsset:(ALAsset *)asset atIndexPath:(NSIndexPath *)indexPath
{
    [self _scrollToItemAtIndexPath:indexPath withBias:BKCameraRollSpecs.rowScrollBias];
    [self _updateDrawerPosition:BKCameraRollDrawerPositionClosed animated:YES];

    _selectedItem = [indexPath copy];
    _floorController.asset = asset;
}

#pragma mark - BKCameraControlContainer methods

- (UIView *)cameraControlContainerView
{
    return self.view;
}

- (void)setControlView:(BKCameraControlView *)controlView
{
    controlView.frame = self.view.bounds;
    [self.view addSubview:controlView];
}


#pragma mark - BKCameraControlViewDelegate methods

- (void)cameraControlView:(BKCameraControlView *)controlView didCaptureAssetWithURL:(NSURL *)assetURL
{
    [_assetsController assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        _selectedItem = [NSIndexPath indexPathForItem:1 inSection:0];
        _floorController.asset = asset;
        [self _scrollToItemAtIndexPath:_selectedItem withBias:0];
        [_assetsController.view selectItemAtIndexPath:_selectedItem animated:NO scrollPosition:UICollectionViewScrollPositionNone];

        [self _didAcceptAsset:asset];
    } failureBlock:^(NSError *error) {

    }];
}

- (void)cameraControlViewDidCancel:(BKCameraControlView *)controlView
{
    [self _leavePhotoExperience];
}

#pragma mark - Drawer and collection stuff

- (void)_scrollToItemAtIndexPath:(NSIndexPath *)indexPath withBias:(CGFloat)bias
{
    UICollectionViewLayoutAttributes *layoutAttributes = [_assetsController.view layoutAttributesForItemAtIndexPath:indexPath];
    POPSpringAnimation *scrollToItemAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPScrollViewContentOffset];
    CGFloat topInset = _assetsController.view.contentInset.top;
    NSUInteger itemCount = [_assetsController.view numberOfItemsInSection:0];
    NSUInteger row = indexPath.item / BKCameraRollSpecs.cellsPerRow;
    NSUInteger rowCount = (BKCameraRollSpecs.cellsPerRow + itemCount - 1) / BKCameraRollSpecs.cellsPerRow; // 4 items = 1, 5 items = 2, etc.
    if (indexPath.item < BKCameraRollSpecs.cellsPerRow) { // First row
        scrollToItemAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(0, layoutAttributes.frame.origin.y - topInset)];
    } else if (row == rowCount - 1) { // Last row
        CGFloat visibleAssetsHeight = BKCameraRollSpecs.closedDrawerHeight - BKCameraRollSpecs.drawerHandleHeight;
        scrollToItemAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(0, _assetsController.view.contentSize.height - visibleAssetsHeight - topInset)];
    } else { // Anywhere in between
        CGFloat visibleAssetsHeight = BKCameraRollSpecs.closedDrawerHeight - BKCameraRollSpecs.drawerHandleHeight;
        CGFloat availableHeight = visibleAssetsHeight - CGRectGetHeight(layoutAttributes.bounds);
        CGFloat offset = layoutAttributes.frame.origin.y - availableHeight * bias - topInset;
        scrollToItemAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(0, offset)];
    }

    [_assetsController.view pop_addAnimation:scrollToItemAnimation forKey:@"scrollToItem"];
}

- (void)_updateDrawerPosition:(BKCameraRollDrawerPosition)drawerPosition animated:(BOOL)animated
{
    if (_viewSpec.drawerPosition != drawerPosition) {
        _viewSpec.drawerPosition = drawerPosition;

        if (_viewSpec.drawerPosition == BKCameraRollDrawerPositionHidden) {
            if (!_prefersStatusBarHidden) {
                _prefersStatusBarHidden = YES;
                [self setNeedsStatusBarAppearanceUpdate];
            }
        } else {
            if (_prefersStatusBarHidden) {
                _prefersStatusBarHidden = NO;
                [self setNeedsStatusBarAppearanceUpdate];
            }
        }
    }

    const CGFloat newDrawerOffset = [_viewSpec drawerOffsetForDrawerPosition:_viewSpec.drawerPosition];
    const UIEdgeInsets newFloorContentInset = [_viewSpec floorContentInsetForDrawerPosition:_viewSpec.drawerPosition];

    if (animated) {
        [_viewSpec pop_removeAnimationForKey:kBKCameraRollDrawerOffsetProperty];
        _drawerSpring.fromValue = @(_viewSpec.drawerOffset);
        _drawerSpring.toValue = @(newDrawerOffset);

        [_viewSpec pop_removeAnimationForKey:kBKCameraRollFloorContentInsetProperty];
        _floorSpring.fromValue = [NSValue valueWithUIEdgeInsets:_viewSpec.floorContentInset];
        _floorSpring.toValue = [NSValue valueWithUIEdgeInsets:newFloorContentInset];

        // HACK
        if (_viewSpec.drawerPosition == BKCameraRollDrawerPositionHidden) {
            _drawerSpring.springBounciness = 0;
            _drawerSpring.springSpeed = BKCameraRollSpecs.drawerSpringSpeedFast;
        } else {
            _drawerSpring.springBounciness = BKCameraRollSpecs.drawerSpringBounciness;
            _drawerSpring.springSpeed = BKCameraRollSpecs.drawerSpringSpeedNormal;
        }
        // END HACK

        [_viewSpec pop_addAnimation:_drawerSpring forKey:kBKCameraRollDrawerOffsetProperty];
        [_viewSpec pop_addAnimation:_floorSpring forKey:kBKCameraRollFloorContentInsetProperty];
    } else {
        [_viewSpec pop_removeAnimationForKey:kBKCameraRollDrawerOffsetProperty];
        _drawerOffsetProperty.writeBlock(_viewSpec, (const CGFloat[]){newDrawerOffset});
        _floorContentInsetProperty.writeBlock(_viewSpec, (const CGFloat *)&newFloorContentInset);
    }

    [_drawerHandleArrow setDirection:[self _directionForDrawerPosition:drawerPosition] animated:animated];
}

- (BKDrawerHandleArrowDirection)_directionForDrawerPosition:(BKCameraRollDrawerPosition)position
{
    return (position == BKCameraRollDrawerPositionOpened) ? BKDrawerHandleArrowDirectionDown : BKDrawerHandleArrowDirectionUp;
}

#pragma mark - Status bar

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

@end
