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

#import <objc/runtime.h>
#import "UINavigationController+FDFullscreenPopGesture.h"

void FDFullscreenPopGestureSwizzleMethod(Class originalCls, SEL originalSelector, Class swizzledCls, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(originalCls, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(swizzledCls, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(originalCls,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(originalCls,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@interface _FDFullscreenPopGestureRecognizerDelegate : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;

@end

@implementation _FDFullscreenPopGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    // Ignore when no view controller is pushed into the navigation stack.
    if (self.navigationController.viewControllers.count <= 1) {
        return NO;
    }
    
    // Ignore when the active view controller doesn't allow interactive pop.
    UIViewController *topViewController = self.navigationController.viewControllers.lastObject;
    if (topViewController.fd_interactivePopDisabled) {
        return NO;
    }
    
    // Ignore when the beginning location is beyond max allowed initial distance to left edge.
    CGPoint beginningLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
    CGFloat maxAllowedInitialDistance = topViewController.fd_interactivePopMaxAllowedInitialDistanceToLeftEdge;
    if (maxAllowedInitialDistance > 0 && beginningLocation.x > maxAllowedInitialDistance) {
        return NO;
    }

    // Ignore pan gesture when the navigation controller is currently in transition.
    if ([[self.navigationController valueForKey:@"_isTransitioning"] boolValue]) {
        return NO;
    }
    
    // Prevent calling the handler when the gesture begins in an opposite direction.
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    BOOL isLeftToRight = [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionLeftToRight;
    CGFloat multiplier = isLeftToRight ? 1 : - 1;
    if ((translation.x * multiplier) <= 0) {
        return NO;
    }
    
    return YES;
}

@end

typedef void (^_FDViewControllerWillAppearInjectBlock)(UIViewController *viewController, BOOL animated);

@interface UIViewController (FDFullscreenPopGesturePrivate)

@property (nonatomic, copy) _FDViewControllerWillAppearInjectBlock fd_willAppearInjectBlock;

@end

@implementation UIViewController (FDFullscreenPopGesturePrivate)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FDFullscreenPopGestureSwizzleMethod(self, @selector(viewWillAppear:), self, @selector(fd_viewWillAppear:));
        FDFullscreenPopGestureSwizzleMethod(self, @selector(viewWillDisappear:), self, @selector(fd_viewWillDisappear:));
        FDFullscreenPopGestureSwizzleMethod(self, @selector(viewDidLoad), self, @selector(fd_viewDidLoad));
//        FDFullscreenPopGestureSwizzleMethod(self, @selector(viewWillLayoutSubviews), self, @selector(fd_viewDidLayoutSubviews));
    });
}

- (void)fd_viewWillAppear:(BOOL)animated
{
    // Forward to primary implementation.
    [self fd_viewWillAppear:animated];
    
    if (self.fd_willAppearInjectBlock) {
        self.fd_willAppearInjectBlock(self, animated);
    }
}

- (void)fd_viewWillDisappear:(BOOL)animated
{
    // Forward to primary implementation.
    [self fd_viewWillDisappear:animated];
    if (self.navigationController.fd_open == false) { return; }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIViewController *viewController = self.navigationController.viewControllers.lastObject;
        if (viewController && !viewController.fd_prefersNavigationBarHidden && viewController.navigationController.fd_open) {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
        }
    });
}

- (void)fd_viewDidLoad{
    [self fd_viewDidLoad];
    if (self.navigationController.fd_open == false) { return; }
    [self setBackNavigationItem];
}

- (void)fd_viewDidLayoutSubviews {
    [self fd_viewDidLayoutSubviews];
    /// 更新背景图片
    if (self.navigationController.fd_open == false) { return; }
}

- (_FDViewControllerWillAppearInjectBlock)fd_willAppearInjectBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setFd_willAppearInjectBlock:(_FDViewControllerWillAppearInjectBlock)block
{
    objc_setAssociatedObject(self, @selector(fd_willAppearInjectBlock), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


/// 设置导航栏默认返回样式
- (void)setBackNavigationItem{
    
    /// 设置导航栏默认返回样式
    if (self.navigationController.viewControllers.count>1 && !self.fd_HiddenBackNavigationBarItem && self.navigationController.fd_backItem) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[self.navigationController.fd_backItem imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(leftBtnAction)];
    }else{
        if (self.fd_HiddenBackNavigationBarItem) {
            self.navigationItem.leftBarButtonItem = [UIBarButtonItem new];
        }
    }
}

#pragma mark - 返回
- (void)leftBtnAction {
    [self.navigationController popViewControllerAnimated:YES];
}


@end

@implementation UINavigationController (FDFullscreenPopGesture)

+ (void)load
{
    // Inject "-pushViewController:animated:"
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FDFullscreenPopGestureSwizzleMethod(self, @selector(pushViewController:animated:), self, @selector(fd_pushViewController:animated:));
        FDFullscreenPopGestureSwizzleMethod(self, @selector(setViewControllers:animated:), self, @selector(fd_setViewControllers:animated:));
    });
}

