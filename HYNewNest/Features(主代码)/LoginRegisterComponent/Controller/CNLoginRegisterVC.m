//
//  CNLoginRegisterVC.m
//  HYNewNest
//
//  Created by cean.q on 2020/7/13.
//  Copyright © 2020 james. All rights reserved.
//  

#import "CNLoginRegisterVC.h"
#import "CNTwoStatusBtn.h"
#import "CNImageCodeInputView.h"
#import "CNAccountInputView.h"
#import "CNCodeInputView.h"

@interface CNLoginRegisterVC () <CNAccountInputViewDelegate, CNCodeInputViewDelegate,  CNImageCodeInputViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (strong, nonatomic) IBOutlet UIScrollView *switchSV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentWidth;

#pragma mark - Login
@property (weak, nonatomic) IBOutlet CNAccountInputView *loginAccountView;
@property (weak, nonatomic) IBOutlet CNCodeInputView *loginCodeView;
@property (weak, nonatomic) IBOutlet CNTwoStatusBtn *loginBtn;
@property (weak, nonatomic) IBOutlet CNImageCodeInputView *loginImageCodeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginImageCodeViewH;
@property (assign, nonatomic) BOOL needImageCode;
@property (weak, nonatomic) IBOutlet UIButton *remeberCodeBtn;


#pragma mark - Register
@property (weak, nonatomic) IBOutlet CNAccountInputView *registerAccountView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *phoneViewH;
@property (weak, nonatomic) IBOutlet CNTwoStatusBtn *registerBtn;
@property (assign, nonatomic) BOOL isRegister;


@end

@implementation CNLoginRegisterVC

+ (instancetype)loginVC {
    return [[CNLoginRegisterVC alloc] init];
}

+ (instancetype)registerVC {
    CNLoginRegisterVC *vc = [[CNLoginRegisterVC alloc] init];
    vc.isRegister = YES;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    [self setDelegate];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.switchSV.frame = self.bgView.bounds;
    self.contentWidth.constant = self.switchSV.frame.size.width * 2;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)configUI {
    [self.bgView addSubview:self.switchSV];
    if (_isRegister) {
        [self gotoRegister:nil];
    }
}

#pragma mark - InputViewDelegate

- (void)setDelegate {
    self.loginAccountView.delegate = self;
    self.registerAccountView.delegate = self;
    self.loginCodeView.delegate = self;
}

- (void)accountInputViewTextChange:(CNAccountInputView *)view {
    self.loginBtn.enabled = view.correct && self.loginCodeView.correct;
    self.loginCodeView.phoneLogin = view.phoneLogin;
}

- (void)codeInputViewTextChange:(CNAccountInputView *)view {
    self.loginBtn.enabled = view.correct && self.loginAccountView.correct;
}

//- (void)phoneViewTextChange:(CNPhoneInputView *)view {
//    if (self.phoneBtn.selected) {
//        self.registerBtn.enabled = view.correct;
//    } else {
//        self.registerBtn.enabled = self.registerImageCodeView.correct && view.correct;
//    }
//}

//- (void)imageCodeViewTextChange:(CNImageCodeInputView *)view {
//    if ([view isEqual:self.registerImageCodeView]) {
//        self.registerBtn.enabled = self.phoneView.correct && view.correct;
//    }
//}

#pragma mark - ButtonAction

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)gotoRegister:(UIButton *)sender {
    [self.switchSV setContentOffset:CGPointMake(kScreenWidth, 0)];
}

- (IBAction)remeberAction:(UIButton *)sender {
    sender.selected = !sender.selected;
}


- (IBAction)forgotPassword:(id)sender {
//    [self.navigationController pushViewController:[ForgetPasswordViewController new] animated:YES];
}

