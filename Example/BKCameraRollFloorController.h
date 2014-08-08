// Copyright 2014-present 650 Industries. All rights reserved.

@class ALAsset;
@class BKCameraRollFloorView;

@interface BKCameraRollFloorController : NSObject

@property (nonatomic, strong, readonly) BKCameraRollFloorView *view;

- (void)didLoad;
- (void)setAsset:(ALAsset *)asset;

@end
