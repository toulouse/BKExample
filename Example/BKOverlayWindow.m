//  Copyright (c) 2014 650 Industries, Inc. All rights reserved.

#import "BKOverlayWindow.h"

#import "BKActivityOverlayView.h"

@implementation BKOverlayWindow {
    BKActivityOverlayView *_overlayView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.windowLevel = UIWindowLevelStatusBar;

        _overlayView = [[BKActivityOverlayView alloc] init];
        [self addSubview:_overlayView];
    }
    return self;
}

- (void)layoutSubviews
{
    _overlayView.frame = self.bounds;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGPoint overlayViewPoint = [_overlayView convertPoint:point fromView:self];
    BOOL pointInsideOverlayView = [_overlayView pointInside:overlayViewPoint withEvent:event];

    return pointInsideOverlayView;
}

@end
