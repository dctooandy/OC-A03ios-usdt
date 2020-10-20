//
//  HYBuyECoinGuideVC.m
//  HYNewNest
//
//  Created by zaky on 10/15/20.
//  Copyright © 2020 emneoma.xyz. All rights reserved.
//

#import "HYBuyECoinGuideVC.h"
#import "CNBaseNetworking.h"
#import "CNTwoStatusBtn.h"
#import "BuyECoinModel.h"
#import "LTSegmentedBar.h"
#import "CNRechargeRequest.h"
#import <SDWebImageDownloader.h>
#import "HYRechargeHelper.h"
#import "ChargeManualMessgeView.h"
#import "HYBuyECoinComfirmView.h"
#import "CNTradeRecodeVC.h"

@interface HYBuyECoinGuideVC ()<LTSegmentedBarDelegate>

@property (nonatomic, assign) NSInteger curIdx;
@property (weak, nonatomic) IBOutlet UIView *topBtnsBgView;
@property (nonatomic, strong) LTSegmentedBar *segmentedBar;

@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;

@property (weak, nonatomic) IBOutlet CNTwoStatusBtn *btnRecharge;
@property (weak, nonatomic) IBOutlet CNTwoStatusBtn *btnRegister;

@property (weak, nonatomic) IBOutlet UIView *topTagsContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topTagsContainHeightCons;

@property (nonatomic, strong) NSMutableArray *downloadTokens;
@property (strong,nonatomic) NSArray<BuyECoinModel*> *datas;


@property (nonatomic, strong) NSArray<DepositsBankModel *> *depositModels;
@property (nonatomic, strong) OnlineBanksModel *curOnliBankModel;
@property (nonatomic, assign, readwrite) NSInteger selcPayWayIdx;
@end

@implementation HYBuyECoinGuideVC

- (LTSegmentedBar *)segmentedBar {
    if (!_segmentedBar) {
        LTSegmentedBar *segmentBar = [LTSegmentedBar segmentedBarWithFrame:CGRectZero];
        segmentBar.delegate = self;
        segmentBar.backgroundColor = [UIColor clearColor];
        segmentBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, _topBtnsBgView.height);
        // Setup SegmentedBar Configuration here
        [segmentBar updateWithConfig:^(LTSegmentedBarConfig *config) {
            config.itemNormalColor = kHexColor(0x6D778B);
            config.itemSelectColor = [UIColor whiteColor];
            config.itemNormalFont = [UIFont fontPFR13];
            config.itemSelectFont = [UIFont fontPFSB16];
            config.indicatorHeight = 0;
//            config.indicatorWidth = 20;
//            config.indicatorColor = [UIColor whiteColor];
            config.splitLineColor = kHexColor(0x6D778B);
            config.itemWidthFit = YES;
        }];
        
        [_topBtnsBgView addSubview:segmentBar];
        _segmentedBar = segmentBar;
        
    }
    return _segmentedBar;
}


#pragma mark - VIEW LIFE

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"买币指南";
    [self addNaviRightItemWithImageName:@"service"];
    [self setupAttributes];
    _curIdx = 0;
    self.downloadTokens = @[].mutableCopy;
    
    [self getDynamicData];
    [self queryDepositBankPayWays];
}

- (void)rightItemAction {
    [NNPageRouter jump2Live800Type:CNLive800TypeDeposit];
}


#pragma mark - SETUP

- (void)setupAttributes {
    _topBtnsBgView.backgroundColor = _topTagsContainer.backgroundColor = kHexColor(0x212137);
    _btnRecharge.enabled = YES;
    _btnRegister.enabled = YES;
    _contentScrollView.backgroundColor = kHexColor(0x161627);
}

- (void)setupViewDatas {
    if (!self.datas.count) {
        return;
    }
    // 头部
    NSMutableArray *names = @[].mutableCopy;
    for (BuyECoinModel *model in self.datas) {
        [names addObject:model.name];
    }
    [self.segmentedBar setItems:names];
    self.segmentedBar.selectedIndex = 0;
    // 标签
    [self setupTags];
    // 内容
    [self setupContent];
}

