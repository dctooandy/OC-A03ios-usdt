//
//  HYTabBarViewController.m
//  HYGEntire
//
//  Created by zaky on 24/10/2019.
//  Copyright © 2019 kunlun. All rights reserved.
//


#import "HYTabBarViewController.h"
#import "HYNavigationController.h"
#import "CNHomeVC.h"
//#import "HYVIPViewController.h"
#import "HYBonusViewController.h"
#import "HYGloryViewController.h"
#import "CNMineVC.h"

#import "UIImage+ESUtilities.h"
#import "SuspendBall.h"
#import "CNServerView.h"
#import "CNHomeRequest.h"

@interface HYTabBarViewController ()<UITabBarControllerDelegate, SuspendBallDelegte, CNServerViewDelegate>
@property (nonatomic, strong) SuspendBall *suspendBall;
@end

@implementation HYTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupControllers];
    [self setupAppearance];
    [self setupCSSuspendBall];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupAppearance) name:CNSkinChangeNotification object:nil];
}

- (void)setupAppearance{
    
    if (@available(iOS 13, *)) {
        UITabBarAppearance *appearance = [self.tabBar.standardAppearance copy];
        // 设置背景
        UIImage *bgimg = [UIImage createImageWithRadius:0 Color:KColorRGB(12, 11, 17) bounds:CGRectMake(0, 0, kScreenWidth, kTabBarHeight)];
        appearance.backgroundImage = bgimg;
//        if (CNSkinManager.currSkinType == SKinTypeBlack) { //没效果？
//            appearance.backgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//        } else {
            appearance.backgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//        }
        appearance.backgroundColor = [UIColor clearColor];
        // 去除分割线
//        appearance.shadowImage = [UIImage new];
//        appearance.shadowColor = [UIColor clearColor];
        // 选中字体颜色
        self.tabBar.tintColor = kHexColor(0x0FB4DD);
        self.tabBar.standardAppearance = appearance;
        
    } else {
        // 设置背景色
        [[UITabBar appearance] setBarTintColor:KColorRGB(12, 11, 17)];
        // 去除分割线
//        self.tabBar.shadowImage = [UIImage new];
        // 选中字体颜色
        self.tabBar.tintColor = kHexColor(0x0FB4DD);
        [UITabBar appearance].translucent = YES;
    }
}

- (void)setupControllers{
    
    NSMutableArray *vcs = @[].mutableCopy;
    HYNavigationController *homeNav = [HYNavigationController navigationControllerWithController:[CNHomeVC class]
                                                                   tabBarTitle:@"大厅"
                                                                   normalImage:[UIImage imageNamed:@"Home"]
                                                                 selectedImage:[UIImage imageNamed:@"Home_s"]];
    [vcs addObject:homeNav];
    
//    HYNavigationController *vipNav = [HYNavigationController navigationControllerWithController:[HYVIPViewController class]
//                                                                                        tabBarTitle:@"VIP"
//                                                                                        normalImage:[UIImage imageNamed:@"vip"]
//                                                                                      selectedImage:[UIImage imageNamed:@"vip_s"]];
//    [vcs addObject:vipNav];
    
    HYNavigationController *bonusNav = [HYNavigationController navigationControllerWithController:[HYBonusViewController class]
                                                                                            tabBarTitle:@"优惠"
                                                                                            normalImage:[UIImage imageNamed:@"youhui"]
                                                                                          selectedImage:[UIImage imageNamed:@"youhui_s"]];
    [vcs addObject:bonusNav];
   
    HYNavigationController *gloryNav = [HYNavigationController navigationControllerWithController:[HYGloryViewController class]
                                                                      tabBarTitle:@"风采"
                                                                      normalImage:[UIImage imageNamed:@"Fengcai"]
                                                                    selectedImage:[UIImage imageNamed:@"Fengcai_s"]];
    [vcs addObject:gloryNav];
    
    HYNavigationController *mineNav = [HYNavigationController navigationControllerWithController:[CNMineVC class]
                                                                   tabBarTitle:@"我的"
                                                                   normalImage:[UIImage imageNamed:@"Wode"]
                                                                 selectedImage:[UIImage imageNamed:@"Wode_s"]];
    [vcs addObject:mineNav];
    
    
    self.viewControllers = vcs.copy;
    self.delegate = self;
}

