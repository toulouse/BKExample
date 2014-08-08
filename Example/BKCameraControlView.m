// Copyright 2014-present 650 Industries. All rights reserved.

#import "BKCameraControlView.h"

@import AVFoundation.AVAnimation;

#import <KVOController/FBKVOController.h>
#import <BKCameraController/BKCameraController.h>
#import <BKHitSlop/BKHitSlop.h>
#import <BKRecursiveDescription/BKRecursiveDescription.h>

#import "BKCameraControlViewSpec.h"
#import "BKCameraRollViewController.h"
#import "BKIcons.h"
#import "BKVideoPreviewWrapperView.h"
#import "UIButton+Bouncy.h"

const struct BKCameraControlSpecs BKCameraControlSpecs = {
    .controlButtonHitSlop = {-10, -10, -10, -10},
    .cancelButtonSize = {40, 40},
    .takeButtonSize = {120, 120},
};

@implementation BKCameraControlView {
    __weak BKCameraController *_cameraController;
    FBKVOController *_kvoController;

    // View spec
    BKCameraControlViewSpec *_viewSpec;
    BOOL _needsRefresh;

    // Images
    UIImage *_flashOffImage;
    UIImage *_flashOnImage;
    UIImage *_flashAutoImage;

    // Views
    BKVideoPreviewWrapperView *_videoPreview;
    UIView *_overlay;
    UIImageView *_cameraIconView;
    UIButton *_flashButton;
    UIButton *_switchCameraButton;
    UIButton *_cancelButton;
    UIButton *_takeButton;
}

