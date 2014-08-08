// Copyright (c) 2014-present 650 Industries, Inc. All rights reserved.

#import "BKIcons.h"

@implementation BKIcons

+ (UIImage *)circleWithSize:(CGSize)size fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor lineWidth:(CGFloat)lineWidth
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);

    // Scale to 80x80 coordinate space
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), size.width / 80.0, size.height / 80.0);

    // Oval Drawing
    UIBezierPath *ovalPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(12, 12, 56, 56)];
    [fillColor setFill];
    [ovalPath fill];
    [strokeColor setStroke];
    ovalPath.lineWidth = lineWidth;
    [ovalPath stroke];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)xWithSize:(CGSize)size color:(UIColor *)color strokeColor:(UIColor *)strokeColor lineWidth:(CGFloat)lineWidth
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);

    // Scale to 80x80 coordinate space
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), size.width / 80.0, size.height / 80.0);

    // Oval Drawing
    UIBezierPath *ovalPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(4, 4, 72, 72)];
    [strokeColor setStroke];
    ovalPath.lineWidth = lineWidth + 2;
    [ovalPath stroke];
    [color setStroke];
    ovalPath.lineWidth = lineWidth;
    [ovalPath stroke];

    // Bezier Drawing
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(20, 20)];
    [bezierPath addCurveToPoint:CGPointMake(60, 60) controlPoint1:CGPointMake(60, 60) controlPoint2:CGPointMake(60, 60)];
    [strokeColor setStroke];
    bezierPath.lineWidth = lineWidth + 2;
    [bezierPath stroke];
    [color setStroke];
    bezierPath.lineWidth = lineWidth;
    [bezierPath stroke];

    // Bezier 2 Drawing
    UIBezierPath *bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint:CGPointMake(20, 60)];
    [bezier2Path addCurveToPoint:CGPointMake(60, 20) controlPoint1:CGPointMake(54.44, 25.56) controlPoint2:CGPointMake(60, 20)];
    [strokeColor setStroke];
    bezier2Path.lineWidth = lineWidth + 2;
    [bezier2Path stroke];
    [color setStroke];
    bezier2Path.lineWidth = lineWidth;
    [bezier2Path stroke];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