- (void)setupTags {
    for (UIView *subView in _topTagsContainer.subviews) {
        [subView removeFromSuperview];
    }
    BuyECoinModel *model = self.datas[_curIdx];
    NSArray *tags = [model.label componentsSeparatedByString:@";"];
    
    CGFloat leftSpace = AD(12);
    CGFloat btnSpace = AD(10);
    CGFloat maxX = leftSpace;
    CGFloat maxY = AD(5);
    for (NSString *tag in tags) {
        UIButton *tagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [tagBtn setTitle:tag forState:UIControlStateNormal];
        [tagBtn setImage:[UIImage imageNamed:@"checked"] forState:UIControlStateNormal];
        tagBtn.titleLabel.font = [UIFont fontPFR12];
        [tagBtn setTitleColor:kHexColor(0xFFFFFF) forState:UIControlStateNormal];
        tagBtn.userInteractionEnabled = NO;
        tagBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        tagBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 3);
        [tagBtn sizeToFit];
        //tagBtn.width + 25 -- 按钮宽
        if (maxX + tagBtn.width + 35 > (kScreenWidth - AD(24))) {
            maxX = leftSpace;
            maxY = maxY + 30 + btnSpace;
        }
        tagBtn.frame = CGRectMake(maxX, maxY, tagBtn.width + 35, 30);
        maxX = CGRectGetMaxX(tagBtn.frame) + btnSpace;
        tagBtn.backgroundColor = kHexColor(0x161627);
        tagBtn.layer.masksToBounds = YES;
        tagBtn.layer.cornerRadius = 15;
        [_topTagsContainer addSubview:tagBtn];
    }
    _topTagsContainHeightCons.constant = maxY + 30 + 15;
}

- (void)setupContent {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    for (UIView *subView in _contentScrollView.subviews) {
        [subView removeFromSuperview];
    }
    
    
    BuyECoinModel *model = self.datas[_curIdx];
    NSArray *imgURLs = [model.imgList componentsSeparatedByString:@";"];
    NSMutableArray *imgs = @[].mutableCopy;
    
    [LoadingView show];
    [self downloadImage:imgURLs arrayImages:imgs currentIndex:0 success:^(NSArray<NSData *> *resultImages) {
        
        [LoadingView hide];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            CGFloat maxY = 0;
            for (int i=0; i<resultImages.count; i++) {
                UIImage *img = [UIImage imageWithData:resultImages[i]];
                UIImageView *imgv = [UIImageView new];
                imgv.frame = CGRectMake(0, maxY, kScreenWidth-8, img.size.height*(kScreenWidth-8)/img.size.width);
                imgv.image = img;
                maxY = CGRectGetMaxY(imgv.frame);
                [self.contentScrollView addSubview:imgv];
                
            }
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            self.contentScrollView.contentSize = CGSizeMake(0, maxY);
        });
        
        
    } failure:^{
        [LoadingView hide];
        [CNHUB showError:@"下载指南失败 获取图片出错"];
    }];
    

    
}

//递归按序下载图片
- (void)downloadImage:(NSArray <NSString *> *)arrayURLs arrayImages:(NSMutableArray<NSData *> *)arrayImages currentIndex:(NSUInteger)index success:(void (^)(NSArray <NSData *> *resultImages))success failure:(void (^)(void))failure {
   
    __block NSUInteger currentIndex = index;
   
    //这里使用 weakself, 在控制器销毁的时候, 当前下载任务完成后,就不会继续下一个任务, 如果使用 self, 那么当控制器销毁的时候, SD 会继续下载直到所有任务完成
    __weak typeof(self) weakSelf = self;
   
    NSString *stringurl = arrayURLs[currentIndex];
   
    NSURL *url = [NSURL URLWithString:stringurl];
        
    SDWebImageDownloadToken *token = [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
       
        float p = receivedSize / (expectedSize * 1.0);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            weakSelf.progressView.progress = p;
//        });
        NSLog(@"当前索引 %lu, 当前进度: %f", (unsigned long)currentIndex, p);
       
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        currentIndex++;
       
        if (finished && !error && data) {  //下载结束并且没有出错
            [arrayImages addObject:data];
           
//            weakSelf.imageView.image = image;
        }
       
        if (currentIndex == arrayURLs.count) { //停止递归下载
            
            if(arrayImages.count > 0){  //当数组有元素存在,认为是成功, 也可以只写一个回调block, 不区分成功与失败
                if(success){
                    success(arrayImages);
                }
            }else{
                if(failure){
                    failure();
                }
            }
            return;
        } else {
            //继续递归下载
            [weakSelf downloadImage:arrayURLs arrayImages:arrayImages currentIndex:currentIndex success:success failure:failure];
        }
    }];
    if (token) [self.downloadTokens addObject:token];
}


#pragma mark - setter
- (void)setCurIdx:(NSInteger)curIdx {
    if (_curIdx != curIdx) {
        _curIdx = curIdx;
        [self setupTags];
        for (SDWebImageDownloadToken *token in self.downloadTokens) {
            [token cancel];
        }
        [self.downloadTokens removeAllObjects];
        [self setupContent];
    }
}


