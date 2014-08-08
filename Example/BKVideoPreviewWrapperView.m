// Copyright 2014-present 650 Industries. All rights reserved.

#import "BKVideoPreviewWrapperView.h"

#define __layer ((AVCaptureVideoPreviewLayer *)self.layer)

@import AVFoundation;

@implementation BKVideoPreviewWrapperView

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (void)setSession:(AVCaptureSession *)session
{
    __layer.session = session;
}

- (AVCaptureSession *)session
{
    return __layer.session;
}

- (AVCaptureConnection *)connection
{
    return __layer.connection;
}

- (void)setVideoGravity:(NSString *)videoGravity
{
    __layer.videoGravity = [videoGravity copy];
}

- (NSString *)videoGravity
{
    return __layer.videoGravity;
}

@end
