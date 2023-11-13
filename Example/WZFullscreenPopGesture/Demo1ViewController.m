//
//  Demo1ViewController.m
//  WZFullscreenPopGesture
//
//  Created by 牛胖胖 on 2019/12/4.
//  Copyright © 2019 xiaobin liu. All rights reserved.
//

#import "Demo1ViewController.h"
#import "Demo2ViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
@interface Demo1ViewController ()

@end

@implementation Demo1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = NSStringFromClass([self class]);
    self.view.backgroundColor = UIColor.whiteColor;
    self.fd_prefersNavigationBarHidden = 2;
    [self.fd_customBar setBackgroundImage: [self imageWithColor:UIColor.yellowColor andSize:CGSizeMake(1, 1)] forBarMetrics:0];
    [self addUITapGestureRecognizer];
    
    NSLog(@"aaaaaaaa");
    
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

- (void)addUITapGestureRecognizer{
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)]];
}

- (void)tapAction{
    Demo2ViewController *vc = [Demo2ViewController new];
    [self.navigationController pushViewController:vc animated:YES];
//    [self.navigationController setViewControllers:@[vc] animated:true];
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
