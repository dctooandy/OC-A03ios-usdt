//
//  DSBProfitBoardDataSource.m
//  HYNewNest
//
//  Created by zaky on 12/24/20.
//  Copyright © 2020 BYGJ. All rights reserved.
//

#import "DSBProfitBoardDataSource.h"
#import "DSBProfitBoardCell.h"
#import "DSBProfitFooter.h"
#import "DSBProfitHeader.h"
#import "DSBGameRoundResModel.h"
#import "HYDSBSlideUpView.h"

#import "DashenBoardRequest.h"
#import "HYInGameHelper.h"
#import "SocketRocketUtility.h"
#import "BYJSONHelper.h"

NSString *const ProfitCellId = @"DSBProfitBoardCell";
NSString *const ProfitFooterId = @"DSBProfitFooter";
NSString *const ProfitHeaderId = @"DSBProfitHeader";

@interface DSBProfitBoardDataSource () <UITableViewDelegate, UITableViewDataSource>
{
    BOOL _isAsking;
    NSInteger _retryTimes;
}

@property (weak,nonatomic) id<DashenBoardAutoHeightDelegate> delegate; // 高度代理
@property (weak,nonatomic) UITableView *tableView;

// 请求一次就好了
@property (strong,nonatomic) NSArray <DSBProfitBoardUsrModel *> *usrModels;
// 动态表单推荐桌台
@property (copy,nonatomic) NSString *recomTableId;
// 当前露珠展示桌台
@property (copy,nonatomic) NSString *showTableId;
@end

@implementation DSBProfitBoardDataSource

- (instancetype)initWithDelegate:(id)delegate TableView:(UITableView *)tableView{
    
    self = [super init];
    _isAsking = NO;
    _retryTimes = 0;
    _delegate = delegate;
    _curPage = 0;
    
    // setup tableview
    tableView.backgroundColor = kHexColor(0x1C1B34);
    [tableView registerNib:[UINib nibWithNibName:ProfitCellId bundle:nil] forCellReuseIdentifier:ProfitCellId];
    [tableView registerNib:[UINib nibWithNibName:ProfitFooterId bundle:nil] forHeaderFooterViewReuseIdentifier:ProfitFooterId];
    [tableView registerNib:[UINib nibWithNibName:ProfitHeaderId bundle:nil] forHeaderFooterViewReuseIdentifier:ProfitHeaderId];
    tableView.dataSource = self;
    tableView.delegate = self;
    _tableView = tableView;
    
    // setup timer
    // GCD定时器
    static dispatch_source_t _timer;
    //设置刷新间隔 5 分钟
    NSTimeInterval period = 60*5.0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self requestYinliRank];
        });
    });
    // 开启定时器
    dispatch_resume(_timer);
        
    return self;
}

- (void)setupWebSocket {
//    NSString *wsURL = @"wss://roadmap.9mbv.com:7070/socket.io/?EIO=4&transport=websocket"; //https
    NSString *wsURL = @"ws://roadmap.9mbv.com:8080/socket.io/?EIO=4&transport=websocket";
    [[SocketRocketUtility instance] SRWebSocketOpenWithURLString:wsURL];
    
    // 防止重复添加监听者
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self addObserverAndHandleData];
    });
    
}