- (void)setupCSSuspendBall {
    CGFloat btnWH = 60.f;
    NSArray *imgNameGroup = @[@"cunqu", @"help", @"phone_s"];
    SuspendBall *suspendBall = [SuspendBall suspendBallWithFrame:CGRectMake(kScreenWidth - btnWH, kScreenHeight *0.75, btnWH, btnWH) delegate:self subBallImageArray:imgNameGroup];
    suspendBall.top = kNavPlusStaBarHeight;
    suspendBall.bottom = kTabBarHeight + kSafeAreaHeight;
    suspendBall.hidden = NO;
    self.suspendBall = suspendBall;
    [self.view addSubview:suspendBall];
    [self.view bringSubviewToFront:suspendBall];
}


#pragma mark  UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
        
    NSInteger index = [tabBarController.viewControllers indexOfObject:viewController];
    
    if (index == 3 && ![CNUserManager shareManager].isLogin) {

        [HYTextAlertView showWithTitle:@"温馨提示" content:@"我的页面有很多资金信息，登录后才可以查看哦" comfirmText:@"登录" cancelText:@"注册" comfirmHandler:^(BOOL isComfirm) {
            if (isComfirm) {
                [NNPageRouter jump2Login];
            } else {
                [NNPageRouter jump2Register];
            }
        }];

        return NO;
    }

    return YES;
}


#pragma mark - SuspendBallDelegte 弹球
-(void)hideSuspendBall{
    if (self.suspendBall && self.suspendBall.showFunction == YES) {
        [self.suspendBall suspendBallShow];
    }
    self.suspendBall.hidden = YES;
}

- (void)showSuspendBall {
    self.suspendBall.hidden = NO;
}

- (void)suspendBall:(UIButton *)subBall didSelectTag:(NSInteger)tag{
    
    [self hideSuspendBall];
    
    if(tag == 0){
        //客服 存取款问题
        [NNPageRouter jump2Live800Type:CNLive800TypeDeposit];
    }else if (tag == 1){
        //客服 其他问题
        [NNPageRouter jump2Live800Type:CNLive800TypeNormal];
    }else if (tag == 2){
        //电话回拨
        [CNServerView showServerWithDelegate:self];
    }else if (tag == 3){
        //400
        [self call400];
    }
}

- (void)serverView:(CNServerView *)server callBack:(NSString *)phone code:(NSString *)code messageId:(NSString *)messageId {
    NSLog(@"phone=%@,code=%@, mid=%@", phone, code, messageId);
    // 请求接口处理完成移除
    [server removeFromSuperview];
    [CNHomeRequest callCenterCallBackMessageId:messageId
                                       smsCode:code
                                      mobileNo:phone
                                       handler:^(id responseObj, NSString *errorMsg) {
        if (!errorMsg) {
            [kKeywindow jk_makeToast:@"客户代表将于1-10分钟内为您致电，请保持电话畅通哦 (^o^)" duration:3 position:JKToastPositionCenter];
        }
    }];
}

- (void)call400{
    
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",@"4001203093"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str] options:@{} completionHandler:^(BOOL success) {
        [CNHUB showSuccess:@"正在为您拨通.."];
    }];
}


#pragma mark - 控制屏幕旋转方法
-(BOOL)shouldAutorotate {
    return self.selectedViewController.shouldAutorotate;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.selectedViewController supportedInterfaceOrientations];
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.selectedViewController preferredInterfaceOrientationForPresentation];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
