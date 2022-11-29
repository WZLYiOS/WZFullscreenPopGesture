// The MIT License (MIT)
//
// Copyright (c) 2015-2016 forkingdog ( https://github.com/forkingdog )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import <UIKit/UIKit.h>

@class FDNavigationBar;

/// "UINavigation+FDFullscreenPopGesture" extends UINavigationController's swipe-
/// to-pop behavior in iOS 7+ by supporting fullscreen pan gesture. Instead of
/// screen edge, you can now swipe from any place on the screen and the onboard
/// interactive pop transition works seamlessly.
///
/// Adding the implementation file of this category to your target will
/// automatically patch UINavigationController with this feature.
@interface UINavigationController (FDFullscreenPopGesture)

/// The gesture recognizer that actually handles interactive pop.
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *fd_fullscreenPopGestureRecognizer;

/// A view controller is able to control navigation bar's appearance by itself,
/// rather than a global way, checking "fd_prefersNavigationBarHidden" property.
/// Default to YES, disable it if you don't want so.
@property (nonatomic, assign) BOOL fd_viewControllerBasedNavigationBarAppearanceEnabled;

/// 是否开启fd功能，默认NO
@property (nonatomic, assign) BOOL fd_open;

// 默认返回按钮: image/UIView
@property (strong,nonatomic) UIImage *fd_backItem;

@end

/// Allows any view controller to disable interactive pop gesture, which might
/// be necessary when the view controller itself handles pan gesture in some
/// cases.
@interface UIViewController (FDFullscreenPopGesture)

/// Whether the interactive pop gesture is disabled when contained in a navigation
/// stack.
@property (nonatomic, assign) BOOL fd_interactivePopDisabled;

/// Indicate this view controller prefers its navigation bar hidden or not,
/// checked when view controller based navigation bar's appearance is enabled.
/// Default to NO, bars are more likely to show.
@property (nonatomic, assign) BOOL fd_prefersNavigationBarHidden;

/// Max allowed initial distance to left edge when you begin the interactive pop
/// gesture. 0 by default, which means it will ignore this limit.
@property (nonatomic, assign) CGFloat fd_interactivePopMaxAllowedInitialDistanceToLeftEdge;

/// 自定义NavigationBar
@property (strong,nonatomic,readonly) FDNavigationBar *fd_customNavigationBar;

/// 是否显示返回按钮
@property (nonatomic, assign) BOOL fd_HiddenBackNavigationBarItem;

@end

// MARK - 自定义导航栏
@interface FDNavigationBar : UINavigationBar

@property (strong, nonatomic) UINavigationItem *navigationItem;

- (instancetype)initWithController: (UIViewController*)contoller;


@end

/// MARK - 颜色装换图片
@interface UIImage (FDFullscreenPopGesture)

+ (UIImage *)fd_imageWithColor:(UIColor *)color andSize:(CGSize)size;

@end

/// MARK - 扩展字体
@interface UINavigationBar (FDFullscreenPopGesture)

@property (strong,nonatomic) UIColor *fd_titleColor;
@property (strong,nonatomic) UIFont *fd_titleFont;
@property (assign, nonatomic) CGFloat fd_backGroundViewAlpha;

@end