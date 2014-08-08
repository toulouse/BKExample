// Copyright (c) 2014-present 650 Industries, Inc. All rights reserved.

@interface UIButton (Bouncy)

@property (nonatomic, assign, getter=isBouncy) BOOL bouncy;
@property (nonatomic, assign) CGPoint bounceScale;

+ (CGPoint)defaultBounceScale;
+ (void)setDefaultBounceScale:(CGPoint)bounceScale;

@end
