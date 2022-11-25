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
    self.fd_backItem = [UIImage imageNamed:@"navBack"];
    self.fd_open = YES;
    
//    /// 解决ios13 后导航栏透明
//    if(@available(iOS 13.0, *)) {
//        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
//        [appearance configureWithTransparentBackground];
//        appearance.backgroundColor= UIColor.whiteColor;
//        appearance.shadowImage = [UIImage new];
//        appearance.shadowColor = UIColor.clearColor;
//        self.navigationBar.standardAppearance = appearance;
//        self.navigationBar.scrollEdgeAppearance = appearance;
//     }
}


@end
