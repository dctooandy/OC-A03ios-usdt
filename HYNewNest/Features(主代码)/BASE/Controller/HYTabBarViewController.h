//
//  HYTabBarViewController.h
//  HYGEntire
//
//  Created by zaky on 24/10/2019.
//  Copyright © 2019 kunlun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYTabBarViewController : UITabBarController
-(void)hideSuspendBall;
-(void)showSuspendBall;
- (void)fetchUnreadCount;
- (void)setUnreadToDefault;
- (void)initOCSSSDKShouldReload:(BOOL)reload;

@property (nonatomic, assign) NSInteger unreadMessage;
@property (nonatomic, assign) BOOL hasNewBonus;

@end

NS_ASSUME_NONNULL_END
