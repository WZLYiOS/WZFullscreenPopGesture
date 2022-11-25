//
//  AppDelegate.m
//  WZFullscreenPopGesture
//
//  Created by xiaobin liu on 2019/6/24.
//  Copyright © 2019 xiaobin liu. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "FDNavigationViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = UIColor.whiteColor;
    
    
    
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [UINavigationBar appearance].shadowImage = [UIImage new];
    [[UINavigationBar appearance] setBackgroundImage: [self imageWithColor:UIColor.orangeColor andSize:CGSizeMake(1, 1)] forBarMetrics:0];
    [UINavigationBar appearance].barTintColor = UIColor.whiteColor;
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColor.blueColor,
    NSFontAttributeName:[UIFont boldSystemFontOfSize:17.0f]}];
    [UINavigationBar appearance].translucent = false;
    
//    /// 解决ios13 后导航栏透明
    if(@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
//        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UINavigationBar appearance].barTintColor;
        appearance.titleTextAttributes = [UINavigationBar appearance].titleTextAttributes;
        appearance.shadowColor = UIColor.clearColor;
        appearance.shadowImage = [UIImage new];
        [[UINavigationBar appearance] setStandardAppearance:appearance];
        [[UINavigationBar appearance] setScrollEdgeAppearance:appearance];
     }
    
    
    FDNavigationViewController *navi = [[FDNavigationViewController alloc] initWithRootViewController:[ViewController new]];
       navi.modalPresentationStyle = UIModalPresentationFullScreen;
    self.window.rootViewController = navi;
    
    
    
    return YES;
}

- (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
