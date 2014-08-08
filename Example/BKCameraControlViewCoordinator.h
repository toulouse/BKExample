// Copyright 2014-present 650 Industries. All rights reserved.

@class BKCameraController;
@class BKCameraControlView;

@protocol BKCameraControlContainer;

@interface BKCameraControlViewCoordinator : NSObject

@property (nonatomic, weak, readonly) id<BKCameraControlContainer> fromContainer;
@property (nonatomic, weak, readonly) id<BKCameraControlContainer> toContainer;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign, readonly) BOOL finished;

@property (nonatomic, weak) id<BKCameraControlContainer> floorContainer;
@property (nonatomic, weak) id<BKCameraControlContainer> cellContainer;

- (instancetype)initWithControlView:(BKCameraControlView *)controlView
                         anchorView:(UIView *)anchorView;

- (void)beginInteractiveTransitionFromContainer:(id<BKCameraControlContainer>)fromContainer
                                    toContainer:(id<BKCameraControlContainer>)toContainer;
- (void)finishInteractiveTransition;

@end

@protocol BKCameraControlContainer <NSObject>

- (UIView *)cameraControlContainerView;
- (void)setControlView:(BKCameraControlView *)controlView;

@end
