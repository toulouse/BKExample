// Copyright (c) 2014-present 650 Industries, Inc. All rights reserved.

#import "BKHitSlopDemoViewController.h"

#import <BKHitSlop/BKHitSlop.h>
#import <pop/POP.h>

#import "UIButton+Bouncy.h"

@interface BKHitSlopDemoViewController ()

@end

@implementation BKHitSlopDemoViewController {
    UIColor *_slopEnabledAidColor;
    UIColor *_slopDisabledAidColor;

    UILabel *_toggleLabel;
    UIView *_hitSlopVisualAid;
    UIButton *_actualButton;

    BOOL _on;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _on = YES;

    self.view.backgroundColor = [UIColor whiteColor];
    _slopEnabledAidColor = [UIColor colorWithRed:0.3 green:0.6 blue:0.9 alpha:1.0];
    _slopDisabledAidColor = [UIColor colorWithRed:0.3 green:0.6 blue:0.9 alpha:0.5];

    _toggleLabel = [[UILabel alloc] init];
    _toggleLabel.textAlignment = NSTextAlignmentCenter;
    _toggleLabel.text = @"Hit Slop Enabled";
    [self.view addSubview:_toggleLabel];

    _hitSlopVisualAid = [[UIView alloc] init];
    _hitSlopVisualAid.backgroundColor = _slopEnabledAidColor;
    [self.view addSubview:_hitSlopVisualAid];

    _actualButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _actualButton.bk_hitSlop = UIEdgeInsetsMake(-50, -50, -50, -50);
    _actualButton.bouncy = YES;
    _actualButton.backgroundColor = [UIColor colorWithRed:0.9 green:0.6 blue:0.3 alpha:1.0];
    [_actualButton addTarget:self action:@selector(_toggled:) forControlEvents:UIControlEventTouchUpInside];
   [self.view addSubview:_actualButton];
}

- (void)viewWillLayoutSubviews
{
    _hitSlopVisualAid.bounds = CGRectMake(0, 0, 200, 200);
    _hitSlopVisualAid.center = self.view.center;

    _actualButton.bounds = CGRectMake(0, 0, 100, 100);
    _actualButton.center = self.view.center;

    [_toggleLabel sizeToFit];
    _toggleLabel.center = CGPointMake(_hitSlopVisualAid.center.x, _hitSlopVisualAid.center.y - (CGRectGetHeight(_hitSlopVisualAid.bounds) / 2.0 + CGRectGetHeight(_toggleLabel.bounds) / 2.0) - 10.0);
}

- (void)_toggled:(id)sender
{
    if (!_on) {
        _on = YES;
        _toggleLabel.text = @"Hit Slop Enabled";
        _actualButton.bk_hitSlop = UIEdgeInsetsMake(-50, -50, -50, -50);

        POPSpringAnimation *bgSpring = [POPSpringAnimation animationWithPropertyNamed:kPOPViewBackgroundColor];
        bgSpring.toValue = _slopEnabledAidColor;
        [_hitSlopVisualAid pop_addAnimation:bgSpring forKey:@"toggle"];
    } else {
        _on = NO;
        _toggleLabel.text = @"Hit Slop Disabled";
        _actualButton.bk_hitSlop = UIEdgeInsetsZero;

        POPSpringAnimation *bgSpring = [POPSpringAnimation animationWithPropertyNamed:kPOPViewBackgroundColor];
        bgSpring.toValue = _slopDisabledAidColor;
        [_hitSlopVisualAid pop_addAnimation:bgSpring forKey:@"toggle"];
    }
}

@end
