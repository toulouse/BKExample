// Copyright 2014-present 650 Industries. All rights reserved.

#import "BKCameraRollAssetCollectionViewCell.h"

@implementation BKCameraRollAssetCollectionViewCell {
    UIImageView *_imageView;
    UIColor *_borderColor;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] init];
        _borderColor = [UIColor colorWithRed:0.133 green:0.514 blue:0.969 alpha:1.0];
        [self addSubview:_imageView];
    }
    return self;
}

- (void)layoutSubviews
{
    _imageView.frame = self.bounds;
}

- (void)setImage:(UIImage *)image
{
    _imageView.image = image;
}

- (UIImage *)image
{
    return _imageView.image;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];

    if (selected) {
        self.layer.borderWidth = 2;
        self.layer.borderColor = _borderColor.CGColor;
    } else {
        self.layer.borderWidth = 0;
        self.layer.borderColor = nil;
    }
}

@end
