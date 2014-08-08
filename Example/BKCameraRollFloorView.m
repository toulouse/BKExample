// Copyright 2014-present 650 Industries. All rights reserved.

#import "BKCameraRollFloorView.h"

@interface BKCameraRollFloorView () <UIGestureRecognizerDelegate>
@end

@implementation BKCameraRollFloorView {
    UIImageView *_photoView;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.clipsToBounds = YES;

        _photoView = [[UIImageView alloc] init];
        _photoView.layer.allowsEdgeAntialiasing = YES;
        _photoView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_photoView];
    }
    return self;
}

- (UIImage *)photo
{
    return _photoView.image;
}

- (void)setPhoto:(UIImage *)photo
{
    _photoView.image = photo;
}


- (void)layoutSubviews
{
    _photoView.frame = self.bounds;
}


@end
