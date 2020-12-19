//
//  SuperCopartnerTbCell.m
//  HYNewNest
//
//  Created by zaky on 12/17/20.
//  Copyright © 2020 BYGJ. All rights reserved.
//

#import "SuperCopartnerTbCell.h"

@implementation SuperCopartnerTbCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = kHexColor(0xFFFFFF);
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    return self;
}


- (void)setupType:(SuperCopartnerType)type strArr:(NSArray<NSString *> *)strArr {
    
    [self removeAllSubViews];
    NSMutableArray *arr = strArr.mutableCopy;
    //TODO: 假数据
    UIColor *textColor = kHexColor(0x000000);
    switch (type) {
        case SuperCopartnerTypeMyBonus:
            if (strArr.count == 0) {
                arr = @[@"--", @"--", @"--", @"--", @"--"].mutableCopy;
            }
            break;
        case SuperCopartnerTypeMyRecommen:
            if (strArr.count == 0) {
                arr = @[@"--", @"--", @"--", @"--"].mutableCopy;
            }
            break;
        case SuperCopartnerTypeCumuBetRank: // 颜色改变
        {
            NSString *rank = arr.firstObject;
            if ([rank isEqualToString:@"1"]) {
                textColor = kHexColor(0xD69F5A);
                [arr replaceObjectAtIndex:0 withObject:@"冠军"];
            } else if ([rank isEqualToString:@"2"]) {
                textColor = kHexColor(0xD83783);
                [arr replaceObjectAtIndex:0 withObject:@"亚军"];
            } else if ([rank isEqualToString:@"3"]) {
                textColor = kHexColor(0x6132D4);
                [arr replaceObjectAtIndex:0 withObject:@"季军"];
            }
            break;
        }
        case SuperCopartnerTypeMyGifts:
            arr = @[@"2020.20.20", @"Macbook pro 13.3英寸", @"30天"].mutableCopy;
            break;
        default:
            break;
    }
    
    __block NSInteger line = arr.count;
    CGFloat lbWidth = (kScreenWidth - 25 - 20) / (line * 1.0);
    [arr enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *lb = [UILabel new];
        lb.text = obj;
        lb.font = [UIFont fontPFR12];
        lb.textColor = textColor;
        lb.textAlignment = NSTextAlignmentCenter;
        lb.adjustsFontSizeToFitWidth = YES;
        lb.frame = CGRectMake(10 + lbWidth * idx, 0, lbWidth, 26);
        [self addSubview:lb];
    }];
}

@end
