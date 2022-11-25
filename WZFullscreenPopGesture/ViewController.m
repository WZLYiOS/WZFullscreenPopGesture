//
//  ViewController.m
//  WZFullscreenPopGesture
//
//  Created by xiaobin liu on 2019/6/24.
//  Copyright © 2019 xiaobin liu. All rights reserved.
//

#import "ViewController.h"
#import "Demo0ViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "Demo3ViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = NSStringFromClass([self class]);
    self.view.backgroundColor = UIColor.orangeColor;
    [self addUITapGestureRecognizer];
    
    UIButton *bbbb = [[UIButton alloc] init];
    bbbb.frame = CGRectMake(0, 0, 100, 30);
    bbbb.backgroundColor = UIColor.blackColor;
    [bbbb addTarget:self action:@selector(bbbbtapAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:bbbb];
}

- (void)addUITapGestureRecognizer{
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)]];
}

- (void)tapAction{
//    Demo0ViewController *vc = [Demo0ViewController new];
//    [self.navigationController pushViewController:vc animated:YES];
    Demo3ViewController *vc = [Demo3ViewController new];
    [self.navigationController pushViewController:vc animated:YES];
//    [self.navigationController setViewControllers:@[vc] animated:true];
}

- (void)bbbbtapAction{
    
}


@end
