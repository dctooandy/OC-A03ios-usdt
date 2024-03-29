//
//  CNNormalInputView.h
//  HYNewNest
//
//  Created by cean.q on 2020/8/3.
//  Copyright © 2020 james. All rights reserved.
//

#import "CNBaseXibView.h"

NS_ASSUME_NONNULL_BEGIN

@class CNNormalInputView;
@protocol CNNormalInputViewDelegate
- (void)inputViewTextChange:(CNNormalInputView *)view;
@optional
- (void)inputViewDidEndEditing:(CNNormalInputView *)view;

- (void)pickerViewDidEndEditing:(CNNormalInputView *)view index:(NSInteger)index;
@end


@interface CNNormalInputView : CNBaseXibView
/// 文本框的内容
@property (nonatomic, copy) NSString *text;
/// 记录对错，用于UI改变风格
@property (assign, nonatomic) BOOL wrongAccout;
@property (nonatomic, weak) id delegate;


/// 错误提示
- (void)showWrongMsg:(NSString *)msg;
/// 设置输入框占位符显示内容
- (void)setPlaceholder:(NSString *)text;
/// 设置键盘样式
- (void)setKeyboardType:(UIKeyboardType)keyboardType;
/// 可编辑设定
- (void)editAble:(BOOL)editable;
///设定字体颜色
- (void)setTextColor:(UIColor *)color;
///回复预设值
- (void)setStatusToNormal;
///设定输入框背景色
- (void)setInputBackgoundColor: (UIColor *)color;

- (void)setPrefixText: (NSString *)text;

-(void)setPicker:(NSString *)titleStr arr:(NSArray *)arr;
-(void)removeTap;

@end

NS_ASSUME_NONNULL_END
