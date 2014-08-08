// Copyright (c) 2014-present 650 Industries, Inc. All rights reserved.

#import "BKCameraControlViewSpec.h"

#import <BKRecursiveDescription/BKRecursiveDescription.h>

#import "BKCameraControlView.h"

@implementation BKCameraControlViewSpec

- (void)layout
{
    _videoPreviewFrame = _bounds;
    _overlayFrame = _bounds;

    _flashButtonFrame = CGRectMake(0.0, 0.0, 90.0, 60.0);
    _switchCameraButtonFrame = CGRectMake(CGRectGetWidth(_bounds) - 60, 0.0, 60.0, 60.0);

    CGRect cancelButtonFrame;
    cancelButtonFrame.origin = CGPointMake(20, CGRectGetHeight(_bounds) - 50);
    cancelButtonFrame.size = BKCameraControlSpecs.cancelButtonSize;
    _cancelButtonFrame = cancelButtonFrame;

    CGRect takeButtonFrame;
    takeButtonFrame.origin = CGPointMake(CGRectGetMidX(_bounds) - BKCameraControlSpecs.takeButtonSize.width / 2,
                                         CGRectGetHeight(_bounds) - BKCameraControlSpecs.takeButtonSize.height);
    takeButtonFrame.size = BKCameraControlSpecs.takeButtonSize;
    _takeButtonFrame = takeButtonFrame;

    _cameraIconCenter = CGPointMake(CGRectGetMidX(_bounds), CGRectGetMidY(_bounds));

    _overlayAlpha = (1 - _percentCameraState) * 0.5;
    _cameraIconAlpha = 1 - _percentCameraState;
    _buttonAlpha = _percentCameraState;
}
- (void)bk_addRecursiveDescriptionToString:(NSMutableString *)string level:(NSUInteger)level
{
    DESCRIBE_SELF(string, self);

    DESCRIBE_VARIABLE(string, level, _bounds);
    DESCRIBE_VARIABLE(string, level, _percentCameraState);

    DESCRIBE_VARIABLE(string, level, _videoPreviewFrame);
    DESCRIBE_VARIABLE(string, level, _overlayFrame);
    DESCRIBE_VARIABLE(string, level, _cancelButtonFrame);
    DESCRIBE_VARIABLE(string, level, _flashButtonFrame);
    DESCRIBE_VARIABLE(string, level, _switchCameraButtonFrame);
    DESCRIBE_VARIABLE(string, level, _takeButtonFrame);

    DESCRIBE_VARIABLE(string, level, _cameraIconCenter);

    DESCRIBE_VARIABLE(string, level, _overlayAlpha);
    DESCRIBE_VARIABLE(string, level, _cameraIconAlpha);
    DESCRIBE_VARIABLE(string, level, _buttonAlpha);

}
@end
