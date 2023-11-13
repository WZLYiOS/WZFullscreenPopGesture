//
//  Demo0ViewController.m
//  WZFullscreenPopGesture
//
//  Created by 牛胖胖 on 2019/12/4.
//  Copyright © 2019 xiaobin liu. All rights reserved.
//

#import "Demo0ViewController.h"
#import "Demo1ViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
@interface Demo0ViewController ()

@end

@implementation Demo0ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // D
    self.navigationItem.title = NSStringFromClass([self class]);
    self.view.backgroundColor = UIColor.orangeColor;

    self.fd_prefersNavigationBarHidden = FDNavigationHiddenTypeCustom;
    self.fd_customBar.backgroundColor = UIColor.blackColor;
    UIView *xxxx = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
//    xxxx.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:xxxx];
    [self addUITapGestureRecognizer];
}


 
- (void)addUITapGestureRecognizer{
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)]];
}

- (void)tapAction{
    Demo1ViewController *vc = [Demo1ViewController new];
    [self.navigationController pushViewController:vc animated:true];
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
