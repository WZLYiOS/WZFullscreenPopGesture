//
//  Demo2ViewController.m
//  WZFullscreenPopGesture
//
//  Created by 牛胖胖 on 2019/12/4.
//  Copyright © 2019 xiaobin liu. All rights reserved.
//

#import "Demo2ViewController.h"
#import "Demo3ViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
@interface Demo2ViewController ()

@end

@implementation Demo2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = NSStringFromClass([self class]);
    self.view.backgroundColor = UIColor.blueColor;
    [self addUITapGestureRecognizer];
    
    UIView *xxxx = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    xxxx.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:xxxx];
}

- (void)addUITapGestureRecognizer{
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)]];
}

- (void)tapAction{
    Demo3ViewController *vc = [Demo3ViewController new];
//    [self.navigationController pushViewController:vc animated:YES];
    [self.navigationController setViewControllers:@[vc] animated:true];
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
