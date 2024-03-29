//
//  HYNetworkConfigManager.m
//  HYNewNest
//
//  Created by Lenhulk on 2020/7/20.
//  Copyright © 2020 james. All rights reserved.
//

#import "HYNetworkConfigManager.h"
#import "CNUserManager.h"
#import "CNTOPHUB.h"
#import "CNSplashRequest.h"
#import "HYInGameHelper.h"
#import "HYTabBarViewController.h"
#import "AppdelegateManager.h"
#import "IVCacheWrapper.h"
@interface HYNetworkConfigManager ()
@property (nonatomic, assign, readwrite) IVNEnvironment environment;
@property (nonatomic, strong) NSString *envName;
@end

@implementation HYNetworkConfigManager
@synthesize environment = _environment;

+ (void)load {
    [HYNetworkConfigManager shareManager];
    [AppdelegateManager shareManager];
}

+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    static HYNetworkConfigManager *_configManager = nil;
    dispatch_once(&onceToken, ^{
        _configManager = [[HYNetworkConfigManager alloc] init];
#ifdef DEBUG
        IVNEnvironment environment = [[NSUserDefaults standardUserDefaults] integerForKey:@"IVNEnvironment"];
        _configManager.environment = environment;
#else
        _configManager.environment = IVNEnvironmentPublish;
#endif
        [IVHttpManager shareManager].environment = _configManager.environment;
        [IVHttpManager shareManager].appId = @"dzqAQAGPCjn1kUqzeiHsUTy57sFVTNQs";//A01NEWAPP02
        [IVHttpManager shareManager].productId = @"1682d3a2ee0c4ee8acbe58a5c39bb888";//A01
        [IVHttpManager shareManager].parentId = @"";//???: 渠道号
        [IVHttpManager shareManager].globalHeaders = @{@"pid": @"1682d3a2ee0c4ee8acbe58a5c39bb888",
                                                       @"Authorization": @"Bearer"};
        [IVHttpManager shareManager].userToken = [CNUserManager shareManager].userInfo.token;
        [IVHttpManager shareManager].loginName = [CNUserManager shareManager].userInfo.loginName;
        
    });
    return _configManager;
}

//Debug才会进入
- (void)switchEnvirnment {
#ifdef DEBUG
    // 切换环境 保存
    [IVHttpManager shareManager].gateway = nil;
    [IVHttpManager shareManager].domain = nil;
    [IVHttpManager shareManager].gateways = nil;
    [IVHttpManager shareManager].domains = nil;
    [AppdelegateManager shareManager].gateways = nil;
    [AppdelegateManager shareManager].websides = nil;
    [IVCacheWrapper clearCache];
    self.environment += 1;
//    if (self.environment == 2)
//    {
//        self.environment += 1;
//    }
    if (self.environment > 3) {
        self.environment = 1;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:self.environment forKey:@"IVNEnvironment"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[AppdelegateManager shareManager] setEnvironment:self.environment];
    WEAKSELF_DEFINE
    [[AppdelegateManager shareManager] checkDomainHandler:^{

    [kKeywindow jk_makeToast:[IVHttpManager shareManager].gateway
                    duration:4
                    position:JKToastPositionCenter
                       title:[NSString stringWithFormat:@"😄当前是%ld --【%@】",(long)weakSelf.environment ,weakSelf.envName]];

        // 重新加载游戏线路信息
        [[HYInGameHelper sharedInstance] queryHomeInGamesStatus];
        
        // 重新获取H5/CDN
        [CNSplashRequest queryCDNH5Domain:^(id responseObj, NSString *errorMsg) {
            NSString *cdnAddr = responseObj[@"csdnAddress"];
            NSString *h5Addr = responseObj[@"h5Address"];
            if ([cdnAddr containsString:@","]) {
                cdnAddr = [cdnAddr componentsSeparatedByString:@","].firstObject;
            }
            [IVHttpManager shareManager].cdn = cdnAddr;
            [IVHttpManager shareManager].domain = h5Addr;
        }];
        
        // 重新加载OCSS
        [(HYTabBarViewController *)[NNControllerHelper currentTabBarController] initOCSSSDKShouldReload:NO];
    }];

#endif
}


#pragma mark - GET&SET
- (IVNEnvironment)environment {
    return _environment;
}

- (void)setEnvironment:(IVNEnvironment)environment {
//    NSString *envName;
    
    NSMutableDictionary *eventDict = @{}.mutableCopy;
    [eventDict setValue:[IVHttpManager shareManager].gateway forKey:@"from"];
    
    _environment = environment;
    [IVHttpManager shareManager].environment = environment;
    [IVHttpManager shareManager].domain = @"https://m.ag800.com"; //H5
    [IVHttpManager shareManager].cdn = @"https://a03front.58baili.com"; //cdn
    [self getEnvName];
//    //通知外部
    [eventDict setValue:[IVHttpManager shareManager].gateway forKey:@"to"];
    [[NSNotificationCenter defaultCenter] postNotificationName:IVNGatewaySwitchNotification object:nil userInfo:eventDict.copy];
}

- (void)getEnvName
{
    switch (self.environment) {
        case IVNEnvironmentTest:
        {
            _envName = @"本地环境";
            break;
        }
        case IVNEnvironmentDevelop:
        {
            _envName = @"本地环境";
            break;
        }
        case IVNEnvironmentPublishTest:
        {
            _envName = @"运测环境";
            break;
        }
        case IVNEnvironmentPublish:
        {
            _envName = @"运营环境";
            break;
        }
        default:
            break;
    }
}

- (NSMutableDictionary *)baseParam {
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[@"productId"] = [IVHttpManager shareManager].productId;
    if (!KIsEmptyString([IVHttpManager shareManager].loginName)) { //非空
        param[@"loginName"] = [IVHttpManager shareManager].loginName;
    }
    return param;
}

@end
