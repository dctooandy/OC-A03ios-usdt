//
//  CNWDAddressRequest.m
//  HYNewNest
//
//  Created by Lenhulk on 2020/7/23.
//  Copyright © 2020 emneoma. All rights reserved.
//

#import "CNWDAccountRequest.h"

@implementation CNWDAccountRequest

+(void)getWallet:(HandlerBlock)handler {
    NSMutableDictionary *param = [kNetworkMgr baseParam];
    param[@"bizCode"] = @"WALLET_TYPE";
    [self POST:(config_dynamicQuery) parameters:param completionHandler:handler];
}

+ (void)queryAccountHandler:(HandlerBlock)handler {
    NSMutableDictionary *param = [kNetworkMgr baseParam];
    // 0 仅查询银行账户  1 查询当前账户和子账户(usdt)列表  2 仅查询子账户列表
    // subWalletAccounts
    param[@"queryType"] = @1;
    [self POST:(config_getQueryCard) parameters:param completionHandler:handler];
}

+ (void)deleteAccountId:(NSString *)accountId
                handler:(HandlerBlock)handler {
    
    NSMutableDictionary *param = [kNetworkMgr baseParam];
    param[@"accountId"] = accountId;
    
    [self POST:(config_deleteAccount) parameters:param completionHandler:handler];
}

+ (void)deleteAccountId:(NSString *)accountId
           smsCodeModel:(SmsCodeModel *)smsCodeModel
                handler:(HandlerBlock)handler {
    
    NSMutableDictionary *param = [kNetworkMgr baseParam];
    param[@"accountId"] = accountId;
    param[@"messageId"] = smsCodeModel.messageId;
    param[@"validateId"] = smsCodeModel.validateId;
    param[@"smsCode"] = smsCodeModel.smsCode;
    
    [self POST:(config_deleteAccount) parameters:param completionHandler:handler];
}

+ (void)getBankCardBinByBankCardNo:(NSString *)bankCardNo   handler:(HandlerBlock)handler {
    kPreventRepeatTime(0.5);
    
    NSMutableDictionary *param = [kNetworkMgr baseParam];
    param[@"bankCardNo"] = bankCardNo;
    
    [self POST:(config_getByCardBin) parameters:param completionHandler:handler];
}

+ (void)createAccountBankCardNo:(NSString *)accountNo
                       bankName:(NSString *)bankName
                    accountType:(NSString *)accountType
                 bankBranchName:(NSString *)bankBranchName
                       province:(NSString *)province
                           city:(NSString *)city
                      messageId:(NSString *)messageId
                     validateId:(NSString *)validateId
                         expire:(NSString *)expire
                        handler:(HandlerBlock)handler {
    
    NSMutableDictionary *param = [kNetworkMgr baseParam];
    param[@"accountNo"] = accountNo;
    param[@"bankName"] = bankName;
    param[@"accountType"] = accountType;
    param[@"bankBranchName"] = bankBranchName;
    param[@"province"] = province;
    param[@"city"] = city;
    param[@"messageId"] = messageId;
    param[@"validateId"] = validateId;
    param[@"expire"] = expire;
    
    [self POST:(config_createBank) parameters:param completionHandler:handler];
    
}

+ (void)createAccountDCBoxAccountNo:(NSString *)accountNo
                           isOneKey:(BOOL)isOneKey
                         validateId:(nullable NSString *)validateId
                          messageId:(nullable NSString *)messageId
                            smsCode:(nullable NSString *)smsCode
                            handler:(HandlerBlock)handler {
    
    NSMutableDictionary *param = [kNetworkMgr baseParam];
    param[@"accountNo"] = accountNo;
    param[@"accountNo2"] = accountNo;
    param[@"accountType"] = @"DCBOX";
    param[@"walletType"] = @"DCBOX";
    param[@"bankName"] = @"DCBOX";
    param[@"protocol"] = @"ERC20";
    param[@"accountName"] = [CNUserManager shareManager].printedloginName;
    param[@"flag"] = isOneKey?@1:@2;
    if (validateId) {
        param[@"validateId"] = validateId;
    }
    if (messageId) {
        param[@"messageId"] = messageId;
    }
    if (smsCode) {
        param[@"smsCode"] = smsCode;
    }
    
    [self POST:(config_create) parameters:param completionHandler:handler];
    
}

+ (void)createAccountUSDTAccountNo:(NSString *)accountNo
                         bankAlias:(NSString *)bankAlias
                          bankName:(NSString *)bankName
                          protocol:(NSString *)protocol
                        validateId:(nullable NSString *)validateId
                         messageId:(nullable NSString *)messageId
                           smsCode:(nullable NSString *)smsCode
                           handler:(HandlerBlock)handler {
    
    NSMutableDictionary *param = [kNetworkMgr baseParam];
    // 协议改为自动判定
    param[@"accountNo"] = accountNo;
    param[@"bankAlias"] = bankAlias;
    param[@"accountType"] = @"USDT";
    param[@"walletType"] = @"USDT";
    param[@"accountName"] = [CNUserManager shareManager].printedloginName;
    param[@"bankName"] = bankName;
    param[@"protocol"] = protocol;
    [param setObject:@2 forKey:@"flag"];
    if (validateId) {
        param[@"validateId"] = validateId;
    }
    if (messageId) {
        param[@"messageId"] = messageId;
    }
    if (smsCode) {
        param[@"smsCode"] = smsCode;
    }

    [self POST:(config_create) parameters:param completionHandler:handler];
}

+ (NSString *)autoUsdtProtocolAccountNo:(NSString *)accountNo {
    if (!KIsEmptyString(accountNo)) {
        if ([accountNo hasPrefix:@"1"] || [accountNo hasPrefix:@"3"]) {
            return @"OMNI";
        } else if ([accountNo hasPrefix:@"0x"]) {
            return @"ERC20";
        } else if ([accountNo hasPrefix:@"T"]) {
            return @"TRC20";
        }
    }
    return @"ERC20";
}

+ (void)createGoldAccountHandler:(HandlerBlock)handler {
    
    NSMutableDictionary *param = [kNetworkMgr baseParam];
    param[@"use"] = @8;
    
    [self POST:(config_createGoldAccount) parameters:param completionHandler:handler];
}


@end
