// Copyright (c) 2014-present 650 Industries, Inc. All rights reserved.

#import "BKCameraRollViewSpec.h"

#import <BKRecursiveDescription/BKRecursiveDescription.h>

#import "BKCameraRollViewController.h"
#import "BKGeometry.h"

@interface BKCameraRollButtonSpec ()

@property (nonatomic, assign, readwrite) CGRect bounds;
@property (nonatomic, assign, readwrite) CGPoint center;
@property (nonatomic, assign, readwrite) CGFloat alpha;

@end

@implementation BKCameraRollViewSpec

- (instancetype)init
{
    if (self = [super init]) {
        _drawerPosition = BKCameraRollDrawerPositionOpened;
        _previousDrawerPosition = BKCameraRollDrawerPositionOpened;

        _acceptSpec = [[BKCameraRollButtonSpec alloc] init];
    }
    return self;
}

- (void)setDrawerPosition:(BKCameraRollDrawerPosition)drawerPosition
{
    if (_drawerPosition != drawerPosition) {
        self.previousDrawerPosition = _drawerPosition;
        _drawerPosition = drawerPosition;
    }
}

- (void)layout
{
    // DRAWER LOGIC
    // _drawerOffset's origin logically starts from under the top bar, so we should correct for that
    const CGFloat closedDrawerOffset = CGRectGetHeight(_bounds) - BKCameraRollSpecs.closedDrawerHeight;
    const CGFloat deltaFromClosedOffset = _drawerOffset - closedDrawerOffset;

    // * Fixed-size rect: just shift it down when you slide it down, to prevent a ton of re-layout, i.e. dequeueing cells
    //   if the hosted scrollview is a table view or collection view.
    // * Flexible-sized rect: stretch it when pulling the drawer outside its normal range.
    const CGFloat typicalDrawerHeight = CGRectGetHeight(_bounds) - _floorContentInset.top;
    const CGRect fixedSizeDrawerRect = CGRectMake(0, _drawerOffset, CGRectGetWidth(_bounds), typicalDrawerHeight);

    CGRect flexibleSizeDrawerRect = UIEdgeInsetsInsetRect(_bounds, UIEdgeInsetsMake(_drawerOffset, 0, 0, 0));

    // The handle should overlap and be above the collection view. The rationale for not splitting their area is that
    // one might want to give the handle a blur effect, so we want the content to keep showing underneath.
    _drawerInsets.top = BKCameraRollSpecs.drawerHandleHeight;

    // If the flexible-size rect is bigger than the fixed sized rect then we're stretching outside the resting position
    // for an open drawer. The fixed-size rect doesn't change its size, so we need to set its insets to the amount that
    // is hidden. Since the drawer's bottom matches the floor's bottom, and since we've defined the resting point of an
    // open drawer to be the top floor inset, with a bottom inset == drawer offset - top floor inset, the bottom inset
    // pushes the bottom up by the same amount the drawer offset masks the bottom area of the drawer.
    if (CGRectGetHeight(flexibleSizeDrawerRect) > typicalDrawerHeight) {
        _drawerFrame = flexibleSizeDrawerRect;
        _drawerInsets.bottom = 0;
    } else {
        _drawerFrame = fixedSizeDrawerRect;
        _drawerInsets.bottom = _drawerOffset - _floorContentInset.top;
    }

    // FLOOR LOGIC
    // Note: these heights don't account for the vertical content insets yet.
    const CGFloat defaultFloorContentHeight = CGRectGetHeight(_bounds) - BKCameraRollSpecs.closedDrawerHeight;
    const CGFloat minFloorContentHeight = defaultFloorContentHeight - BKCameraRollSpecs.floorUndersizeMargin;
    const CGFloat visibleFloorContentHeight = _drawerOffset;

    const CGFloat floorContentHeight = fmax(minFloorContentHeight, fmin(visibleFloorContentHeight, defaultFloorContentHeight));
    _floorContentFrame = UIEdgeInsetsInsetRect(CGRectMake(0, 0, CGRectGetWidth(_bounds), floorContentHeight), _floorContentInset);

    if (visibleFloorContentHeight > defaultFloorContentHeight) {
        const CGFloat extraFloorContentHeight = visibleFloorContentHeight - defaultFloorContentHeight;
        const CGFloat percentClosedToHidden = extraFloorContentHeight / BKCameraRollSpecs.closedDrawerHeight;
        const CGFloat distanceToCenter = CGRectGetMidY(_bounds) - CGRectGetMidY(_floorContentFrame);
        _floorContentFrame = CGRectOffset(_floorContentFrame, 0, distanceToCenter * percentClosedToHidden);
    }

    // PIXEL-ALIGNED RECTS
    // Make rects integral, else we get flickering when the floats sit on pixel boundaries and stuff gets rounded.
    _floorContentFrame = BKRectIntegralScaled(_floorContentFrame, [UIScreen mainScreen].scale);
    _drawerFrame = BKRectIntegralScaled(_drawerFrame, [UIScreen mainScreen].scale);

    // Useful calculations
    const BOOL isInOpenRegion = deltaFromClosedOffset <= 0;
    const BOOL isInClosedRegionAndUnhidden = _drawerPosition != BKCameraRollDrawerPositionHidden && !isInOpenRegion;

    // ALPHA
    // [0, closedDrawerHeight] & (openDrawerHeight, bottom]
    const CGFloat percentOpenToClosedDrawer = (_drawerOffset - _floorContentInset.top) / closedDrawerOffset;
    const CGFloat percentClosedToHiddenDrawer = deltaFromClosedOffset / BKCameraRollSpecs.closedDrawerHeight;
    const CGFloat percent = isInOpenRegion ? percentOpenToClosedDrawer : 1 - percentClosedToHiddenDrawer;
    const CGFloat clampedPercent = fmin(fmax(0.0, percent), 1.0); // Clamp to [0,1]

    // ACCEPT BUTTON
    _acceptSpec.bounds = CGRectMake(0, 0, BKCameraRollSpecs.buttonSize.width, BKCameraRollSpecs.buttonSize.height);
    _acceptSpec.center = CGPointMake(CGRectGetMaxX(_drawerFrame) - BKCameraRollSpecs.buttonSize.width / 2 - BKCameraRollSpecs.rightButtonAreaInsets.right,
                                     CGRectGetMinY(_drawerFrame) - BKCameraRollSpecs.buttonSize.height / 2 - BKCameraRollSpecs.rightButtonAreaInsets.bottom);
    _acceptSpec.alpha = isInClosedRegionAndUnhidden ? 1.0 : clampedPercent;

    if ((_drawerPosition == BKCameraRollDrawerPositionHidden && _previousDrawerPosition == BKCameraRollDrawerPositionClosed) ||
        (_drawerPosition == BKCameraRollDrawerPositionClosed && _previousDrawerPosition == BKCameraRollDrawerPositionHidden)) {
        _percentHiddenState = deltaFromClosedOffset / BKCameraRollSpecs.closedDrawerHeight;
    } else if (_drawerPosition == BKCameraRollDrawerPositionHidden && _previousDrawerPosition == BKCameraRollDrawerPositionOpened){
        _percentHiddenState = (_drawerOffset) / CGRectGetHeight(_bounds);
    } else if (_drawerPosition == BKCameraRollDrawerPositionOpened && _previousDrawerPosition == BKCameraRollDrawerPositionHidden) {
        _percentHiddenState = (_drawerOffset - _floorContentInset.top) / CGRectGetHeight(_bounds);
    }
}

