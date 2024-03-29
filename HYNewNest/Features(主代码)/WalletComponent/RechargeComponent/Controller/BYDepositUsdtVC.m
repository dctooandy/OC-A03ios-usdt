//
//  BYDepositUsdtVC.m
//  HYNewNest
//
//  Created by zaky on 6/21/21.
//  Copyright © 2021 BYGJ. All rights reserved.
//

#import "BYDepositUsdtVC.h"
#import <IN3SAnalytics/CNTimeLog.h>
#import "CNRechargeRequest.h"
#import "HYRechargeHelper.h"
#import "ChargeManualMessgeView.h"
#import "CNTwoStatusBtn.h"
#import "BYDepositUsdtEditorView.h"
#import "UILabel+Gradient.h"
#import "ChargeManualMessgeView.h"
#import "CNTradeRecodeVC.h"

@interface BYDepositUsdtVC () <BYDepositUsdtEditorDelegate>
@property (weak, nonatomic) IBOutlet UIButton *xjkBtn;
@property (weak, nonatomic) IBOutlet UIView *qtqbBg;
@property (weak, nonatomic) IBOutlet UIView *xjkBg;
@property (weak, nonatomic) IBOutlet UILabel *xjk;
@property (weak, nonatomic) IBOutlet UILabel *qtqb;
@property (weak, nonatomic) IBOutlet BYDepositUsdtEditorView *editorView;
@property (weak, nonatomic) IBOutlet CNTwoStatusBtn *depoBtn;

@property (assign,nonatomic) NSInteger selIdx; //!<选中行
@property (nonatomic, strong) NSArray<DepositsBankModel *> *depositModels;
@property (nonatomic, strong) NSArray<PayWayV3PayTypeItem *> *payWayV3Models;
@property (nonatomic, strong) OnlineBanksModel *curOnliBankModel;
@property (nonatomic, strong) NSArray *depositProtocolList;
@end

@implementation BYDepositUsdtVC

#pragma mark - VIEW LIFE CYCLE
- (instancetype)init {
    [CNTimeLog startRecordTime:CNEventPayLaunch];
    if (self = [super init]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"充币";
    [self addNaviRightItemWithImageName:@"kf"];
    
    _selIdx = 0;
    _editorView.delegate = self;
    _depoBtn.enabled = NO;
    if (self.amount_list.length > 0) {
        _editorView.amount_list = self.amount_list;
    }
    
    [_xjk setupGradientColorDirection:BYLblGrdtColorDirectionLeftRight From:kHexColor(0x10B4DD) toColor:kHexColor(0x19CECE)];
    [_qtqb setupGradientColorDirection:BYLblGrdtColorDirectionLeftRight From:kHexColor(0x10B4DD) toColor:kHexColor(0x19CECE)];
    
    [self queryDepositBankPayWays];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_hasRecord) {
        [CNTimeLog endRecordTime:CNEventPayLaunch];
        _hasRecord = YES;
    }
}

- (void)rightItemAction {
    [NNPageRouter presentOCSS_VC];
}


#pragma mark - IBAction
- (IBAction)didTapTopDepositWayBtn:(UIButton *)sender {
    self.selIdx = sender.tag;
    if (sender.tag == 0) {
        _qtqbBg.backgroundColor = kHexColor(0x1C1C36);
        _xjkBg.backgroundColor = kHexColor(0x272749);
    } else {
        _qtqbBg.backgroundColor = kHexColor(0x272749);
        _xjkBg.backgroundColor = kHexColor(0x1C1C36);
    }
}

- (void)setSelIdx:(NSInteger)selIdx {
    _selIdx = selIdx;
    if (self.payWayV3Models.count) {
//        _editorView.deposModel = self.depositModels[_selIdx];
        _editorView.paywaysV3Model = self.payWayV3Models[_selIdx];
        if (self.suggestRecharge != 0) {
            _editorView.rechargeAmount = [NSString stringWithFormat:@"%i", self.suggestRecharge];
        }
    }
}


#pragma mark - BYDepositUsdtEditorDelegate
/**
 选择了协议
 */
