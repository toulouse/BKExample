// Copyright (c) 2014-present 650 Industries, Inc. All rights reserved.

typedef NS_ENUM(NSUInteger, BKCameraRollDrawerPosition) {
    BKCameraRollDrawerPositionHidden,
    BKCameraRollDrawerPositionClosed,
    BKCameraRollDrawerPositionOpened,
};

@class BKCameraRollButtonSpec;

@interface BKCameraRollViewSpec : NSObject

// INPUT
/**
 * @abstract Returns the logical drawer position.
 * @discussion The drawer position is a logical value reflecting the logical state of the drawer's destination point.
 * It's important to note that the positioning of the actual drawer is *NOT* managed by this value, on account of the
 * interactivity of the interface. The view controller is responsible for setting the drawerOffset for the desired 
 * position in accordance with its own interactive state.
 * @return The logical drawer position.
 */
@property (nonatomic, assign) BKCameraRollDrawerPosition drawerPosition;
@property (nonatomic, assign) CGRect bounds;
@property (nonatomic, assign) CGFloat drawerOffset;
@property (nonatomic, assign) UIEdgeInsets floorContentInset;

// OUTPUT
@property (nonatomic, assign) BKCameraRollDrawerPosition previousDrawerPosition; // Drawer position before camera experience was entered

@property (nonatomic, assign, readonly) CGRect floorContentFrame;
@property (nonatomic, assign, readonly) CGRect drawerFrame;
@property (nonatomic, assign, readonly) UIEdgeInsets drawerInsets;

@property (nonatomic, strong, readonly) BKCameraRollButtonSpec *acceptSpec;

// How far into the hidden state we are
@property (nonatomic, assign, readonly) CGFloat percentHiddenState;

- (CGFloat)drawerOffsetForDrawerPosition:(BKCameraRollDrawerPosition)position;
- (UIEdgeInsets)floorContentInsetForDrawerPosition:(BKCameraRollDrawerPosition)position;

- (void)layout;

@end

@interface BKCameraRollButtonSpec : NSObject

@property (nonatomic, assign, readonly) CGRect bounds;
@property (nonatomic, assign, readonly) CGPoint center;
@property (nonatomic, assign, readonly) CGFloat alpha;

@end