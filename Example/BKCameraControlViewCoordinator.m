// Copyright 2014-present 650 Industries. All rights reserved.

#import "BKCameraControlViewCoordinator.h"

#import <BKCameraController/BKCameraController.h>

#import "BKCameraControlView.h"

#define FLT_LERP(a, b, percent) ((a) + (percent) * ((b) - (a)))

void BKLerpRect(CGRect *dst, const CGRect *from, const CGRect *to, CGFloat percent) {
    dst->origin.x = FLT_LERP(from->origin.x, to->origin.x, percent);
    dst->origin.y = FLT_LERP(from->origin.y, to->origin.y, percent);
    dst->size.width = FLT_LERP(from->size.width, to->size.width, percent);
    dst->size.height = FLT_LERP(from->size.height, to->size.height, percent);
}

@implementation BKCameraControlViewCoordinator {
    UIView *_anchorView;
    BKCameraControlView *_controlView;
}

- (instancetype)initWithControlView:(BKCameraControlView *)controlView
                         anchorView:(UIView *)anchorView;
{
    if (self = [super init]) {
        _controlView = controlView;
        _anchorView = anchorView;
        _finished = YES;
    }
    return self;
}

- (void)beginInteractiveTransitionFromContainer:(id<BKCameraControlContainer>)fromContainer
                                    toContainer:(id<BKCameraControlContainer>)toContainer
{
    if (!_finished) {
        return;
    }

    _finished = NO;
    _fromContainer = fromContainer;
    _toContainer = toContainer;

    // Re-parent control view to the anchor view.
    CGRect rootFrame = [_controlView convertRect:_controlView.frame toView:nil];
    CGRect anchoredFrame = [_anchorView convertRect:rootFrame fromView:nil];
    [_anchorView addSubview:_controlView];
    [_fromContainer setControlView:nil];
    _controlView.frame = anchoredFrame;
}

- (void)setProgress:(CGFloat)progress
{
    if (_finished) {
        return;
    }

    if (_progress != progress) {
        _progress = fmin(fmax(0.0, progress), 1.0);
    }

    UIView *fromView = [_fromContainer cameraControlContainerView];
    UIView *toView = [_toContainer cameraControlContainerView];
    CGRect fromFrameGlobal = [fromView convertRect:fromView.frame toView:nil];
    CGRect fromFrame = [_anchorView convertRect:fromFrameGlobal fromView:nil];
    CGRect toFrameGlobal = [toView convertRect:toView.frame toView:nil];
    CGRect toFrame = [_anchorView convertRect:toFrameGlobal fromView:nil];

    CGRect lerpedFrame;
    BKLerpRect(&lerpedFrame, &fromFrame, &toFrame, _progress);

    if (CGRectEqualToRect(lerpedFrame, CGRectZero)) {
        NSLog(@"Zero");
    }

    _controlView.frame = lerpedFrame;
}

- (void)finishInteractiveTransition
{
    [_toContainer setControlView:_controlView];

    _finished = YES;
    _fromContainer = nil;
    _toContainer = nil;
}

@end