- (void)fd_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.fd_fullscreenPopGestureRecognizer]) {
        
        // Add our own gesture recognizer to where the onboard screen edge pan gesture recognizer is attached to.
        [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.fd_fullscreenPopGestureRecognizer];
        
        // Forward the gesture events to the private handler of the onboard gesture recognizer.
        NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
        id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
        SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
        self.fd_fullscreenPopGestureRecognizer.delegate = self.fd_popGestureRecognizerDelegate;
        [self.fd_fullscreenPopGestureRecognizer addTarget:internalTarget action:internalAction];
        
        // Disable the onboard gesture recognizer.
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    // Handle perferred navigation bar appearance.
    [self fd_setupViewControllerBasedNavigationBarAppearanceIfNeeded:viewController];
    
    // Forward to primary implementation.
    if (![self.viewControllers containsObject:viewController]) {
        [self fd_pushViewController:viewController animated:animated];
    }
}

- (void)fd_setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated
{
    [self fd_addFullscreenPopGestureRecognizer];
    
    // Handle perferred navigation bar appearance.
    for (UIViewController *viewController in viewControllers) {
        [self fd_setupViewControllerBasedNavigationBarAppearanceIfNeeded:viewController];
    }
    if (viewControllers.count <= 1) {
        viewControllers.lastObject.fd_HiddenBackNavigationBarItem = true;
    }
    [self fd_setViewControllers:viewControllers animated:animated];
}

- (void)fd_addFullscreenPopGestureRecognizer
{
    if (![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.fd_fullscreenPopGestureRecognizer]) {
        
        // Add our own gesture recognizer to where the onboard screen edge pan gesture recognizer is attached to.
        [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.fd_fullscreenPopGestureRecognizer];
        
        // Forward the gesture events to the private handler of the onboard gesture recognizer.
        NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
        id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
        SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
        self.fd_fullscreenPopGestureRecognizer.delegate = self.fd_popGestureRecognizerDelegate;
        [self.fd_fullscreenPopGestureRecognizer addTarget:internalTarget action:internalAction];
        
        // Disable the onboard gesture recognizer.
        self.interactivePopGestureRecognizer.enabled = NO;
    }
}


- (void)fd_setupViewControllerBasedNavigationBarAppearanceIfNeeded:(UIViewController *)appearingViewController
{
    if (!self.fd_viewControllerBasedNavigationBarAppearanceEnabled) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    _FDViewControllerWillAppearInjectBlock block = ^(UIViewController *viewController, BOOL animated) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && viewController.navigationController.fd_open) {
            [strongSelf setNavigationBarHidden:viewController.fd_prefersNavigationBarHidden animated:animated];
        }
    };
    
    // Setup will appear inject block to appearing view controller.
    // Setup disappearing view controller as well, because not every view controller is added into
    // stack by pushing, maybe by "-setViewControllers:".
    appearingViewController.fd_willAppearInjectBlock = block;
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    if (disappearingViewController && !disappearingViewController.fd_willAppearInjectBlock) {
        disappearingViewController.fd_willAppearInjectBlock = block;
    }
}

