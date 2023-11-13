//
//  Demo3ViewController.m
//  WZFullscreenPopGesture
//
//  Created by 牛胖胖 on 2019/12/4.
//  Copyright © 2019 xiaobin liu. All rights reserved.
//

#import "Demo3ViewController.h"
#import "Demo0ViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "Demo1ViewController.h"
@interface Demo3ViewController ()

@end

@implementation Demo3ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = NSStringFromClass([self class]);
    self.view.backgroundColor = UIColor.whiteColor;

    self.fd_prefersNavigationBarHidden = FDNavigationHiddenTypeHidden;
    self.fd_customBar.backgroundColor = UIColor.redColor;
    [self addUITapGestureRecognizer];
    UIView *xxxx = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    xxxx.backgroundColor = [UIColor redColor];
    [self.view addSubview:xxxx];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
}

//- (UIStatusBarStyle)preferredStatusBarStyle {
//    return [self.fd_customNavigationBar getStatusBarStyle];
//}

- (void)addUITapGestureRecognizer{
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)]];
}

- (void)tapAction{
//    self.fd_customNavigationBar.barTintColor = UIColor.redColor;
//    self.fd_customNavigationBar.barStyle = UIBarStyleDefault;
    Demo0ViewController *vc = [Demo0ViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)leftBtnAction{
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - xx
- (void)xxxxxAction{
    [self tapAction];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
