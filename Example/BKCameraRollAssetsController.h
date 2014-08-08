// Copyright 2014-present 650 Industries. All rights reserved.

#import "BKCameraControlViewCoordinator.h"

@import AssetsLibrary.ALAssetsLibrary;

@class ALAsset;
@class BKCameraControlView;
@protocol BKCameraRollAssetsControllerDelegate;

@interface BKCameraRollAssetsController : NSObject <UICollectionViewDataSource, UICollectionViewDelegate, BKCameraControlContainer>

@property (nonatomic, weak) id<BKCameraRollAssetsControllerDelegate> delegate;

@property (nonatomic, weak) BKCameraControlView *controlView;

@property (nonatomic, strong, readonly) UICollectionView *view;
@property (nonatomic, copy, readonly) NSArray *assets;
@property (nonatomic, copy, readonly) NSError *error;

- (void)didLoad;
- (void)loadAssetsWithCompletion:(void (^)())completion;
- (void)assetForURL:(NSURL *)assetURL resultBlock:(ALAssetsLibraryAssetForURLResultBlock)resultBlock failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock;
@end

@protocol BKCameraRollAssetsControllerDelegate <NSObject>

- (void)assetsControllerDidSelectCamera:(BKCameraRollAssetsController *)controller;
- (void)assetsController:(BKCameraRollAssetsController *)controller didSelectAsset:(ALAsset *)asset atIndexPath:(NSIndexPath *)indexPath;

@end