#pragma mark - Action
- (IBAction)didTapRechargeECoin:(id)sender {
    HYBuyECoinComfirmView *view = [[HYBuyECoinComfirmView alloc] initWithDepositModels:self.depositModels switchHandler:^(NSInteger idx) {
        self.selcPayWayIdx = idx;
        [self queryOnlineBankAmount];
    } submitHandler:^(NSString *amount) {
        [self submitUSDTRequest:amount];
    }];
    [self.view addSubview:view];
    [view show];
    
}

- (IBAction)didTapRegisterBtn:(id)sender {
    BuyECoinModel *model = self.datas[_curIdx];
    NSURL *url = [NSURL URLWithString:model.registerUrl];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            [CNHUB showSuccess:@"请在外部浏览器查看"];
        }];
    }
}


#pragma mark - LTSegmentedBarDelegate

- (void)segmentBar:(LTSegmentedBar *)segmentedBar didSelectIndex:(NSInteger)toIndex fromIndex:(NSInteger)fromIndex
{
    self.curIdx = toIndex;
}


#pragma mark - Request

- (void)getDynamicData {
    NSMutableDictionary *param = [kNetworkMgr baseParam];
    [param setObject:@"MAIBI_GUIDE" forKey:@"bizCode"];
    [CNBaseNetworking POST:kGatewayPath(config_dynamicQuery) parameters:param completionHandler:^(id responseObj, NSString *errorMsg) {
        if (KIsEmptyString(errorMsg) && [responseObj isKindOfClass:[NSDictionary class]]) {
            NSArray *data = [responseObj objectForKey:@"data"];
            self.datas = [BuyECoinModel cn_parse:data];
            [self setupViewDatas];
        }
    }];
    
}

/**
USDT支付渠道
*/
- (void)queryDepositBankPayWays {
    [CNRechargeRequest queryUSDTPayWalletsHandler:^(id responseObj, NSString *errorMsg) {
        NSArray *depositModels = [DepositsBankModel cn_parse:responseObj];
        NSMutableArray *models = @[].mutableCopy;
        for (DepositsBankModel *bank in depositModels) {
            if (([bank.bankname isEqualToString:@"dcbox"] || [HYRechargeHelper isUSDTOtherBankModel:bank])) {
                [models addObject:bank];
            }
        }
        self.depositModels = models;
        self.selcPayWayIdx = 0;

    }];
}

/**
在线类支付 需要
*/
- (void)queryOnlineBankAmount {
    DepositsBankModel *model = self.depositModels[_selcPayWayIdx];
    [CNRechargeRequest queryOnlineBanksPayType:model.payType
                                  usdtProtocol:@"ERC20"
                                       handler:^(id responseObj, NSString *errorMsg) {
        if (KIsEmptyString(errorMsg) && [responseObj isKindOfClass:[NSDictionary class]]) {
            OnlineBanksModel *oModel = [OnlineBanksModel cn_parse:responseObj];
            self.curOnliBankModel = oModel;
        }
    }];
}

- (void)submitUSDTRequest:(NSString *)amount {
    DepositsBankModel *model = self.depositModels[_selcPayWayIdx];
    
    if ([HYRechargeHelper isUSDTOtherBankModel:model]) {
        [CNRechargeRequest submitOnlinePayOrderV2Amount:amount
                                               currency:model.currency
                                           usdtProtocol:@"ERC20"
                                                payType:model.payType
                                                handler:^(id responseObj, NSString *errorMsg) {
            
            if (KIsEmptyString(errorMsg) && [responseObj isKindOfClass:[NSDictionary class]]) {
                ChargeManualMessgeView *view = [[ChargeManualMessgeView alloc] initWithAddress:responseObj[@"address"] retelling:nil type:ChargeMsgTypeOTHERS];
                view.clickBlock = ^(BOOL isSure) {
                    [self.navigationController pushViewController:[CNTradeRecodeVC new] animated:YES];
                };
                [kKeywindow addSubview:view];
            }
        }];
        
    } else {
        [CNRechargeRequest submitOnlinePayOrderAmount:amount
                                             currency:model.currency
                                         usdtProtocol:@"ERC20"
                                              payType:model.payType
                                                payid:self.curOnliBankModel.payid
                                           showQRCode:1
                                              handler:^(id responseObj, NSString *errorMsg) {
            
            if (KIsEmptyString(errorMsg) && [responseObj isKindOfClass:[NSDictionary class]]) {
                ChargeManualMessgeView *view = [[ChargeManualMessgeView alloc] initWithAddress:responseObj[@"payUrl"] retelling:nil type:[HYRechargeHelper isUSDTOtherBankModel:model]?ChargeMsgTypeOTHERS:ChargeMsgTypeDCBOX];
                view.clickBlock = ^(BOOL isSure) {
                    [self.navigationController pushViewController:[CNTradeRecodeVC new] animated:YES];
                };
                [kKeywindow addSubview:view];
            }
        }];
    }
}


@end
