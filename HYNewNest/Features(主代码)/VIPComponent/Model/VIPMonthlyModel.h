//
//  VIPMonthlyModel.h
//  HYNewNest
//
//  Created by zaky on 9/10/20.
//  Copyright © 2020 emneoma.xyz. All rights reserved.
//

#import "CNBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface VipRhqk :CNBaseModel
/// 累计入会名额
@property (nonatomic , assign) NSInteger              betCount;

/// 赌霸数
@property (nonatomic , strong) NSNumber             * betBaCount;
/// 赌神数
@property (nonatomic , strong) NSNumber             * betGoldCount;
/// 赌王数
@property (nonatomic , strong) NSNumber             * betKingCount;
/// 赌圣数
@property (nonatomic , strong) NSNumber             * betSaintCount;
/// 赌侠数
@property (nonatomic , strong) NSNumber             * betXiaCount;

/// 赌尊名
@property (nonatomic , copy) NSString              * betZunName;
/// 赌尊充值
@property (nonatomic , copy) NSString              * depositAmount;
/// 赌尊流水
@property (nonatomic , copy) NSString              * betAmount;

@end


@interface VipScjz :CNBaseModel
/// 累计送出
@property (nonatomic , copy) NSString              * ljsc;
/// 累计身份
@property (nonatomic , copy) NSString              * ljsf;
/// 入会礼金
@property (nonatomic , copy) NSString              * rhlj;
/// 月度分红
@property (nonatomic , copy) NSString              * ydfh;
/// 至尊转盘
@property (nonatomic , copy) NSString              * zzzp;

@end


@interface VIPMonthlyModel :CNBaseModel
/// 入会情况
@property (nonatomic , strong) VipRhqk              * vipRhqk;
/// 送出价值
@property (nonatomic , strong) VipScjz              * vipScjz;
/// 是否有可领取的入会礼金 空则没有
@property (nonatomic , copy) NSDictionary           * preRequest;
/// 2-7 依次从赌侠到赌尊
@property (nonatomic , copy) NSString              * clubLevel;
/// 上月存款
@property (nonatomic , assign) CGFloat              totalDepositAmount;
/// 上月月份
@property (nonatomic , assign) NSInteger              lastMonth;
/// 上月流水
@property (nonatomic , assign) CGFloat              totalBetAmount;
/// 当前是什么等级
@property (nonatomic , copy) NSString              * betName;

@end

NS_ASSUME_NONNULL_END
