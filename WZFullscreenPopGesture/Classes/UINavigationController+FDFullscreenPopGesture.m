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
    
    CGFloat multiplier = [UIView appearance].semanticContentAttribute == UISemanticContentAttributeForceRightToLeft ? -1 : 1;
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
        Method viewWillAppear_originalMethod = class_getInstanceMethod(self, @selector(viewWillAppear:));
        Method viewWillAppear_swizzledMethod = class_getInstanceMethod(self, @selector(fd_viewWillAppear:));
        method_exchangeImplementations(viewWillAppear_originalMethod, viewWillAppear_swizzledMethod);
    
        Method viewWillDisappear_originalMethod = class_getInstanceMethod(self, @selector(viewWillDisappear:));
        Method viewWillDisappear_swizzledMethod = class_getInstanceMethod(self, @selector(fd_viewWillDisappear:));
        method_exchangeImplementations(viewWillDisappear_originalMethod, viewWillDisappear_swizzledMethod);
        
        
        Method viewDidLoad_originalMethod = class_getInstanceMethod(self, @selector(viewDidLoad));
        Method viewDidLoad_swizzledMethod = class_getInstanceMethod(self, @selector(fd_viewDidLoad));
        method_exchangeImplementations(viewDidLoad_originalMethod, viewDidLoad_swizzledMethod);
        
        Method viewDidLayout_originalMethod = class_getInstanceMethod(self, @selector(viewDidLayoutSubviews));
        Method viewDidLayout_swizzledMethod = class_getInstanceMethod(self, @selector(fd_viewDidLayoutSubviews));
        method_exchangeImplementations(viewDidLayout_originalMethod, viewDidLayout_swizzledMethod);
        
    });
}

- (void)fd_viewWillAppear:(BOOL)animated
{
    // Forward to primary implementation.
    [self fd_viewWillAppear:animated];
    
    if (![self isNavigationBarEnabled]) {
        return;
    }
    
    if (self.fd_willAppearInjectBlock) {
        self.fd_willAppearInjectBlock(self, animated);
    }
}

- (void)fd_viewWillDisappear:(BOOL)animated
{
    // Forward to primary implementation.
    [self fd_viewWillDisappear:animated];
    
    if (![self isNavigationBarEnabled]) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIViewController *viewController = self.navigationController.viewControllers.lastObject;
        if (viewController && !viewController.isPrefersNavigationBarHidden && self.isPrefersNavigationBarHidden) {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
        }
    });
}

/// 是否开放导航栏
- (BOOL)isNavigationBarEnabled {
    if (self.navigationController == nil) {
        return false;
    }
    if (!self.navigationController.fd_open) {
        return false;
    }
    if (![self.navigationController.viewControllers containsObject: self]) {
        return false;
    };
    return true;
}

- (void)fd_viewDidLoad{
    [self fd_viewDidLoad];
    if ([self isNavigationBarEnabled]) {
        [self setBackNavigationItem];
    }
}

- (void)fd_viewDidLayoutSubviews {
    [self fd_viewDidLayoutSubviews];
    if (self.fd_prefersNavigationBarHidden == FDNavigationHiddenTypeCustom && self.fd_customBar) {
        [self.view bringSubviewToFront: self.fd_customBar];
    }
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
    if (self.navigationController.viewControllers.count > 1) {
        UIImage *img = self.navigationController.fd_backItem;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(leftBtnAction)];
    }
}

#pragma mark - 返回
- (void)leftBtnAction {
    [self.navigationController popViewControllerAnimated: YES];
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
        if (strongSelf && viewController.isPrefersNavigationBarHidden) {
            [strongSelf setNavigationBarHidden:viewController.isPrefersNavigationBarHidden animated:animated];
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

- (id)fd_backItem {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setFd_backItem:(id)backItem{
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

// 是否显示导航栏
- (BOOL)isPrefersNavigationBarHidden {
    if (self.fd_prefersNavigationBarHidden == FDNavigationHiddenTypeNomar) {
        return false;
    }
    return true;
}

- (FDNavigationHiddenType)fd_prefersNavigationBarHidden
{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setFd_prefersNavigationBarHidden:(FDNavigationHiddenType)fd_prefersNavigationBarHidden {
    objc_setAssociatedObject(self, @selector(fd_prefersNavigationBarHidden), @(fd_prefersNavigationBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (fd_prefersNavigationBarHidden == FDNavigationHiddenTypeCustom) {
        self.fd_customBar = [[FDNavigationBar alloc] initWithController: self];
    }
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

- (FDNavigationBar *)fd_customBar {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setFd_customBar:(FDNavigationBar *)fd_customBar {
    SEL key = @selector(fd_customBar);
    objc_setAssociatedObject(self, key, fd_customBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIStatusBarStyle)fd_statusBarStyle {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setFd_statusBarStyle:(UIStatusBarStyle)fd_statusBarStyle {
    objc_setAssociatedObject(self, @selector(fd_statusBarStyle), @(fd_statusBarStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsStatusBarAppearanceUpdate];
}

@end


@implementation UIScrollView (FDFullscreenPopGesture)

- (BOOL)fd_scrollViewPopGestureRecognizerEnable {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setFd_scrollViewPopGestureRecognizerEnable:(BOOL)fd_scrollViewPopGestureRecognizerEnable {
    objc_setAssociatedObject(self, @selector(fd_scrollViewPopGestureRecognizerEnable), @(fd_scrollViewPopGestureRecognizerEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (self.contentOffset.x <= 0 && self.fd_scrollViewPopGestureRecognizerEnable) {
        if ([otherGestureRecognizer.delegate isKindOfClass:NSClassFromString(@"_FDFullscreenPopGestureRecognizerDelegate")]) {
            return YES;
        }
    }
    return NO;
}

@end
