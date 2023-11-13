//
//  FDNavigationViewController.m
//  WZFullscreenPopGesture
//
//  Created by 牛胖胖 on 2019/12/4.
//  Copyright © 2019 xiaobin liu. All rights reserved.
//

#import "FDNavigationViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
@interface FDNavigationViewController ()

@end

@implementation FDNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    /// 解决ios13 后导航栏透明
    if(@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithTransparentBackground];
        appearance.backgroundColor= UIColor.whiteColor;
        appearance.shadowImage = [UIImage new];
        appearance.shadowColor = UIColor.clearColor;
        self.navigationBar.standardAppearance = appearance;
        self.navigationBar.scrollEdgeAppearance = appearance;
     }
    
//    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"button"] forBarMetrics:0];
    
    //    [UINavigationBar appearance].shadowImage = [UIImage new];
//        [[UINavigationBar appearance] setBackgroundImage: [self imageWithColor:UIColor.blueColor andSize:CGSizeMake(1, 1)] forBarMetrics:0];
        self.navigationBar.barTintColor = UIColor.grayColor;
    //    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColor.blueColor,
    //    NSFontAttributeName:[UIFont boldSystemFontOfSize:17.0f]}];
//        [UINavigationBar appearance].translucent = false;
    
    self.fd_open = true;
    self.fd_backItem = [UIImage imageNamed:@"navBack"];
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

@end
