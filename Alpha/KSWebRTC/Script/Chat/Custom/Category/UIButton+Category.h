//
//  UIButton+Category.h
//  KSWebRTC
//
//  Created by saeipi on 2020/7/10.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Category)

+ (UIButton *)ks_buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font backgroundColor:(UIColor *)backgroundColor borderColor:(UIColor *)borderColor borderWidth:(CGFloat )borderWidth;

/**
 创建普通按钮【normal/highlighted 前景图】
 */
+ (instancetype)ks_buttonWithNormalImg:(NSString *)normalImg highlightedImg:(NSString *)highlightedImg width:(CGFloat)width height:(CGFloat)height;
/**
 创建背景模式按钮【normal/highlighted 背景图】
 */
+ (instancetype)ks_buttonWithBackgroundNormalImg:(NSString *)normalImg highlightedImg:(NSString *)highlightedImg width:(CGFloat)width height:(CGFloat)height;
/**
 创建普通按钮【normal/highlighted/selected 前景图】
 */
+ (instancetype)ks_buttonWithNormalImg:(NSString *)normalImg highlightedImg:(NSString *)highlightedImg selectedImg:(NSString *)selectedImg width:(CGFloat)width height:(CGFloat)height;
/**
 创建背景模式按钮【normal/highlighted/selected 背景图】
 */
+ (instancetype)ks_buttonWithBackgroundNormalImg:(NSString *)normalImg highlightedImg:(NSString *)highlightedImg selectedImg:(NSString *)selectedImg width:(CGFloat)width height:(CGFloat)height;

/**
 创建最普通的按钮
 */
+ (instancetype)ks_buttonWithNormalImg:(NSString *)normalImg highlightedImg:(NSString *)highlightedImg;

/**
 创建背景模式按钮【背景图+标题】
 */
+ (instancetype)ks_buttonWithBackgroundImg:(NSString *)backgroundImg title:(NSString *)title font:(int)font;

/**
 设置普通图片
 */
-(void)ks_setNormalImg:(NSString *)normalImg highlightedImg:(NSString *)highlightedImg;

/**
 创建只有Normal图片的普通按钮
 */
+ (instancetype)ks_buttonWithNormalImg:(NSString *)normalImg;
/**
 创建安娜
 
 @param normalImg 默认图片
 @param selectImg 选择图片
 @return UIButton
 */
+ (instancetype)ks_buttonWithNormalImg:(NSString *)normalImg selectImg:(NSString *) selectImg;
/**
 文字按钮
 */
+ (instancetype)ks_buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor bgColor:(UIColor *)bgColor font:(int)font isBold:(BOOL)isBold;
/**
 创建圆角按钮
 */
+ (instancetype)ks_buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor bgColor:(UIColor *)bgColor radius:(CGFloat)radius font:(int)font isBold:(BOOL)isBold;
/**
 创建文字按钮
 */
+ (instancetype)ks_buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor;

/**
 创建文字按钮
 */
+ (instancetype)ks_buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(int)font isBold:(BOOL)isBold;
/**
 创建文字图片按钮
 */
+ (instancetype)ks_buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(int)font isBold:(BOOL)isBold normalImg:(NSString *)normalImg;
//- (void)playAnimation;
- (void)ks_addTarget:(id)target action:(SEL)action;
- (void)ks_addTouchEventForTarget:(id)target action:(SEL)action;
+(instancetype)ks_buttonWithTitle:(NSString *)title font:(int)font normalColor:(UIColor *)normalColor highlightedColor:(UIColor *)highlightedColor bgNormalColor:(UIColor *)bgNormalColor bgHighlightedColor:(UIColor *)bgHighlightedColor isBold:(BOOL)isBold;
-(void)ks_updateBackgroundImageFromNormalColor:(UIColor *)normalColor disabledColor:(UIColor *)disabledColor;

//MARK: - 实例化封装

/// 初始化按钮
/// @param title 文字
/// @param titleColor 文字颜色
/// @param font 文字大小
+ (UIButton *)ks_buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font;

+ (UIButton *)ks_buttonWithFrame:(CGRect)frame title:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font radius:(CGFloat)radius backgroundColor:(UIColor *)backgroundColor;

+ (UIButton *)ks_buttonWithFrame:(CGRect)frame titleColor:(UIColor *)titleColor font:(UIFont *)font radius:(CGFloat)radius backgroundColor:(UIColor *)backgroundColor;

@end
