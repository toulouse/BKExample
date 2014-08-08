// Copyright 2014-present 650 Industries. All rights reserved.

struct BKCameraControlSpecs {
    const UIEdgeInsets controlButtonHitSlop;
    const CGSize cancelButtonSize;
    const CGSize takeButtonSize;
};

const struct BKCameraControlSpecs BKCameraControlSpecs;

@class BKCameraController;
@protocol BKCameraControlViewDelegate;

@interface BKCameraControlView : UIView

@property (nonatomic, weak) id<BKCameraControlViewDelegate> delegate;
@property (nonatomic, assign) CGFloat percentCameraState;

- (instancetype)initWithCameraController:(BKCameraController *)cameraController;

@end

@protocol BKCameraControlViewDelegate <NSObject>

- (void)cameraControlView:(BKCameraControlView *)controlView didCaptureAssetWithURL:(NSURL *)assetURL;
- (void)cameraControlViewDidCancel:(BKCameraControlView *)controlView;

@end