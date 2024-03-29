//
//  HYNavigationController.m
//  HYGEntire
//
//  Created by zaky on 11/11/2019.
//  Copyright © 2019 kunlun. All rights reserved.
//

#import "HYNavigationController.h"
#import "CNSkinManager.h"
#import <UIImage+JKColor.h>
#import "HYTabBarViewController.h"

@interface HYNavigationController ()<UIGestureRecognizerDelegate, UINavigationControllerDelegate>
@end

@implementation HYNavigationController

#pragma mark - VIEW LIFE

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.interactivePopGestureRecognizer.delegate = self;
    self.delegate = self;
    
//    [self setupAppearance];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupAppearance) name:CNSkinChangeNotification object:nil];
}

- (void)dealloc{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupAppearance {
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.navigationBar setShadowImage:[UIImage new]];
        
    self.navigationBar.translucent = NO;
    [self.navigationBar setBackgroundImage:[UIImage jk_imageWithColor:kHexColor(0x1A1A2C)] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName: [UIFont fontPFSB18]}];
    
}

#pragma mark - GESTURE

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return self.viewControllers.count > 1;
}

// 允许同时响应多个手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:
(UIGestureRecognizer *)otherGestureRecognizer {
   return YES;
}

//禁止响应手势的是否ViewController中scrollView跟着滚动
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:
(UIGestureRecognizer *)otherGestureRecognizer {
   return [gestureRecognizer isKindOfClass:UIScreenEdgePanGestureRecognizer.class];
}

#pragma mark - PUSH & POP
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    // 防止重复push
    if ([self.topViewController isKindOfClass:viewController.class]) {
        return;
    }
    
    if (self.viewControllers.count>0) {
        //当存在子控制器时才隐藏tabBar
        viewController.hidesBottomBarWhenPushed = YES;
        //饭回按钮
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"l_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
//        backItem.imageInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        viewController.navigationItem.leftBarButtonItem = backItem;
        
        // 控制客服球
        [(HYTabBarViewController *)[NNControllerHelper currentTabBarController] hideSuspendBall];
    
    }
    
    //  push入栈
    [super pushViewController:viewController animated:animated];
}

- (void)back {
//    if ([[NNControllerHelper getCurrentViewController] isMemberOfClass:NSClassFromString(@"GameStartPlayViewController")]) {
//        [[NNControllerHelper getCurrentViewController] performSelector:@selector(goBack)];
//    } else {
        [self popViewControllerAnimated:YES];
//    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated{
    // 控制客服球
    if (self.viewControllers.count <= 2) {
        [(HYTabBarViewController *)[NNControllerHelper currentTabBarController] showSuspendBall];
    }
    //pop出栈
    return [super popViewControllerAnimated:animated];
}

- (NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    // 控制客服球
    [(HYTabBarViewController *)[NNControllerHelper currentTabBarController] showSuspendBall];
    return [super popToRootViewControllerAnimated:animated];
}

#pragma mark - DELEGATE
// 屏幕已经渲染完成  即将显示出来
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {

}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 不知道为什么首页缺少这里 导航栏还是会出现
    // 首頁的ChildVC 未設定 hideNavgation = true 因此導航欄還是會出現
    // 隐藏导航栏
//     if (viewController.hideNavgation) {
//         self.navigationBar.translucent = YES;
//         [self setNavigationBarHidden:YES animated:YES];
//     } else {
//         self.navigationBar.translucent = NO;
//         [self setNavigationBarHidden:NO animated:YES];
//     }
    
}

#pragma mark - CUSTOM

+ (HYNavigationController *)navigationControllerWithController:(Class)controller tabBarTitle:(NSString *)tabBarTitle normalImage:(UIImage *)normalImage selectedImage:(UIImage *)selectedImage{
    UIViewController *vc = [[controller alloc] init];;
    
    UITabBarItem *item = [[UITabBarItem alloc]
                          initWithTitle:tabBarTitle
                          image:normalImage
                          selectedImage:selectedImage];

    item.imageInsets = UIEdgeInsetsMake(-3, 0, 3, 0);
    item.titlePositionAdjustment = UIOffsetMake(0, 0);
    item.image = [item.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item.selectedImage = [item.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
   
    vc.tabBarItem = item;
    vc.tabBarItem.title = tabBarTitle;
    vc.title = tabBarTitle;

    HYNavigationController *nav = [[HYNavigationController alloc] initWithRootViewController:vc];
    return nav;
}

#pragma mark - STATUSBAR

- (UIStatusBarStyle)preferredStatusBarStyle {
//    if ([CNSkinManager currSkinType] == SKinTypeBlack) {
        return UIStatusBarStyleLightContent;
//    } else {
//        return UIStatusBarStyleDefault;
//    }
}

#pragma mark - 控制屏幕旋转方法
- (BOOL)shouldAutorotate{
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return  [self.topViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return [self.topViewController preferredInterfaceOrientationForPresentation];
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