- (CGFloat)drawerOffsetForDrawerPosition:(BKCameraRollDrawerPosition)position
{
    const CGFloat bottomOffset = CGRectGetHeight(_bounds);

    switch (position) {
        case BKCameraRollDrawerPositionHidden:
            return bottomOffset;
        case BKCameraRollDrawerPositionClosed:
            return bottomOffset - BKCameraRollSpecs.closedDrawerHeight;
        case BKCameraRollDrawerPositionOpened: {
            UIEdgeInsets floorContentInset = [self floorContentInsetForDrawerPosition:position];
            return floorContentInset.top;
        }
    }
}

- (UIEdgeInsets)floorContentInsetForDrawerPosition:(BKCameraRollDrawerPosition)position
{
    // TODO: Look into whether we should incorporate status bar changes
    return UIEdgeInsetsMake(BKCameraRollSpecs.topFloorInset, 0, BKCameraRollSpecs.bottomFloorInset, 0);
}

- (void)bk_addRecursiveDescriptionToString:(NSMutableString *)string level:(NSUInteger)level
{
    DESCRIBE_SELF(string, self);

    DESCRIBE_VARIABLE(string, level, _drawerPosition);
    DESCRIBE_VARIABLE(string, level, _bounds);
    DESCRIBE_VARIABLE(string, level, _drawerOffset);
    DESCRIBE_VARIABLE(string, level, _floorContentInset);
    DESCRIBE_VARIABLE(string, level, _previousDrawerPosition);
    DESCRIBE_VARIABLE(string, level, _floorContentFrame);
    DESCRIBE_VARIABLE(string, level, _drawerFrame);
    DESCRIBE_VARIABLE(string, level, _drawerInsets);
    DESCRIBE_VARIABLE(string, level, _acceptSpec);
    DESCRIBE_VARIABLE(string, level, _percentHiddenState);
}

@end

@implementation BKCameraRollButtonSpec

- (void)bk_addRecursiveDescriptionToString:(NSMutableString *)string level:(NSUInteger)level
{
    DESCRIBE_SELF(string, self);

    DESCRIBE_VARIABLE(string, level, _bounds);
    DESCRIBE_VARIABLE(string, level, _center);
    DESCRIBE_VARIABLE(string, level, _alpha);
}
@end
