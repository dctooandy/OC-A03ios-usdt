//
//  KYMNetworingWrapper.m
//  Hybird_1e3c3b
//
//  Created by Key.L on 2022/2/21.
//  Copyright © 2022 BTT. All rights reserved.
//

#import "KYMWithdrewRequest.h"
#import "KYMSelectChannelVC.h"
#import "CNMAlertView.h"
#import "LoadingView.h"
#import "KYMFastWithdrewVC.h"
#import "MBProgressHUD+Add.h"
#import "BalanceManager.h"
#import "CNMFastPayStatusVC.h"

@implementation KYMWithdrewRequest


+ (void)checkChannelWithParams:(NSDictionary *)params callback:(KYMCallback)callback {
    kym_sendRequest(@"deposit/checkChannel",params, ^(BOOL status, NSString * msg , NSDictionary *body) {
        if (body == nil || body == NULL || ![body isKindOfClass:[NSDictionary class]]) {
            callback(NO, msg ? : @"操作失败，数据异常",@"");
            return;
        }
        KYMWithdrewCheckModel *model = [KYMWithdrewCheckModel yy_modelWithJSON:body];
        NSString *errMsg = model.message ? : msg;
        if ([model.code isEqualToString:@"00000"]) {
            callback(YES,model.message,model);
        } else {
            callback(NO,errMsg,model);
        }
    });
}
+ (void)createWithdrawWithBankNum:(NSString *)bankNum amount:(NSString *)amount pwd:(NSString *)pwd  callback:(KYMCallback)callback {
    //撮合取款
    NSMutableDictionary *mparams = @{}.mutableCopy;
//            mparams[@"loginName"] = @""; //用户名，底层已拼接
//            mparams[@"productId"] = @""; //脱敏产品编号，底层已拼接
    mparams[@"accountId"] = bankNum; //银行账户编号
    mparams[@"amount"] = amount; //取款金额
    mparams[@"currency"] = @"CNY"; //币种
    mparams[@"withdrawType"] = @"4"; //取款提案类型
    mparams[@"password"] = pwd; //取款密码
    
    kym_sendRequest(@"withdraw/createRequest",mparams.copy, ^(BOOL status, NSString * msg , id body) {
        if (body == nil || body == NULL || ![body isKindOfClass:[NSDictionary class]]) {
            callback(NO, msg ? : @"操作失败，数据异常",@"");
            return;
        }
        KYMCreateWithdrewModel *model = nil;
        model = [KYMCreateWithdrewModel yy_modelWithJSON:body];
        callback(status,msg,model);
    });
}
+ (void)getWithdrawDetailWithParams:(NSDictionary *)params callback:(KYMCallback)callback {
    kym_sendRequest(@"withdraw/getMMWithDrawDetail",params, ^(BOOL status, NSString * msg , id body) {
        if (body == nil || body == NULL || ![body isKindOfClass:[NSDictionary class]]) {
            callback(NO, msg ? : @"操作失败，数据异常",@"");
            return;
        }
        KYMGetWithdrewDetailModel *model = [KYMGetWithdrewDetailModel yy_modelWithJSON:body];
        
        callback(status,msg,model);
    });
}
+ (void)checkReceiveStatus:(NSDictionary *)params callback:(KYMCallback)callback {
    kym_sendRequest(@"withdraw/withdrawOperate",params, ^(BOOL status, NSString * msg , NSDictionary *body) {
        if (body == nil || body == NULL || ![body isKindOfClass:[NSDictionary class]]) {
            callback(NO, msg ? : @"操作失败，数据异常",@"");
            return;
        }
        KYMCheckReceiveModel *model = [KYMCheckReceiveModel yy_modelWithJSON:body];
        NSString *errMsg = model.message ? : msg;
        if ([model.code isEqualToString:@"00000"]) {
            callback(YES,model.message,model);
        } else {
            callback(NO,errMsg,model);
        }
    });
}
+ (void)cancelWithdrawWithParams:(NSDictionary *)params callback:(KYMCallback)callback {
    kym_sendRequest(@"withdraw/cancelRequest",params, ^(BOOL status, NSString * msg , id body) {
        if (body == nil || body == NULL || ![body isKindOfClass:[NSNumber class]]) {
            callback(NO, msg ? : @"操作失败，数据异常",@"");
            return;
        }
        if ([body boolValue]) {
            callback(YES, msg ,@(YES));
        } else {
            callback(NO, msg ,@(NO));
        }
    });
}
+ (void)checkWithdraw:(UIViewController *)viewController callBack:(void(^)(BOOL isMatch,KYMWithdrewCheckModel  * checkModel))callback {
    NSMutableDictionary *parmas = @{}.mutableCopy;
    parmas[@"merchant"] = @"A01";
    //网络库底层自带这两个参数，如果其他产品不带的需要加上
//                        parmas[@"loginName"] = @"xxx";
//                        parmas[@"productId"] = @"xxx";
    parmas[@"type"] = @"2";
    parmas[@"currency"] = @"CNY";
    [KYMWithdrewRequest checkChannelWithParams:parmas.copy callback:^(BOOL status, NSString * _Nonnull msg, KYMWithdrewCheckModel  * _Nonnull model) {
        if (!status) {
            //普通取款
            callback(NO,nil);
            return;
        }
        [LoadingView show];
        kym_requestBalance(^(BOOL status, NSString * _Nonnull msg, NSString  *_Nonnull balance) {
            if (!status) {
                [LoadingView hide];
                [MBProgressHUD showError:msg toView:nil];
                return;
            }
            [LoadingView hideLoadingViewForView:nil];
            //移除比余额小的金额
            [model.data removeAmountBiggerThanTotal:balance];
            //如果渠道开启，有金额列表，且金额列表中最小的比余额大才走撮合
            if (model.data.isAvailable && model.data.amountList.count > 0 && [balance doubleValue] >= [model.data.miniAmount doubleValue]) {
                //取款类型选择弹框
                KYMSelectChannelVC *vc = [[KYMSelectChannelVC alloc] init];
                vc.checkModel = model;
                vc.selectedChannelCallback = ^(NSInteger index) {
                    //是否为撮合取款
                    if (index == 0) {
                        //是否已存在存取款提案
                        if (model.data.mmProcessingOrderTransactionId && model.data.mmProcessingOrderTransactionId.length != 0) {
                            if (model.data.mmProcessingOrderType == 1) { // 存款
                                [CNMAlertView showAlertTitle:@"交易提醒" content:@"您当前有正在交易的存款订单\n如需取款，请选择在线取款" desc:nil needRigthTopClose:NO commitTitle:@"查看订单" commitAction:^{
                                    CNMFastPayStatusVC *statusVC = [[CNMFastPayStatusVC alloc] init];
                                    statusVC.cancelTime = [model.data.remainCancelDepositTimes integerValue];
                                    statusVC.transactionId = model.data.mmProcessingOrderTransactionId;
                                    [viewController.navigationController pushViewController:statusVC animated:YES];
                                    
                                } cancelTitle:@"在线取款" cancelAction:^{
                                    //普通取款
                                    callback(NO,nil);
                                }];
                            } else { // 取款
                                
                                KYMFastWithdrewVC *vc = [[KYMFastWithdrewVC alloc] init];
                                vc.mmProcessingOrderTransactionId = model.data.mmProcessingOrderTransactionId;
                                
                                [CNMAlertView showAlertTitle:@"交易提醒" content:@"老板，如需再次取款，请选择在线取款" desc:nil needRigthTopClose:NO commitTitle:@"关闭" commitAction:^{
                                    
                                } cancelTitle:@"在线取款" cancelAction:^{
                                    [viewController.navigationController popViewControllerAnimated:NO];
                                    [vc stopTimer];
                                    //普通取款
                                    callback(NO,nil);
                                }];
                                
                                [viewController.navigationController pushViewController:vc animated:YES];
                            }
                        } else {
                            //撮合取款
                            callback(YES,model);
                        }
                    } else {
                        //普通取款
                        callback(NO,nil);
                    }
                    
                };
                [viewController presentViewController:vc animated:YES completion:nil];
            } else {
                //普通取款
                callback(NO,nil);
            }
        });
    }];
}
@end
