// Copyright (c) 2014-present 650 Industries, Inc. All rights reserved.

@interface BKCameraControlViewSpec : NSObject

@property (nonatomic, assign) CGRect bounds;
@property (nonatomic, assign) CGFloat percentCameraState;

@property (nonatomic, assign, readonly) CGRect videoPreviewFrame;
@property (nonatomic, assign, readonly) CGRect overlayFrame;
@property (nonatomic, assign, readonly) CGRect cancelButtonFrame;
@property (nonatomic, assign, readonly) CGRect flashButtonFrame;
@property (nonatomic, assign, readonly) CGRect switchCameraButtonFrame;
@property (nonatomic, assign, readonly) CGRect takeButtonFrame;

@property (nonatomic, assign, readonly) CGPoint cameraIconCenter;

@property (nonatomic, assign, readonly) CGFloat overlayAlpha;
@property (nonatomic, assign, readonly) CGFloat cameraIconAlpha;
@property (nonatomic, assign, readonly) CGFloat buttonAlpha;

- (void)layout;

@end