- (void)didSelectOneProtocol:(NSString *)selectedProtocol {

//    DepositsBankModel *model = self.depositModels[_selIdx];
    PayWayV3PayTypeItem *model = self.payWayV3Models[_selIdx];
    [CNRechargeRequest queryOnlineBanksPayType:model.payType
                                  usdtProtocol:selectedProtocol
                                       handler:^(id responseObj, NSString *errorMsg) {
        if (KIsEmptyString(errorMsg) && [responseObj isKindOfClass:[NSDictionary class]]) {
            OnlineBanksModel *oModel = [OnlineBanksModel cn_parse:responseObj];
            self.curOnliBankModel = oModel;
        }
    }];
}

- (void)depositAmountIsRight:(BOOL)isRight {
    self.depoBtn.enabled = isRight;
}


#pragma mark - REQUEST
//- (void)getPayAmountShortCuts {
//    [CNRechargeRequest getShortCutsHandler:^(id responseObj, NSString *errorMsg) {
//        if (!errorMsg && [responseObj isKindOfClass:[NSArray class]]) {
//            NSDictionary *dict = responseObj[0];
//            self->amount_list = dict[@"amount_list"];
//            self->h5_root = dict[@"h5_root"];
//            self.btmTitleLb.text = dict[@"title"];

//            NSString *promo = dict[@"promo_info"]; // 顶部广告图
//            self.topBannerDict = [promo jk_dictionaryValue];
//            NSString *topUrl = [self->h5_root stringByAppendingString:self.topBannerDict[@"h5_img"]];
//            [self.topBanner sd_setImageWithURL:[NSURL URLWithString:topUrl] placeholderImage:[UIImage imageNamed:@"gg"]];
//
//            NSString *teaching = dict[@"teaching"]; // 底部轮播图
//            self.btmBannerDict = [teaching jk_dictionaryValue];
//            [self setupBtmBanners];
//        }
//    }];
//}

