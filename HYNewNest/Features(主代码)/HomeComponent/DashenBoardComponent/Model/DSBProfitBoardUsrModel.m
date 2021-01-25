//
//  DSBProfitBoardUsrModel.m
//  HYNewNest
//
//  Created by zaky on 1/25/21.
//  Copyright © 2021 BYGJ. All rights reserved.
//

#import "DSBProfitBoardUsrModel.h"
#import "VIPRankConst.h"

@implementation PrListItem
@end


@implementation DSBProfitBoardUsrModel
- (NSString *)writtenLevel {
    if (self.clubLevel > 1) {
        // 返回 私享会等级
        return VIPRankString[self.clubLevel];
    } else {
        // 返回 VIPn
        return [NSString stringWithFormat:@"VIP%ld", self.customerLevel];
    }
}

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"prList": [PrListItem class]};
}
@end