- (void)addObserverAndHandleData {
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:BYWebSocketDidReceivedNoti object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSString *dictStr = note.object;
        
        if (dictStr.length < 5 || [dictStr hasPrefix:@"0{\"sid\":"] ||
            ([[SocketRocketUtility instance] socketReadyState] == SR_CLOSING ||
             [[SocketRocketUtility instance] socketReadyState] == SR_CLOSED)) { //无用数据 或 无socket连接
            return;
        }
        NSRange startRng = [dictStr rangeOfString:@"["];
        NSString *jsonStr = [dictStr substringFromIndex:startRng.location];
        id fullArr = [BYJSONHelper dictOrArrayWithJsonString:jsonStr];
        if ([fullArr isKindOfClass:[NSDictionary class]]) { // 如果是字典 无用数据
            return;
        }
        // 数组只有两个参数 第二个是主要数据  我们主要处理 @"result list" & @"close round"
        if ([fullArr[0] isEqualToString:@"result list"]) { // 所有游戏数据
            NSLog(@"------------------------ allDict save to DB");
            kPreventRepeatTime(5);
            NSString *allDictStr = fullArr[1];
            NSDictionary *allDict = [BYJSONHelper dictOrArrayWithJsonString:allDictStr];
            for (NSString *vid in allDict.allKeys) {
                DSBGameRoundResModel *vModel = [DSBGameRoundResModel cn_parse:allDict[vid]];
                [vModel bg_saveOrUpdateAsync:^(BOOL isSuccess) {
                    dispatch_async(dispatch_get_main_queue(), ^{ @autoreleasepool {
                        [weakSelf.tableView reloadData];
                    }});
                }];
            }
            
        } else if ([fullArr[0] containsString:@"close round"]){ // 更新游戏数据
            RoundPushModel *nround = [RoundPushModel cn_parse:fullArr[1]];
            NSString* where = [NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"vid"), bg_sqlValue(nround.vid)];
            [DSBGameRoundResModel bg_findAsync:DBName_DSBGameRoundResults where:where complete:^(NSArray * _Nullable array) {
                if (array.count) {
                    DSBGameRoundResModel *model = array.firstObject;
                    NSMutableDictionary *roundReses = model.roundRes.mutableCopy;
                    roundReses[nround.gmcode] = [nround makeRoundResItem]; //添加一条
                    model.roundRes = roundReses.copy;
                    [model bg_saveOrUpdateAsync:^(BOOL isSuccess) {
                        if([nround.vid isEqualToString:weakSelf.showTableId]) {
                            MyLog(@"------------------------ Found:%@, update DB & RefreshView", nround.vid);
                            //返回主线程
                            dispatch_async(dispatch_get_main_queue(), ^{ @autoreleasepool {
                                [weakSelf.tableView reloadData];
                            }});

                        }
                    }];
                }
            }];

        }
    }];
}


#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.usrModels.count && [self.usrModels[0] prList].count) {
        DSBProfitBoardUsrModel *usr = self.usrModels[_curPage];
        return usr.prList.count > 2 ? 2 : usr.prList.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DSBProfitBoardCell *cell = (DSBProfitBoardCell*)[tableView dequeueReusableCellWithIdentifier:ProfitCellId];
    if (self.usrModels.count) {
        DSBProfitBoardUsrModel *usr = self.usrModels[_curPage];
        PrListItem *item = usr.prList[indexPath.row];
        [cell setupPrListItem:item];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 115;//固定
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DSBProfitHeader *header = (DSBProfitHeader *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:ProfitHeaderId];
    
    //db
    if (self.showTableId) {
        NSString* where = [NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"vid"), bg_sqlValue(self.showTableId)];
        [DSBGameRoundResModel bg_findAsync:DBName_DSBGameRoundResults where:where complete:^(NSArray * _Nullable array) {
            if (array.count) {
                DSBGameRoundResModel *m = array[0];
                //返回主线程
                dispatch_async(dispatch_get_main_queue(), ^{ @autoreleasepool {
                    [header setupDrewsWith:m.roundRes];
                }});
            }
        }];
    }
    
    //user
    if (self.usrModels.count) {
        DSBProfitBoardUsrModel *usr = self.usrModels[_curPage];
        header.nameLbl.text = usr.loginName;
        header.tableCodeLbl.text = [NSString stringWithFormat:@"经典百家乐 %@桌", self.showTableId?:@"D000"];
        header.rankLbl.text = usr.writtenLevel;
        if (usr.prList.count) {
            header.profitCucLbl.text = [NSString stringWithFormat:@"%@%@",
                                        [usr.cusAmountSum jk_toDisplayNumberWithDigit:2],
                                        usr.prList[0].currency.lowercaseString];
        }
        header.toprightTapImgv.image = usr.isOnTable?[UIImage imageNamed:@"zaizhuo"]:[UIImage imageNamed:@"tuijian"];
    }
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kDewBall_WH*6+117;//固定
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    DSBProfitFooter *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:ProfitFooterId];
    if (self.usrModels.count) {
        DSBProfitBoardUsrModel *usr = self.usrModels[_curPage];
        if (self.usrModels.count) {
            if (usr.prList.count == 0) {
                footer.isUsrOnline = NO;
                footer.btmBtnClikBlock = nil;
                footer.btmBtnClikHistoryBlock = nil;
            } else {
                footer.isUsrOnline = usr.prList[0].isOnline;
                footer.btmBtnClikBlock = ^{
                    [[HYInGameHelper sharedInstance] inBACGameTableCode:self.showTableId];
                };
                footer.btmBtnClikHistoryBlock = ^{
                    [HYDSBSlideUpView showSlideupYLBView:usr.prList];
                };
            }
        }
    } else {
        footer.isUsrOnline = NO;
        footer.btmBtnClikBlock = nil;
        footer.btmBtnClikHistoryBlock = nil;
    }
    return footer;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 128;//固定
}