/**
USDT支付渠道
*/
- (void)queryDepositBankPayWays {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("queryPaywaysV3.data", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_group_enter(group);
//    [self loadPaywaysV3Datas:group];

    dispatch_group_notify(group,queue, ^{
        [self loadPaywaysV3Datas];
    });
}

- (void)loadPaywaysV3Datas {
    [CNRechargeRequest queryPayWaysV3Handler:^(id responseObj, NSString *errorMsg) {
        if (errorMsg) {
            return;
        }
        PayWayV3Model *resultModel = [PayWayV3Model cn_parse:responseObj];
        __block NSMutableArray *models = @[].mutableCopy;
        __block NSInteger xjkIdx = 0;
        __block NSInteger otherWalletIdx = 0;

        //去掉手工存款 paytype = 0 的情况。不再支持此方式，服务器去不掉只能客户端做过滤
//        NSMutableArray *tmp = [NSMutableArray arrayWithArray:resultModel.payTypeList];
//        for (PayWayV3PayTypeItem *item in resultModel.payTypeList) {
//          if ([item.payType isEqualToString:@"43"])
//          {
//              self.depositProtocolList = item.protocolList;
//          }
//        }
        [resultModel.payTypeList enumerateObjectsUsingBlock:^(PayWayV3PayTypeItem * _Nonnull bank, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([bank.payType caseInsensitiveCompare:@"43"] == NSOrderedSame) {
                [models addObject:bank];
                xjkIdx = models.count-1;
            }
            if ([HYRechargeHelper isUSDTOtherBankV3Model:bank]) {
                [models addObject:bank];
                otherWalletIdx = models.count-1;
            }
        }];
        // 将小金库排到第一位
        if (xjkIdx != 0) {
            [models exchangeObjectAtIndex:0 withObjectAtIndex:xjkIdx];
        }
        if (models.count == 0) {
            [CNTOPHUB showAlert:@"暂无可用充值渠道"];
            return;
        }
        self.payWayV3Models = models;
        
        [self didTapTopDepositWayBtn:self->_xjkBtn];

//        dispatch_group_leave(group);
    }];
}
- (void)quertUSDTPayWallets {
    [CNRechargeRequest queryUSDTPayWalletsHandler:^(id responseObj, NSString *errorMsg) {
        
        NSArray *depositModels = [DepositsBankModel cn_parse:responseObj];
        
        __block NSMutableArray *models = @[].mutableCopy;
        __block NSInteger xjkIdx = 0;
        __block NSInteger otherWalletIdx = 0;
        [depositModels enumerateObjectsUsingBlock:^(DepositsBankModel * _Nonnull bank, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([bank.bankname caseInsensitiveCompare:@"dcbox"] == NSOrderedSame) {
                bank.protocolList = self.depositProtocolList;
                [models addObject:bank];
                xjkIdx = models.count-1;
            }
            if ([HYRechargeHelper isUSDTOtherBankModel:bank]) {
                [models addObject:bank];
                otherWalletIdx = models.count-1;
            }
        }];
        // 将小金库排到第一位
        if (xjkIdx != 0) {
            [models exchangeObjectAtIndex:0 withObjectAtIndex:xjkIdx];
        }
        if (models.count == 0) {
            [CNTOPHUB showAlert:@"暂无可用充值渠道"];
            return;
        }
        self.depositModels = models;
        
        [self didTapTopDepositWayBtn:self->_xjkBtn];
    }];
}

/**
 提交充值
 */
- (IBAction)startDepositAction:(id)sender {
    DepositsBankModel *model = self.depositModels[_selIdx];
    if ([model.bankname isEqualToString:@"dcbox"]) {
        [CNRechargeRequest submitDCUsdtPayType:@"43"
                                       Payment:self.editorView.selectedProtocol
                                        amount:self.editorView.rechargeAmount
                                       handler:^(id responseObj, NSString *errorMsg) {
            if (KIsEmptyString(errorMsg) && [responseObj isKindOfClass:[NSDictionary class]]) {
                ChargeManualMessgeView *view;
                view = [[ChargeManualMessgeView alloc] initWithAddress:responseObj[@"address"] amount:self.editorView.rechargeAmount retelling:nil type:ChargeMsgTypeDCBOX];
                view.clickBlock = ^(BOOL isSure) {
                    [self.navigationController pushViewController:[CNTradeRecodeVC new] animated:YES];
                };
                [kKeywindow addSubview:view];
            }
        }];
//        [CNRechargeRequest submitOnlinePayOrderV2Amount:self.editorView.rechargeAmount
//                                               currency:model.currency
//                                           usdtProtocol:self.editorView.selectedProtocol
//                                                payType:model.payType
//                                                handler:^(id responseObj, NSString *errorMsg) {
//            
//            if (KIsEmptyString(errorMsg) && [responseObj isKindOfClass:[NSDictionary class]]) {
//                ChargeManualMessgeView *view;
//                view = [[ChargeManualMessgeView alloc] initWithAddress:responseObj[@"address"] amount:self.editorView.rechargeAmount retelling:nil type:ChargeMsgTypeDCBOX];
//                view.clickBlock = ^(BOOL isSure) {
//                    [self.navigationController pushViewController:[CNTradeRecodeVC new] animated:YES];
//                };
//                [kKeywindow addSubview:view];
//            }
//        }];
    } else {
        [CNRechargeRequest submitOtherUsdtPayment:self.editorView.selectedProtocol amount:self.editorView.rechargeAmount handler:^(id responseObj, NSString *errorMsg) {
            if (KIsEmptyString(errorMsg) && [responseObj isKindOfClass:[NSDictionary class]]) {
                ChargeManualMessgeView *view;
                view = [[ChargeManualMessgeView alloc] initWithAddress:responseObj[@"address"] amount:self.editorView.rechargeAmount retelling:nil type:ChargeMsgTypeOTHERS];
                view.clickBlock = ^(BOOL isSure) {
                    [self.navigationController pushViewController:[CNTradeRecodeVC new] animated:YES];
                };
                [kKeywindow addSubview:view];
            }
        }];
    }
}



@end
