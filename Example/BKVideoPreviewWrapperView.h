// Copyright 2014-present 650 Industries. All rights reserved.

@class AVCaptureConnection;
@class AVCaptureSession;

@interface BKVideoPreviewWrapperView : UIView

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong, readonly) AVCaptureConnection *connection;
@property (nonatomic, copy) NSString *videoGravity;
@end
