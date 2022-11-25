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
    
    [self addUITapGestureRecognizer];
    
    NSInteger count = self.navigationController.viewControllers.count;
    NSLog(@"aaaaaaaa");
    
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
