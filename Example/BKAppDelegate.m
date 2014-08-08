// Copyright (c) 2014-present 650 Industries, Inc. All rights reserved.

#import "BKAppDelegate.h"

#import <BKServiceController/BKServiceController.h>
#import <BKServiceController/BKServiceRegistrar.h>
#import <BKSlidingViewController/BKSlidingViewController.h>

#import "BKCameraRollViewController.h"
#import "BKHitSlopDemoViewController.h"

NSString * const BKRunMeImmediatelyServiceName = @"BKRunMeImmediatelyService";

@implementation BKAppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[BKServiceController sharedInstance] registerServicesImmediately:^(BKServiceController *controller, BKServiceRegistrar *registrar) {
        [registrar registerBlock:^{
            NSLog(@"This is run immediately. Here's the callstack for proof! %@", [NSThread callStackSymbols]);
        } forKey:BKRunMeImmediatelyServiceName];
    }];

    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    BKSlidingViewController *slidingController  = [[BKSlidingViewController alloc] init];

    UIViewController *vcRed = [[UIViewController alloc] init];
    vcRed.view.backgroundColor = [UIColor redColor];

    BKHitSlopDemoViewController *hitSlopVC = [[BKHitSlopDemoViewController alloc] init];
    BKCameraRollViewController *cameraRollVC = [[BKCameraRollViewController alloc] init];

    slidingController.viewControllers = @[vcRed, hitSlopVC, cameraRollVC];
    slidingController.selectedIndex = 1;

    self.window.rootViewController = slidingController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
