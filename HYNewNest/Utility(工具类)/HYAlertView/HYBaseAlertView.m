//
//  HYBaseAlertView.m
//  HYNewNest
//
//  Created by Lenhulk on 2020/7/24.
//  Copyright © 2020 emneoma. All rights reserved.
//

#import "HYBaseAlertView.h"

@interface HYBaseAlertView ()


@end

@implementation HYBaseAlertView

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _bgView.backgroundColor = kHexColorAlpha(0x000000, 0.7);
        _bgView.alpha = 0;
    }
    return _bgView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = kHexColor(0x343452);
        _contentView.transform = CGAffineTransformMakeScale(0.2, 0.2);
        _contentView.alpha = 0;
    }
    return _contentView;
}

- (void)addupBasicView {
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.contentView];
}

- (void)show {
    [kKeywindow addSubview:self];
    [kKeywindow bringSubviewToFront:self];
    
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.bgView.alpha = 1.0;
        self.contentView.alpha = 1.0;
        self.contentView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.bgView.alpha = 0;
        self.contentView.alpha = 0;
        self.contentView.transform = CGAffineTransformMakeScale(0.2, 0.2);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}

- (instancetype)init {
    self = [super init];
    [self addupBasicView];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self addupBasicView];
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
