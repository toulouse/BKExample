// Copyright (c) 2014-present 650 Industries, Inc. All rights reserved.

#import "UIButton+Bouncy.h"

@import ObjectiveC;

#import <pop/POP.h>

static const void *UIButtonBouncyKey = &("UIButtonBouncyKey");
static const void *UIButtonBounceScaleKey = &("UIButtonBounceScaleKey");
static NSString * const UIButtonBouncyAnimationKey = @"UIButtonBouncyAnimationKey";

@implementation UIButton (Bouncy)

static CGPoint UIButtonDefaultBounceScale = {0.75, 0.75};

+ (CGPoint)defaultBounceScale
{
    return UIButtonDefaultBounceScale;
}

+ (void)setDefaultBounceScale:(CGPoint)bounceScale
{
    UIButtonDefaultBounceScale = bounceScale;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.bouncy) {
        POPSpringAnimation *spring;
        if ((spring = [self.layer pop_animationForKey:UIButtonBouncyAnimationKey])) {
        } else {
            spring = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
            spring.springBounciness = 16;
            spring.removedOnCompletion = NO;
        }

        spring.toValue = [NSValue valueWithCGPoint:self.bounceScale];
        [self.layer pop_addAnimation:spring forKey:UIButtonBouncyAnimationKey];
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    POPSpringAnimation *spring = [self.layer pop_animationForKey:UIButtonBouncyAnimationKey];
    spring.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];

    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    POPSpringAnimation *spring = [self.layer pop_animationForKey:UIButtonBouncyAnimationKey];
    spring.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];

    [super touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    BOOL containsTouch = NO;
    for (UITouch *touch in touches) {
        if ([self pointInside:[touch locationInView:self] withEvent:event]) {
            containsTouch = YES;
            break;
        } else {
            containsTouch |= NO;
        }
    }

    POPSpringAnimation *spring = [self.layer pop_animationForKey:UIButtonBouncyAnimationKey];
    if (containsTouch) {
        spring.toValue = [NSValue valueWithCGPoint:self.bounceScale];
    } else {
        spring.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
    }

    [super touchesEnded:touches withEvent:event];
}

- (void)setBouncy:(BOOL)bouncy
{
    if (!bouncy) {
        [self pop_removeAllAnimations];
    }
    objc_setAssociatedObject(self, UIButtonBouncyKey, @(bouncy), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)isBouncy
{
    return [objc_getAssociatedObject(self, UIButtonBouncyKey) boolValue];
}

- (void)setBounceScale:(CGPoint)bounceScale
{
    objc_setAssociatedObject(self, UIButtonBounceScaleKey, [NSValue valueWithCGPoint:bounceScale], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGPoint)bounceScale
{
    NSValue *value = objc_getAssociatedObject(self, UIButtonBounceScaleKey);
    if (value) {
        return [value CGPointValue];
    } else  {
        return [[self class] defaultBounceScale];
    }
}

@end