- (IBAction)goToLogin:(UIButton *)sender {
    [self.switchSV setContentOffset:CGPointMake(0, 0)];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (IBAction)registerRule:(id)sender {
//    [self.navigationController pushViewController:[CNStatementVC new] animated:YES];
}

#pragma mark - Login

- (IBAction)loginAction:(UIButton *)sender {
    
//    if (self.loginCodeView.code.length == 0) {
//        NSString *tip = self.accountView.phoneLogin ? @"请输入验证码": @"请输入密码";
//        [CNHUB showError:tip];
//        return;
//    }
//
//    __weak typeof(self) weakSelf = self;
//    // 手机登录
//    if (self.accountView.phoneLogin) {
//        [self showLoading];
//        [self.viewModel phoneLoginSmsCode:self.loginCodeView.code smsCodeId:self.accountView.codeId finishHandler:^(NSString * _Nullable errMsg) {
//            [weakSelf hideLoading];
//            if ([errMsg isEqualToString:ERROR_BIND_MOBILE_NOBIND]) {
//                [weakSelf showNoRegisterAlert];
//            } else if (errMsg) {
//                [CNHUB showError:errMsg];
//            } else {
//                [CNHUB showSuccess:@"登录成功"];
//                BOOL isNeedSetGesture = [PCCircleViewConst getIsNeedSetGestureCurrentLoginName];
//                if (isNeedSetGesture) {
//                    [PCCircleViewConst setNeedSetGestureCurrentLoginName:false];
//                    [LCAppDelegate setLockGestureAfterRegist];
//                }else{
//                    //当有手势密码的时候就会出问题，所以重置根控制器
//                    [LCAppDelegate  createRootTabarController];
//                }
//              //  [weakSelf.navigationController popToRootViewControllerAnimated:YES];
//            }
//        }];
//        return;
//    }
//
    // 账号登录
//    if (self.needImageCode) {
//        if (self.loginImageCodeView.imageCode.length == 0) {
//            [CNHUB showError:@"请输入图形验证码"];
//            return;
//        }
//
//        [self accountLogin];
//        return;
//    }
//
//    // 需要检测是否需要图形验证码
//    [self showLoading];
//    [self.viewModel accountPreLogin:self.accountView.account finishHandler:^(NSString * _Nullable errMsg) {
//        [weakSelf hideLoading];
//        if ([errMsg isEqualToString:ERROR_CAPTCHA_EMPTY]) {
//            weakSelf.needImageCode = YES;
//            [CNHUB showError:@"需要验证图形验证码"];
//        } else if (errMsg) {
//            [CNHUB showError:errMsg];
//        } else {
//            [weakSelf accountLogin];
//        }
//    }];
}

// 账号登录
- (void)accountLogin {
//    __weak typeof(self) weakSelf = self;
//    [self showLoading];
//    [self.viewModel accountLogin:self.accountView.account password:self.loginCodeView.code imageCode:self.loginImageCodeView.imageCode imageCodeId:self.loginImageCodeView.imageCodeId finishHandler:^(NSString * _Nonnull errMsg) {
//        [weakSelf hideLoading];
//        if ([errMsg isEqualToString:ERROR_PWD_ERROR_MORE_TIMES]) {
//            weakSelf.needImageCode = YES;
//            [CNHUB showError:@"需要验证图形验证码"];
//        } else if ([errMsg isEqualToString:ERROR_LOGIN_LOCK_ACCOUNT]) {
//            [weakSelf lockAccount];
//        } else if (errMsg) {
//            [CNHUB showError:errMsg];
//        } else {
//            [CNHUB showSuccess:@"登录成功"];
//
//            BOOL isNeedSetGesture = [PCCircleViewConst getIsNeedSetGestureCurrentLoginName];
//            if (isNeedSetGesture) {
//                [PCCircleViewConst setNeedSetGestureCurrentLoginName:false];
//                [LCAppDelegate setLockGestureAfterRegist];
//            }else{
//                //当有手势密码的时候就会出问题，所以重置根控制器
//                [LCAppDelegate  createRootTabarController];
//            }
//        //[weakSelf.navigationController popToRootViewControllerAnimated:YES];
//        }
//    }];
}

- (void)lockAccount {
//    self.loginBtn.enabled = NO;
//    LCWeak
//    [CNAlertView showNormalTitle:@"账号锁定" message:@"密码错误5次，账号已被锁定，请5分钟后再试或联系客服解锁" defaultTitle:@"联系客服" needCancelButton:YES defaultAction:^{
//        [CustomerPopView initWithParentVC:weakSelf];
//    }];
}

- (void)showNoRegisterAlert {
//    [CNAlertView showNormalTitle:@"该手机号尚未注册" message:@"您是否注册新的游戏账户？" defaultTitle:@"注册" needCancelButton:YES defaultAction:^{
//        [self autoRegister];
//    }];
}

#pragma mark - Register

- (IBAction)registerAction:(UIButton *)sender {
    
//    __weak typeof(self) weakSelf = self;
//    // 手机注册
//    if (self.phoneBtn.selected) {
//        CNVerificationCodeVC *codeVC = [[CNVerificationCodeVC alloc] init];
//        codeVC.phoneNum = self.phoneView.phone;
//        codeVC.smsUseType = CNSMSCodeTypeRegister;
//        [self.navigationController pushViewController:codeVC animated:YES];
//        return;
//    }
//    // 账号注册
//    [self showLoading];
//    [self.viewModel accountRegisterPhoneNum:self.phoneView.phone imageCode:self.registerImageCodeView.imageCode imageCodeId:self.registerImageCodeView.imageCodeId finishHandler:^(NSString * _Nullable errMsg) {
//        [weakSelf hideLoading];
//        if (errMsg) {
//            [CNHUB showError:errMsg];
//            return;
//        }
//        // 注册成功
//        [weakSelf registerSuccess:NO];
//    }];
}

- (void)registerSuccess:(BOOL)phoneRegister {
//    [CNHUB showSuccess:@"注册成功"];
    /* 需求更改，统一用账号显示
     // 手机注册时是手机号
     NSString *account = phoneRegister ? self.accountView.account :[CNUserManager shareManager].userInfo.loginName;
     CNRegisterSuccessView *view = [[CNRegisterSuccessView alloc] initWithAccount:account password:[CNUserManager shareManager].userInfo.password isPhone:phoneRegister];
     */
    
//    CNRegisterSuccessView *view = [[CNRegisterSuccessView alloc] initWithAccount:[CNUserManager shareManager].userInfo.loginName password:[CNUserManager shareManager].userInfo.password isPhone:NO];
//    [self.navigationController pushViewController:[[ChargeViewController alloc] initWithView:view] animated:YES];
}
/*
- (void)autoRegister {
    __weak typeof(self) weakSelf = self;
    [self.viewModel autoRegisterFinishHandler:^(NSString * _Nullable errMsg) {
        if (errMsg) {
            [CNHUB showError:errMsg];
            return;
        }
        [weakSelf registerSuccess:YES];
    }];
}
 
#pragma mark - Setter & Getter

- (void)setNeedImageCode:(BOOL)needImageCode {
    _needImageCode = needImageCode;
    if (needImageCode) {
        self.loginImageCodeView.hidden = NO;
        self.loginImageCodeViewH.constant = 80;
        [self.loginImageCodeView getImageCode];
    }
}
*/
//- (CNLoginVM *)viewModel {
//    if (!_viewModel) {
//        _viewModel = [[CNLoginVM alloc] init];
//    }
//    return _viewModel;
//}

@end