- (instancetype)initWithCameraController:(BKCameraController *)cameraController
{
    if (self = [super init]) {
        _cameraController = cameraController;

        _kvoController = [[FBKVOController alloc] initWithObserver:self];
        [_kvoController observe:_cameraController keyPath:@"flashMode" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            NSNumber *flashModeNumber = (NSNumber *)change[NSKeyValueChangeNewKey];
            AVCaptureFlashMode mode = (AVCaptureFlashMode)[flashModeNumber integerValue];
            BOOL flashCapable = ((BKCameraController *)object).flashCapable;
            [observer _updateFlashButtonForMode:mode capable:flashCapable];
        }];

        // View spec
        _viewSpec = [[BKCameraControlViewSpec alloc] init];

        // Images
        _flashOffImage = [UIImage imageNamed:@"FlashOff"];
        _flashOnImage = [UIImage imageNamed:@"FlashOn"];
        _flashAutoImage = [UIImage imageNamed:@"FlashAuto"];

        // Views
        _videoPreview = [[BKVideoPreviewWrapperView alloc] init];
        _videoPreview.session = cameraController.session;
        _videoPreview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _videoPreview.clipsToBounds = YES;
        [self addSubview:_videoPreview];

        _overlay = [[UIView alloc] init];
        _overlay.backgroundColor = [UIColor whiteColor];
        [self addSubview:_overlay];

        UIImage *cameraIcon = [UIImage imageNamed:@"CameraIcon"];
        _cameraIconView = [[UIImageView alloc] initWithImage:cameraIcon];
        [self addSubview:_cameraIconView];

        // Views (Buttons)
        _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _flashButton.alpha = 0;
        _flashButton.bouncy = YES;
        _flashButton.bk_hitSlop = BKCameraControlSpecs.controlButtonHitSlop;
        [self _updateFlashButtonForMode:AVCaptureFlashModeOff capable:YES];
        [_flashButton addTarget:self action:@selector(_buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_flashButton];

        _switchCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _switchCameraButton.alpha = 0;
        _switchCameraButton.bouncy = YES;
        _switchCameraButton.bk_hitSlop = BKCameraControlSpecs.controlButtonHitSlop;
        [_switchCameraButton setImage:[UIImage imageNamed:@"SwitchCamera"] forState:UIControlStateNormal];
        [_switchCameraButton addTarget:self action:@selector(_buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_switchCameraButton];

        UIImage *cancelImage = [BKIcons xWithSize:BKCameraControlSpecs.cancelButtonSize
                                            color:[UIColor redColor]
                                      strokeColor:[UIColor blackColor]
                                        lineWidth:4];
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.alpha = 0;
        _cancelButton.adjustsImageWhenHighlighted = NO;
        _cancelButton.bouncy = YES;
        _cancelButton.bk_hitSlop = BKCameraControlSpecs.controlButtonHitSlop;
        _cancelButton.layer.masksToBounds = NO;
        [_cancelButton setImage:cancelImage forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(_buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelButton];

        UIImage *takeImage = [BKIcons circleWithSize:BKCameraControlSpecs.takeButtonSize
                                           fillColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:64.0/255.0]
                                         strokeColor:[UIColor whiteColor]
                                           lineWidth:4];
        _takeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _takeButton.alpha = 0;
        _takeButton.adjustsImageWhenHighlighted = NO;
        _takeButton.bouncy = YES;
        _takeButton.bk_hitSlop = BKCameraControlSpecs.controlButtonHitSlop;
        _takeButton.layer.masksToBounds = NO;
        [_takeButton setImage:takeImage forState:UIControlStateNormal];
        [_takeButton addTarget:self action:@selector(_buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_takeButton];
    }
    return self;
}

- (void)layoutSubviews
{
    _viewSpec.bounds = self.bounds;
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

        _videoPreview.frame = _viewSpec.videoPreviewFrame;
        _overlay.frame = _viewSpec.overlayFrame;
        _cancelButton.frame = _viewSpec.cancelButtonFrame;
        _flashButton.frame = _viewSpec.flashButtonFrame;
        _switchCameraButton.frame = _viewSpec.switchCameraButtonFrame;
        _takeButton.frame = _viewSpec.takeButtonFrame;
        _cameraIconView.center = _viewSpec.cameraIconCenter;

        _overlay.alpha = _viewSpec.overlayAlpha;
        _cancelButton.alpha = _viewSpec.buttonAlpha;
        _flashButton.alpha = _viewSpec.buttonAlpha;
        _switchCameraButton.alpha = _viewSpec.buttonAlpha;
        _takeButton.alpha = _viewSpec.buttonAlpha;

        if (_overlay) {
            _overlay.alpha = _viewSpec.overlayAlpha;
            _cameraIconView.alpha = _viewSpec.cameraIconAlpha;
        }

        _needsRefresh = NO;
    }
}
- (void)setPercentCameraState:(CGFloat)percentCameraState
{
    _viewSpec.percentCameraState = percentCameraState;
    [self _setNeedsRefresh];
    [self _refreshIfNeeded];
}

- (CGFloat)percentCameraState
{
    return _viewSpec.percentCameraState;
}

#pragma mark - Button logic

- (void)_updateFlashButtonForMode:(AVCaptureFlashMode)flashMode capable:(BOOL)flashCapable
{
    UIImage *icon;
    switch (flashMode) {
        case AVCaptureFlashModeOff:
            icon = _flashOffImage;
            break;
        case AVCaptureFlashModeOn:
            icon = _flashOnImage;
            break;
        case AVCaptureFlashModeAuto:
            icon = _flashAutoImage;
            break;
        default:
            icon = nil;
            NSAssert(NO, @"ERROR: Unknown flash mode: %d", (int)flashMode);
    }
    [_flashButton setImage:icon forState:UIControlStateNormal];
    _flashButton.enabled = flashCapable;
}

- (void)_buttonPressed:(UIButton *)sender
{
    if (sender == _cancelButton) {
        if ([_delegate respondsToSelector:@selector(cameraControlViewDidCancel:)]) {
            [_delegate cameraControlViewDidCancel:self];
        }
    } else if (sender == _flashButton) {
        [_cameraController cycleFlashMode];
    } else if (sender == _switchCameraButton) {
        [_cameraController cyclePosition];
    } else if (sender == _takeButton) {
        [_cameraController captureAssetWithCompletion:^(NSURL *assetURL, NSError *error) {
            if ([_delegate respondsToSelector:@selector(cameraControlView:didCaptureAssetWithURL:)]) {
                [_delegate cameraControlView:self didCaptureAssetWithURL:assetURL];
            }
        }];
    } else {
        NSAssert(NO, @"ERROR: Unknown button");
    }
}

#pragma mark - BKDescribable method

- (void)bk_addRecursiveDescriptionToString:(NSMutableString *)string level:(NSUInteger)level
{
    DESCRIBE_SELF(string, self);

    DESCRIBE_VARIABLE(string, level, _delegate);

    DESCRIBE_VARIABLE(string, level, _cameraController);
    DESCRIBE_VARIABLE(string, level, _kvoController);

    DESCRIBE_VARIABLE(string, level, _viewSpec);
    DESCRIBE_VARIABLE(string, level, _needsRefresh);

    DESCRIBE_VARIABLE(string, level, _flashOffImage);
    DESCRIBE_VARIABLE(string, level, _flashOnImage);
    DESCRIBE_VARIABLE(string, level, _flashAutoImage);

    DESCRIBE_VARIABLE(string, level, _videoPreview);
    DESCRIBE_VARIABLE(string, level, _overlay);
    DESCRIBE_VARIABLE(string, level, _cameraIconView);
    DESCRIBE_VARIABLE(string, level, _flashButton);
    DESCRIBE_VARIABLE(string, level, _switchCameraButton);
    DESCRIBE_VARIABLE(string, level, _cancelButton);
    DESCRIBE_VARIABLE(string, level, _takeButton);
}

@end