- (_FDFullscreenPopGestureRecognizerDelegate *)fd_popGestureRecognizerDelegate
{
    _FDFullscreenPopGestureRecognizerDelegate *delegate = objc_getAssociatedObject(self, _cmd);
    
    if (!delegate) {
        delegate = [[_FDFullscreenPopGestureRecognizerDelegate alloc] init];
        delegate.navigationController = self;
        
        objc_setAssociatedObject(self, _cmd, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return delegate;
}

- (UIPanGestureRecognizer *)fd_fullscreenPopGestureRecognizer
{
    UIPanGestureRecognizer *panGestureRecognizer = objc_getAssociatedObject(self, _cmd);
    
    if (!panGestureRecognizer) {
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
        panGestureRecognizer.maximumNumberOfTouches = 1;
        
        objc_setAssociatedObject(self, _cmd, panGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return panGestureRecognizer;
}

- (BOOL)fd_viewControllerBasedNavigationBarAppearanceEnabled
{
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) {
        return number.boolValue;
    }
    self.fd_viewControllerBasedNavigationBarAppearanceEnabled = YES;
    return YES;
}

- (void)setFd_viewControllerBasedNavigationBarAppearanceEnabled:(BOOL)enabled
{
    SEL key = @selector(fd_viewControllerBasedNavigationBarAppearanceEnabled);
    objc_setAssociatedObject(self, key, @(enabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)fd_open{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setFd_open:(BOOL)open {
    SEL key = @selector(fd_open);
    objc_setAssociatedObject(self, key, @(open), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)fd_backItem {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setFd_backItem:(UIImage *)backItem{
    SEL key = @selector(fd_backItem);
    objc_setAssociatedObject(self, key, backItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UIViewController (FDFullscreenPopGesture)

- (BOOL)fd_interactivePopDisabled
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setFd_interactivePopDisabled:(BOOL)disabled
{
    objc_setAssociatedObject(self, @selector(fd_interactivePopDisabled), @(disabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)fd_prefersNavigationBarHidden
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setFd_prefersNavigationBarHidden:(BOOL)hidden
{
    objc_setAssociatedObject(self, @selector(fd_prefersNavigationBarHidden), @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (CGFloat)fd_interactivePopMaxAllowedInitialDistanceToLeftEdge
{
#if CGFLOAT_IS_DOUBLE
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
#else
    return [objc_getAssociatedObject(self, _cmd) floatValue];
#endif
}

- (void)setFd_interactivePopMaxAllowedInitialDistanceToLeftEdge:(CGFloat)distance
{
    SEL key = @selector(fd_interactivePopMaxAllowedInitialDistanceToLeftEdge);
    objc_setAssociatedObject(self, key, @(MAX(0, distance)), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FDNavigationBar *)fd_customNavigationBar {
    FDNavigationBar *bar = objc_getAssociatedObject(self, _cmd);
    if (bar == nil) {
        /// NavigationBar
        bar = [[FDNavigationBar alloc] initWithController: self];
        if (self.navigationController.viewControllers.count>1 && !self.fd_HiddenBackNavigationBarItem && self.navigationController.fd_backItem) {
            bar.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[self.navigationController.fd_backItem imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(leftBtnAction)];
        }
        [bar setHidden:true];
        objc_setAssociatedObject(self, _cmd, bar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }return bar;
}

- (BOOL)fd_HiddenBackNavigationBarItem {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setFd_HiddenBackNavigationBarItem:(BOOL)hidden {
    objc_setAssociatedObject(self, @selector(fd_HiddenBackNavigationBarItem), @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


/// MARK - 重写控制器方法，电池条颜色自定义 注意：不建议这么写
//- (UIStatusBarStyle)preferredStatusBarStyle {
//
//    if (self.navigationController.fd_open && self.fd_prefersNavigationBarHidden) {
//        return [self.fd_customNavigationBar getStatusBarStyle];
//    }
//    return [UIApplication sharedApplication].statusBarStyle;
//}

@end


/// MARK - 自定义导航栏
@interface FDNavigationBar()

/// 控制器
@property (strong, nonatomic) UIViewController *controller;

@end

@implementation FDNavigationBar

- (instancetype)initWithController:(UIViewController*)contoller {
    self = [super init];
    if (self) {
        self.controller = contoller;
        self.frame = CGRectMake(0, UIApplication.sharedApplication.statusBarFrame.size.height, contoller.navigationController.navigationBar.frame.size.width, contoller.navigationController.navigationBar.frame.size.height);
        [self.controller.view addSubview: self];
        self.fd_backGroundViewAlpha = 1;
        self.navigationItem = [[UINavigationItem alloc] init];
        self.navigationItem.title = contoller.navigationItem.title;
        self.navigationItem.prompt = contoller.navigationItem.prompt;
        self.navigationItem.titleView = contoller.navigationItem.titleView;
        [self setItems:@[self.navigationItem]];

        [self setBackgroundImage:[contoller.navigationController.navigationBar backgroundImageForBarMetrics:0] forBarMetrics:UIBarMetricsDefault];
        [self setShadowImage:contoller.navigationController.navigationBar.shadowImage];
        [self setTitleTextAttributes:contoller.navigationController.navigationBar.titleTextAttributes];
        [self setBarStyle:contoller.navigationController.navigationBar.barStyle];
        self.tintColor = contoller.navigationController.navigationBar.tintColor;
        self.barTintColor = contoller.navigationController.navigationBar.barTintColor;
        [self setTranslucent: true];
    }
    return self;
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (!hidden) {
        self.controller.fd_prefersNavigationBarHidden = true;
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self.controller.view bringSubviewToFront: self];
    
    UIView *bgView = [self backGroundView];
    bgView.alpha = self.fd_backGroundViewAlpha;
    CGRect frame = bgView.frame;
    if (frame.size.height == self.frame.size.height) {
        frame.size.height = UIApplication.sharedApplication.statusBarFrame.size.height+self.frame.size.height;
        frame.origin.y = -UIApplication.sharedApplication.statusBarFrame.size.height;
        bgView.frame = frame;
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor: backgroundColor];
    [self setupAppearance];
}

/// 颜色视图
- (UIView*)backGroundView {
    
    UIView *view = self.subviews.firstObject;
    for (UIView *obj in self.subviews) {
        if ([obj isKindOfClass:NSClassFromString(@"_UIBarBackground")]||[obj isKindOfClass:NSClassFromString(@"_UINavigationBarBackground")]) {
            view = obj;
        }
    }
    return view;
}

- (void)setBarTintColor:(UIColor *)barTintColor {
    [super setBarTintColor:barTintColor];
    
    if ([self backgroundImageForBarMetrics: UIBarMetricsDefault] != nil) {
        [self setBackgroundImage: [UIImage fd_imageWithColor: barTintColor andSize: CGSizeMake(self.frame.size.width, self.frame.size.height)] forBarMetrics:UIBarMetricsDefault];
    }
    self.backgroundColor = barTintColor;
    if(@available(iOS 13.0, *)) {
        self.backgroundColor = barTintColor;
    }
}

- (void)setShadowImage:(UIImage *)shadowImage {
    [super setShadowImage:shadowImage];
    [self setupAppearance];
}

- (void)setTitleTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)titleTextAttributes {
    [super setTitleTextAttributes: titleTextAttributes];
    [self setupAppearance];
}

/// 更新导航栏配置
- (void)setupAppearance {
    if(@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = self.backgroundColor;
        appearance.shadowImage = self.shadowImage;
        appearance.shadowColor = nil;
        appearance.titleTextAttributes = self.titleTextAttributes;
        self.standardAppearance = appearance;
        self.scrollEdgeAppearance = appearance;
    }
}

@end

///  颜色装换图片
@implementation UIImage (FDFullscreenPopGesture)

+ (UIImage *)fd_imageWithColor:(UIColor *)color andSize:(CGSize)size {
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

/// MARK : 导航栏控制器
@implementation UINavigationBar (FDFullscreenPopGesture)


- (UIColor *)fd_titleColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (UIFont *)fd_titleFont {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setFd_titleColor:(UIColor *)fd_titleColor {
    SEL key = @selector(fd_titleColor);
    objc_setAssociatedObject(self, key, fd_titleColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self uploadTitleTextAttributes];
}

- (void)setFd_titleFont:(UIFont *)fd_titleFont {
    SEL key = @selector(fd_titleFont);
    objc_setAssociatedObject(self, key, fd_titleFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self uploadTitleTextAttributes];
}

- (CGFloat)fd_backGroundViewAlpha {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setFd_backGroundViewAlpha:(CGFloat)fd_backGroundViewAlpha {
    SEL key = @selector(fd_backGroundViewAlpha);
    objc_setAssociatedObject(self, key, @(fd_backGroundViewAlpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self uploadTitleTextAttributes];
    if (self.subviews.firstObject != nil) {
        self.subviews.firstObject.alpha = fd_backGroundViewAlpha;
    }
}

/// 更新文字标题
- (void)uploadTitleTextAttributes{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.titleTextAttributes];
    if (self.fd_titleColor && self.fd_backGroundViewAlpha > 0) {
        [dic setValue:self.fd_titleColor forKey:NSForegroundColorAttributeName];
    }else if (self.fd_backGroundViewAlpha == 0) {
        [dic setValue:UIColor.clearColor forKey:NSForegroundColorAttributeName];
    }
    if (self.fd_titleFont) {
        [dic setValue:self.fd_titleFont forKey:NSFontAttributeName];
    }
    [self setTitleTextAttributes:dic];
}


@end