#pragma mark - Request

/// 盈利榜
- (void)requestYinliRank {
    if (_isAsking) {
        MyLog(@"~~~~~> [推荐桌台] 正在请求中。。。");
        return;
    }
    _isAsking = YES; //正在请求
    [LoadingView showLoadingViewWithToView:self.tableView needMask:YES];
    
    /// 推荐桌台号
    [DashenBoardRequest requestRecommendTableHandler:^(id responseObj, NSString *errorMsg) {
        
        if (!errorMsg && [responseObj isKindOfClass:[NSString class]]) {
            self.recomTableId = self.showTableId = responseObj;
            [self requestList];
            
        } else {
            [LoadingView hideLoadingViewForView:self.tableView];
            [self performSelector:@selector(requestYinliRank) withObject:nil afterDelay:5];
            self->_isAsking = NO;
        }
    }];
        
}

/// 盈利榜单列表
- (void)requestList {
    MyLog(@"~~~~~> [盈利榜] 重试次数：%ld（超过五次不再请求）", _retryTimes+1);
    if (_retryTimes > 4) {
        return;
    }
    
    [DashenBoardRequest requestProfitPageNo:1 handler:^(id responseObj, NSString *errorMsg) {
        [LoadingView hideLoadingViewForView:self.tableView];
        
        if (!errorMsg && [responseObj isKindOfClass:[NSDictionary class]]) {
            NSArray *orgData = responseObj[@"data"];
            self.usrModels = [DSBProfitBoardUsrModel cn_parse:orgData];
            [self.tableView reloadData];
            
            // clear data
            [DSBGameRoundResModel bg_drop:DBName_DSBGameRoundResults];
            // setup webSocket
            [self setupWebSocket];
            
            self->_retryTimes = 0;
            self->_isAsking = NO;
            
        } else {
            [self performSelector:@selector(requestList) withObject:nil afterDelay:5];
            self->_retryTimes += 1;
            self->_isAsking = NO;
        }
    }];
}


#pragma mark - Setter

- (void)setType:(DashenBoardType)type {
    _type = type;
    if (!self.usrModels.count) {
        [self requestYinliRank];
    }
    
    if (self.delegate) {
        [self.delegate didSetupDataGetTableHeight:(kDewBall_WH*6+118 + 129 + 114*2)]; //tableview height
    }
}

- (void)setCurPage:(NSInteger)curPage {
    if (!self.usrModels.count) {
        _curPage = 0;
        return;
    }
    
    // animation
    CATransition *animation = [CATransition animation];
    animation.duration = 0.3;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    //    animation.type = kCATransitionFade;
    if (curPage < _curPage) {
        animation.type = kCATransitionReveal;
        animation.subtype = kCATransitionFromLeft;
    } else {
        animation.type = kCATransitionMoveIn;
        animation.subtype = kCATransitionFromRight;
    }
    [self.tableView.layer addAnimation:animation forKey:nil];
    
    // 处理益出
    if (curPage < 0) {
        curPage = self.usrModels.count - 1;
    } else if (curPage > self.usrModels.count - 1) {
        curPage = 0;
    }
    
    // 如果当前用户在线 绘制他的桌台
    DSBProfitBoardUsrModel *usr = self.usrModels[curPage];
    if (usr.prList.count) {
        PrListItem *nearItem = usr.prList[0];
        if (nearItem.isOnline) {
            self.showTableId = nearItem.tableCode;
        } else {
            self.showTableId = self.recomTableId;
        }
        MyLog(@"CURPAGE:%ld, usrName:%@, isOnlie:%ld", curPage, usr.loginName, nearItem.isOnline);
    } else {
        self.showTableId = self.recomTableId;
        MyLog(@"CURPAGE:%ld, usrName:%@, 盈利列表无数据！？", curPage, usr.loginName);
    }
    
    _curPage = curPage;
    
    [self.tableView reloadData];
}


@end
