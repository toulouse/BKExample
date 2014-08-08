// Copyright 2014-present 650 Industries. All rights reserved.

#import "BKCameraRollAssetsController.h"

@import AssetsLibrary;

#import "BKCameraRollAssetCollectionViewCell.h"
#import "BKPhotoPreviewCollectionViewCell.h"

@interface BKCameraRollAssetsController ()

@property (nonatomic, copy, readwrite) NSError *error;

@end

@implementation BKCameraRollAssetsController {
    ALAssetsLibrary *_library;
    ALAssetsGroup *_cameraRollGroup;

    UICollectionViewFlowLayout *_flowLayout;
}

- (instancetype)init
{
    if (self = [super init]) {
        _library = [[ALAssetsLibrary alloc] init];
        _assets = @[];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
}

- (void)didLoad
{
    _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    _flowLayout.minimumInteritemSpacing = 2.0;
    _flowLayout.minimumLineSpacing = 2.0;

    _view = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_flowLayout];
    _view.backgroundColor = [UIColor whiteColor];
    _view.alwaysBounceVertical = YES;
    _view.dataSource = self;
    _view.delegate = self;

    [_view registerClass:[BKPhotoPreviewCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([BKPhotoPreviewCollectionViewCell class])];
    [_view registerClass:[BKCameraRollAssetCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([BKCameraRollAssetCollectionViewCell class])];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_reloadAssetsWithNotification:) name:ALAssetsLibraryChangedNotification object:nil];
}

- (void)loadAssetsWithCompletion:(void (^)())completion
{
    __block ALAssetsGroup *cameraRollGroup = nil;
    [_library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        NSAssert([NSThread isMainThread], @"This code expects to be run from the main thread");
        if (!group) { // Enumeration complete
            self.error = nil;
            _cameraRollGroup = cameraRollGroup;
            [self _loadAssetsWithCompletion:completion];
            return;
        }

        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        cameraRollGroup = group;
    } failureBlock:^(NSError *error) {
        NSLog(@"ERROR: %@", error);
        self.error = error;

        [_view performBatchUpdates:^{
            [_view deleteSections:[NSIndexSet indexSetWithIndex:0]];
            _assets = @[];
            [_view insertSections:[NSIndexSet indexSetWithIndex:0]];
        } completion:nil];
    }];
}

- (void)_loadAssetsWithCompletion:(void (^)())completion
{
    NSMutableArray *assets = [NSMutableArray array];
    [_cameraRollGroup enumerateAssetsWithOptions:NSEnumerationReverse
                                      usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        NSAssert([NSThread isMainThread], @"This code expects to be run from the main thread");
        if (!result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _assets = [assets copy];

                [_view reloadData]; // TODO: use something better than reloadData
                if (completion) {
                    completion();
                }
            });
            return;
        }

        [assets addObject:result];
    }];
}

- (void)_reloadAssetsWithNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (notification.userInfo) {
            NSSet *insertedGroupURLs = notification.userInfo[ALAssetLibraryUpdatedAssetGroupsKey];
            NSURL *assetGroupURL = [insertedGroupURLs anyObject];
            if (assetGroupURL) {
                [_library groupForURL:assetGroupURL resultBlock:^(ALAssetsGroup *group) {
                    if ([[group valueForProperty:ALAssetsGroupPropertyType] unsignedIntegerValue] == ALAssetsGroupSavedPhotos) {
                        [self loadAssetsWithCompletion:nil];
                    }
                } failureBlock:^(NSError *error) {
                    
                }];
            }
        }
    });
}

- (void)assetForURL:(NSURL *)assetURL
        resultBlock:(ALAssetsLibraryAssetForURLResultBlock)resultBlock
       failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock
{
    return [_library assetForURL:assetURL resultBlock:resultBlock failureBlock:failureBlock];
}

#pragma mark - BKCameraControlContainer methods

- (UIView *)cameraControlContainerView
{
    BKPhotoPreviewCollectionViewCell *cell = (BKPhotoPreviewCollectionViewCell *)[_view cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    if (cell) {
        return cell.contentView;
    } else {
        return nil;
    }
}

- (void)setControlView:(BKCameraControlView *)controlView
{
    _controlView = controlView;

    BKPhotoPreviewCollectionViewCell *cell = (BKPhotoPreviewCollectionViewCell *)[_view cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    if (cell) {
        cell.controlView = controlView;
    }

    _view.userInteractionEnabled = controlView != nil;
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // Camera preview and photos
    return 1 + _assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0) {
        BKPhotoPreviewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([BKPhotoPreviewCollectionViewCell class])
                                                                                           forIndexPath:indexPath];
        cell.controlView = _controlView;
        return cell;
    } else {
        BKCameraRollAssetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([BKCameraRollAssetCollectionViewCell class])
                                                                               forIndexPath:indexPath];

        ALAsset *asset = _assets[indexPath.row - 1];
        cell.image = [UIImage imageWithCGImage:asset.thumbnail];
        return cell;
    }
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0) {
        [_delegate assetsControllerDidSelectCamera:self];
    } else {
        ALAsset *asset = _assets[indexPath.row - 1];
        [_delegate assetsController:self didSelectAsset:asset atIndexPath:indexPath];
    }
}

@end
