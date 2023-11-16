//
//  FDNavigationBar.h
//  Created on 2023/11/13
//  Description <#文件描述#>
//  PD <#产品文档地址#>
//  Design <#设计文档地址#>
//  Copyright © 2023 WZLY. All rights reserved.
//  @author 邱啟祥(739140860@qq.com)   
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// MARK - 自定义导航栏样式
@interface FDNavigationBar : UINavigationBar

@property (nonatomic, strong) UINavigationItem *item;

- (instancetype) initWithController:(UIViewController *)controller;



@end

NS_ASSUME_NONNULL_END
