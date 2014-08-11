//  Copyright (c) 2014 650 Industries, Inc. All rights reserved.

#import "BKActivityOverlayView.h"

@import OpenGLES;
@import QuartzCore;

@implementation BKActivityOverlayView {
    dispatch_queue_t _glQueue;

    EAGLContext *_context;
}

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _glQueue = dispatch_queue_create("net.sixfivezero.activitymonitor", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(_glQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));

        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];


        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.opaque = NO;
        eaglLayer.drawableProperties = @{kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};
        dispatch_async(_glQueue, ^{
            [EAGLContext setCurrentContext:_context];
            glClearColor(0, 0, 0, 0);
            glFlush();
            [EAGLContext setCurrentContext:nil];
        });
    }
    return self;
}

/**
 The overlay doesn't currently support touches of any sort, but this leaves open the possibility of making it draggable.
 */
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return NO;
}

@end