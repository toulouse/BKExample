// Copyright 2014-present 650 Industries. All rights reserved.

#import "BKPhotoPreviewCollectionViewCell.h"

#import "BKCameraControlView.h"

@implementation BKPhotoPreviewCollectionViewCell {
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (void)layoutSubviews
{
    _controlView.frame = self.contentView.bounds;
}

- (void)setControlView:(BKCameraControlView *)controlView
{
    if (_controlView != controlView) {
        _controlView = controlView;

        if (_controlView) {
            [self.contentView addSubview:_controlView];
            _controlView.frame = self.contentView.bounds;
            [self.contentView setNeedsLayout];
        }
    }
}

@end
