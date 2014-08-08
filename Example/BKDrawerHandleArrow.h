// Copyright 2014-present 650 Industries. All rights reserved.

typedef NS_ENUM(NSUInteger, BKDrawerHandleArrowDirection) {
    BKDrawerHandleArrowDirectionNeutral,
    BKDrawerHandleArrowDirectionUp,
    BKDrawerHandleArrowDirectionDown,
};

@interface BKDrawerHandleArrow : NSObject

@property (nonatomic) BKDrawerHandleArrowDirection direction;
@property (strong, nonatomic, readonly) CAShapeLayer *layer;

- (void)setDirection:(BKDrawerHandleArrowDirection)direction animated:(BOOL)animated;

@end
