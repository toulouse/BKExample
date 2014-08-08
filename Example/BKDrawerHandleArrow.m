// Copyright 2014-present 650 Industries. All rights reserved.

#import "BKDrawerHandleArrow.h"

@implementation BKDrawerHandleArrow

- (instancetype)init
{
    CGRect defaultFrame = CGRectMake(0, 0, 36, 11);
    return [self initWithFrame:defaultFrame];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super init]) {
        _direction = BKDrawerHandleArrowDirectionNeutral;

        _layer = [CAShapeLayer layer];
        _layer.frame = frame;
        _layer.fillColor = nil;
        _layer.strokeColor = [UIColor colorWithWhite:0 alpha:0.48].CGColor;
        _layer.lineCap = kCALineCapRound;
        _layer.lineJoin = kCALineJoinRound;
        _layer.lineWidth = 7;
        _layer.path = [self _pathForDirection:_direction].CGPath;
    }
    return self;
}

- (void)setDirection:(BKDrawerHandleArrowDirection)direction
{
    [self setDirection:direction animated:NO];
}

- (void)setDirection:(BKDrawerHandleArrowDirection)direction animated:(BOOL)animated
{
    UIBezierPath *path = [self _pathForDirection:direction];
    if (animated) {
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        pathAnimation.duration = 0.1;
        pathAnimation.fromValue = (id)_layer.path;
        pathAnimation.toValue = (id)path.CGPath;
        [_layer addAnimation:pathAnimation forKey:@"path"];
    }
    _layer.path = path.CGPath;

    [self willChangeValueForKey:@"direction"];
    _direction = direction;
    [self didChangeValueForKey:@"direction"];
}

#pragma mark - Paths

- (UIBezierPath *)_pathForDirection:(BKDrawerHandleArrowDirection)direction
{
    switch (direction) {
        case BKDrawerHandleArrowDirectionNeutral:
            return [self _neutralPath];
        case BKDrawerHandleArrowDirectionUp:
            return [self _upwardPath];
        case BKDrawerHandleArrowDirectionDown:
            return [self _downwardPath];
    }
}

- (UIBezierPath *)_neutralPath
{
    CGFloat lineCapRadius = _layer.lineWidth / 2;
    CGFloat leftX = CGRectGetMinX(_layer.bounds) + lineCapRadius;
    CGFloat rightX = CGRectGetMaxX(_layer.bounds) - lineCapRadius;
    CGFloat midY = CGRectGetMidY(_layer.bounds);

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(leftX, midY)];
    [path addLineToPoint:CGPointMake(CGRectGetMidX(_layer.bounds), midY)];
    [path addLineToPoint:CGPointMake(rightX, midY)];
    return path;
}

- (UIBezierPath *)_upwardPath
{
    CGFloat lineCapRadius = _layer.lineWidth / 2;
    CGFloat leftX = CGRectGetMinX(_layer.bounds) + lineCapRadius;
    CGFloat rightX = CGRectGetMaxX(_layer.bounds) - lineCapRadius;
    CGFloat topY = CGRectGetMinY(_layer.bounds) + lineCapRadius;
    CGFloat bottomY = CGRectGetMaxY(_layer.bounds) - lineCapRadius;

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(leftX, bottomY)];
    [path addLineToPoint:CGPointMake(CGRectGetMidX(_layer.bounds), topY)];
    [path addLineToPoint:CGPointMake(rightX, bottomY)];
    return path;
}

- (UIBezierPath *)_downwardPath
{
    CGFloat lineCapRadius = _layer.lineWidth / 2;
    CGFloat leftX = CGRectGetMinX(_layer.bounds) + lineCapRadius;
    CGFloat rightX = CGRectGetMaxX(_layer.bounds) - lineCapRadius;
    CGFloat topY = CGRectGetMinY(_layer.bounds) + lineCapRadius;
    CGFloat bottomY = CGRectGetMaxY(_layer.bounds) - lineCapRadius;

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(leftX, topY)];
    [path addLineToPoint:CGPointMake(CGRectGetMidX(_layer.bounds), bottomY)];
    [path addLineToPoint:CGPointMake(rightX, topY)];
    return path;
}

@end
