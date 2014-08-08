// Copyright 2014-present 650 Industries. All rights reserved.

struct BKCameraRollSpecs {
    const UIEdgeInsets buttonHitSlop;
    const CGSize buttonSize;
    const UIEdgeInsets leftButtonAreaInsets;
    const UIEdgeInsets rightButtonAreaInsets;

    const CGFloat closedDrawerHeight;
    const CGFloat drawerHandleHeight;
    const CGFloat topFloorInset;
    const CGFloat bottomFloorInset;
    const CGFloat floorUndersizeMargin;

    const CGFloat drawerViewCornerRadius;
    const CGSize drawerHandleShadowOffset;
    const CGFloat drawerHandleShadowOpacity;
    const CGFloat drawerHandleShadowRadius;

    const NSUInteger cellsPerRow;
    const CGFloat rowScrollBias;
    const CGFloat drawerSpringBounciness;
    const CGFloat drawerSpringSpeedNormal;
    const CGFloat drawerSpringSpeedFast;
};

const struct BKCameraRollSpecs BKCameraRollSpecs;

@interface BKCameraRollViewController : UIViewController

@end
