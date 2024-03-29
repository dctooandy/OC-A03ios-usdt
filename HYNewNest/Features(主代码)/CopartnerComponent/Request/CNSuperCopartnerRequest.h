//
//  CNSuperCopartnerRequest.h
//  HYNewNest
//
//  Created by zaky on 12/19/20.
//  Copyright © 2020 BYGJ. All rights reserved.
//

#import "CNBaseNetworking.h"
#import "SuperCopartnerTbConst.h"

#import "SCBetRankModel.h"
#import "SCMyRecommenModel.h"
#import "SCMyBonusModel.h"

NS_ASSUME_NONNULL_BEGIN



@interface CNSuperCopartnerRequest : CNBaseNetworking

// 我的推荐礼金 我的洗码返佣
+ (void)requestSuperCopartnerListType:(SuperCopartnerType)type pageNo:(NSInteger)pageNo handler:(HandlerBlock)handler;

// 累计投注排行
+ (void)requestSuperCopartnerListBetRankHandler:(HandlerBlock)handler;

// 一键领取我的礼金
+ (void)applyMyGiftBonusHandler:(HandlerBlock)handler;

@end

NS_ASSUME_NONNULL_END
