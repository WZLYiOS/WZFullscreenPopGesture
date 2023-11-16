//
//  FDNavigationBar.m
//  Created on 2023/11/13
//  Description <#文件描述#>
//  PD <#产品文档地址#>
//  Design <#设计文档地址#>
//  Copyright © 2023 WZLY. All rights reserved.
//  @author 邱啟祥(739140860@qq.com)   
//

#import "FDNavigationBar.h"
#import "UINavigationController+FDFullscreenPopGesture.h"

@interface FDNavigationBar ()

@property (nonatomic, strong) UIViewController *controller;

@end

@implementation FDNavigationBar

- (instancetype) initWithController:(UIViewController *)controller {
    if (self = [super init]) {
        self.controller = controller;
        self.item = [[UINavigationItem alloc] initWithTitle: self.controller.navigationItem.title];
        self.item.prompt = self.controller.navigationItem.prompt;
        [self pushNavigationItem:self.item animated:false];
        CGRect frame = controller.navigationController.navigationBar.frame;
        self.frame = CGRectMake(0, [self barMinY], frame.size.width, frame.size.height);
        [self setBackItem];
        [controller.view addSubview: self];
    }
    return self;
}

-(UIWindow *)mainWindow{
    id appDelegate = [UIApplication sharedApplication].delegate;
    if (appDelegate && [appDelegate respondsToSelector:@selector(window)]) {
        return [appDelegate window];
    }
    
    NSArray *windows = [UIApplication sharedApplication].windows;
    if ([windows count] == 1) {
        return [windows firstObject];
    }
    else {
        for (UIWindow *window in windows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                return window;
            }
        }
    }
    return nil;
}

- (CGFloat)barMinY{
    UIWindow *windwo = [self mainWindow];
    return CGRectGetMaxY(windwo.windowScene.statusBarManager.statusBarFrame);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIView *background = self.subviews.firstObject;
    CGFloat barMinY = [self barMinY];
    background.frame = CGRectMake(0, -barMinY, self.bounds.size.width, self.bounds.size.height + barMinY);
}

/// 设置返回按钮
- (void)setBackItem {
    
    if (self.controller.navigationController.viewControllers.count <= 1) { return; }
    if (self.controller.navigationController.fd_backItem == nil) {
        return; }
    UIImage *img = self.controller.navigationController.fd_backItem;
    self.item.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(leftBtnAction)];
}

#pragma mark - 返回
- (void)leftBtnAction {
    [self.controller.navigationController popViewControllerAnimated: YES];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor: backgroundColor];
    if (@available(iOS 15.0, *)) {
        self.standardAppearance.backgroundColor = backgroundColor;
        self.scrollEdgeAppearance.backgroundColor = backgroundColor;
    }
}

- (void)setBackgroundImage:(UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics {
    [super setBackgroundImage: backgroundImage forBarMetrics: barMetrics];
    if (@available(iOS 15.0, *)) {
        self.standardAppearance.backgroundImage = backgroundImage;
        self.scrollEdgeAppearance.backgroundImage = backgroundImage;
    }
}

@end
