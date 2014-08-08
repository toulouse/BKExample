// Copyright 2014-present 650 Industries. All rights reserved.

#import "BKCameraRollFloorController.h"

@import AssetsLibrary;

#import "BKCameraRollFloorView.h"

@implementation BKCameraRollFloorController

- (void)didLoad
{
    _view = [[BKCameraRollFloorView alloc] init];
    _view.autoresizesSubviews = YES;
}

- (void)setAsset:(ALAsset *)asset
{
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        CGImageRef cgImage = [rep fullScreenImage];
        UIImage *image = [UIImage imageWithCGImage:cgImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            _view.photo = image;
        });
    });
}

@end
