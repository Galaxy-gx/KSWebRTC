//
//  UIButton+Category.m
//  KSWebRTC
//
//  Created by saeipi on 2020/7/10.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "UIButton+Category.h"

@implementation UIButton (Category)

+ (UIButton *)ks_buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font backgroundColor:(UIColor *)backgroundColor borderColor:(UIColor *)borderColor borderWidth:(CGFloat )borderWidth {
    UIButton *coolBtn         = [UIButton buttonWithType:UIButtonTypeCustom];
    [coolBtn setTitle:title forState:UIControlStateNormal];
    [coolBtn setTitleColor:titleColor forState:UIControlStateNormal];
    coolBtn.titleLabel.font   = font;
    coolBtn.layer.borderColor = borderColor.CGColor;
    coolBtn.layer.borderWidth = borderWidth;
    [coolBtn setBackgroundColor:backgroundColor];
    return coolBtn;
}

/**
 设置普通图片
 */
-(void)ks_setNormalImg:(NSString *)normalImg highlightedImg:(NSString *)highlightedImg
{
    [self setImage:[UIImage imageNamed:normalImg] forState:UIControlStateNormal];
    if (highlightedImg) {
        [self setImage:[UIImage imageNamed:highlightedImg] forState:UIControlStateHighlighted];
    }
    //[self setImage:[UIImage imageNamed:highlightedImg] forState:UIControlStateHighlighted];
}
/**
 设置背景图片
 */
-(void)ks_setBackgroundNormalImg:(NSString *)normalImg highlightedImg:(NSString *)highlightedImg
{
    [self setBackgroundImage:[UIImage imageNamed:normalImg] forState:UIControlStateNormal];
    //[self setBackgroundImage:[UIImage imageNamed:highlightedImg] forState:UIControlStateHighlighted];
}

/**
 设置选中状态的背景图片
 */
-(void)ks_setBackgroundSelectedImg:(NSString *)selectedImg {
    [self setBackgroundImage:[UIImage imageNamed:selectedImg] forState:UIControlStateSelected];
}

/**
 设置选中状态的普通图片
 */
-(void)ks_setSelectedImg:(NSString *)selectedImg {
    [self setImage:[UIImage imageNamed:selectedImg] forState:UIControlStateSelected];
}

/**
 创建普通按钮【normal/highlighted 前景图】
 */
+ (instancetype)ks_buttonWithNormalImg:(NSString *)normalImg highlightedImg:(NSString *)highlightedImg width:(CGFloat)width height:(CGFloat)height {
    UIButton *buttonCool = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonCool ks_setNormalImg:normalImg highlightedImg:highlightedImg];
    buttonCool.frame = CGRectMake(0, 0, width, height);
    return buttonCool;
}

/**
 创建背景模式按钮【normal/highlighted 背景图】
 */
+ (instancetype)ks_buttonWithBackgroundNormalImg:(NSString *)normalImg highlightedImg:(NSString *)highlightedImg width:(CGFloat)width height:(CGFloat)height {
    UIButton *buttonCool = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonCool ks_setBackgroundNormalImg:normalImg highlightedImg:highlightedImg];
    buttonCool.frame = CGRectMake(0, 0, width, height);
    return buttonCool;
}


/**
 创建普通按钮【normal/highlighted/selected 前景图】
 */
+ (instancetype)ks_buttonWithNormalImg:(NSString *)normalImg highlightedImg:(NSString *)highlightedImg selectedImg:(NSString *)selectedImg width:(CGFloat)width height:(CGFloat)height
{
    UIButton *buttonCool = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonCool ks_setNormalImg:normalImg highlightedImg:highlightedImg];
    [buttonCool ks_setSelectedImg:selectedImg];
    buttonCool.frame = CGRectMake(0, 0, width, height);
    return buttonCool;
}
/**
 创建背景模式按钮【normal/highlighted/selected 背景图】
 */
+ (instancetype)ks_buttonWithBackgroundNormalImg:(NSString *)normalImg highlightedImg:(NSString *)highlightedImg selectedImg:(NSString *)selectedImg width:(CGFloat)width height:(CGFloat)height {
    UIButton *buttonCool = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonCool ks_setBackgroundNormalImg:normalImg highlightedImg:highlightedImg];
    [buttonCool ks_setBackgroundSelectedImg:selectedImg];
    buttonCool.frame = CGRectMake(0, 0, width, height);
    return buttonCool;
}

/**
 创建最普通的按钮
 */
+ (instancetype)ks_buttonWithNormalImg:(NSString *)normalImg highlightedImg:(NSString *)highlightedImg {
    UIButton *buttonCool = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonCool ks_setNormalImg:normalImg highlightedImg:highlightedImg];
    //buttonCool.showsTouchWhenHighlighted = YES;
    return buttonCool;
}

/**
 创建背景模式按钮【背景图+标题】
 */
+ (instancetype)ks_buttonWithBackgroundImg:(NSString *)backgroundImg title:(NSString *)title font:(int)font {
    UIButton *buttonCool       = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonCool setBackgroundImage:[UIImage imageNamed:backgroundImg] forState:UIControlStateNormal];
    [buttonCool setTitleColor:[UIColor ks_colorWithHexString:@"#f9ecb8"] forState:UIControlStateNormal];
    [buttonCool setTitle:title forState:UIControlStateNormal];
    buttonCool.titleLabel.font = [UIFont systemFontOfSize:font];
    return buttonCool;
}

/**
 创建只有Normal图片的普通按钮
 */
+ (instancetype)ks_buttonWithNormalImg:(NSString *)normalImg {
    UIButton *buttonCool = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonCool setImage:[UIImage imageNamed:normalImg] forState:UIControlStateNormal];
    //buttonCool.showsTouchWhenHighlighted = YES;
    return buttonCool;
}

/**
 创建安娜
 
 @param normalImg 默认图片
 @param selectImg 选择图片
 @return UIButton
 */
+ (instancetype)ks_buttonWithNormalImg:(NSString *)normalImg selectImg:(NSString *) selectImg{
    UIButton *buttonCool = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonCool setImage:[UIImage imageNamed:normalImg] forState:UIControlStateNormal];
    [buttonCool setImage:[UIImage imageNamed:selectImg] forState:UIControlStateSelected];
    return buttonCool;
}

/**
 文字按钮
 */
+ (instancetype)ks_buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor bgColor:(UIColor *)bgColor font:(int)font isBold:(BOOL)isBold {
    UIButton *buttonCool             = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonCool setTitle:title.localizde forState:UIControlStateNormal];
    [buttonCool setTitleColor:titleColor forState:UIControlStateNormal];
    buttonCool.layer.backgroundColor = bgColor.CGColor;
    
    if (isBold) {
        buttonCool.titleLabel.font    = [UIFont boldSystemFontOfSize:font];//[UIFont fontWithName:@"Helvetica-Bold" size:font];
    }
    else{
        buttonCool.titleLabel.font    = [UIFont systemFontOfSize:font];
    }
    
    return buttonCool;
}

/**
 创建圆角按钮
 */
+ (instancetype)ks_buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor bgColor:(UIColor *)bgColor radius:(CGFloat)radius font:(int)font isBold:(BOOL)isBold {
    UIButton *buttonCool             = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonCool setTitle:title.localizde forState:UIControlStateNormal];
    [buttonCool setTitleColor:titleColor forState:UIControlStateNormal];
    if (bgColor) {
        buttonCool.layer.backgroundColor = bgColor.CGColor;
    }
    buttonCool.layer.cornerRadius    = radius;
    
    if (isBold) {
        buttonCool.titleLabel.font   = [UIFont boldSystemFontOfSize:font];//[UIFont fontWithName:@"Helvetica-Bold" size:font];
    }
    else{
        buttonCool.titleLabel.font   = [UIFont systemFontOfSize:font];
    }
    
    return buttonCool;
}

+(instancetype)ks_buttonWithTitle:(NSString *)title font:(int)font normalColor:(UIColor *)normalColor highlightedColor:(UIColor *)highlightedColor bgNormalColor:(UIColor *)bgNormalColor bgHighlightedColor:(UIColor *)bgHighlightedColor isBold:(BOOL)isBold {
    UIButton *buttonCool = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonCool setTitle:title.localizde forState:UIControlStateNormal];
    
    [buttonCool setTitleColor:normalColor forState:UIControlStateNormal];
    [buttonCool setTitleColor:highlightedColor forState:UIControlStateHighlighted];
    
    [buttonCool setBackgroundImage:[UIColor ks_imageWithColor:bgNormalColor] forState:UIControlStateNormal];
    [buttonCool setBackgroundImage:[UIColor ks_imageWithColor:bgHighlightedColor] forState:UIControlStateHighlighted];
    
    if (isBold) {
        buttonCool.titleLabel.font    = [UIFont boldSystemFontOfSize:font];
    }
    else{
        buttonCool.titleLabel.font    = [UIFont systemFontOfSize:font];
    }
    return buttonCool;
}

/**
 创建文字按钮
 */
+ (instancetype)ks_buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor {
    UIButton *buttonCool           = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonCool setTitle:title.localizde forState:UIControlStateNormal];
    [buttonCool setTitleColor:titleColor forState:UIControlStateNormal];
    return buttonCool;
}

/**
 创建文字按钮
 */
+ (instancetype)ks_buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(int)font isBold:(BOOL)isBold{
    UIButton *buttonCool           = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonCool setTitle:title.localizde forState:UIControlStateNormal];
    [buttonCool setTitleColor:titleColor forState:UIControlStateNormal];
    if (isBold) {
        buttonCool.titleLabel.font    = [UIFont boldSystemFontOfSize:font];
    }
    else{
        buttonCool.titleLabel.font    = [UIFont systemFontOfSize:font];
    }
    return buttonCool;
}

/**
 创建文字图片按钮
 */
+ (instancetype)ks_buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(int)font isBold:(BOOL)isBold normalImg:(NSString *)normalImg{
    UIButton *buttonCool           = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonCool setTitle:title.localizde forState:UIControlStateNormal];
    [buttonCool setTitleColor:titleColor forState:UIControlStateNormal];
    if (isBold) {
        buttonCool.titleLabel.font    = [UIFont boldSystemFontOfSize:font];
    }
    else{
        buttonCool.titleLabel.font    = [UIFont systemFontOfSize:font];
    }
    [buttonCool setImage:[UIImage imageNamed:normalImg] forState:UIControlStateNormal];
    return buttonCool;
}

- (void)ks_playAnimation {
    __weak __typeof(self)weakSelf = self;
    weakSelf.transform = CGAffineTransformIdentity;
    [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations: ^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 / 3.0 animations: ^{
            weakSelf.transform = CGAffineTransformMakeScale(1.05, 1.05);
        }];
        [UIView addKeyframeWithRelativeStartTime:1/3.0 relativeDuration:1/3.0 animations: ^{
            weakSelf.transform = CGAffineTransformMakeScale(0.95, 0.95);
        }];
        [UIView addKeyframeWithRelativeStartTime:2/3.0 relativeDuration:1/3.0 animations: ^{
            weakSelf.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }];
    } completion:nil];
}

-(void)ks_addTarget:(id)target action:(SEL)action {
    [self addTarget:self action:@selector(ks_playAnimation) forControlEvents:UIControlEventTouchDown];
    [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

-(void)ks_addTouchEventForTarget:(id)target action:(SEL)action {
    [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

-(void)ks_updateBackgroundImageFromNormalColor:(UIColor *)normalColor disabledColor:(UIColor *)disabledColor {
    [self setBackgroundImage:[UIImage ks_imageWithColor:normalColor] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage ks_imageWithColor:disabledColor] forState:UIControlStateDisabled];
}


/// 初始化按钮
/// @param title 文字
/// @param titleColor 文字颜色
/// @param font 文字大小
+ (UIButton *)ks_buttonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font {
    UIButton *buttonCool           = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonCool ks_setTitle:title titleColor:titleColor font:font];
    return buttonCool;
}

-(void)ks_setTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font {
    [self setTitle:title.localizde forState:UIControlStateNormal];
    [self setTitleColor:titleColor forState:UIControlStateNormal];
    self.titleLabel.font = font;
}

+ (UIButton *)ks_buttonWithFrame:(CGRect)frame title:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font radius:(CGFloat)radius backgroundColor:(UIColor *)backgroundColor {
    UIButton *buttonCool       = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonCool.frame           = frame;
    [buttonCool ks_setTitle:title titleColor:titleColor font:font];
    buttonCool.backgroundColor = backgroundColor;
    UIBezierPath *maskPath     = [UIBezierPath bezierPathWithRoundedRect:buttonCool.bounds
                                                   byRoundingCorners:UIRectCornerTopRight | UIRectCornerTopLeft | UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                         cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer    = [[CAShapeLayer alloc] init];
    maskLayer.frame            = buttonCool.bounds;
    maskLayer.path             = maskPath.CGPath;
    buttonCool.layer.mask      = maskLayer;

    return buttonCool;
}

+ (UIButton *)ks_buttonWithFrame:(CGRect)frame titleColor:(UIColor *)titleColor font:(UIFont *)font radius:(CGFloat)radius backgroundColor:(UIColor *)backgroundColor {
    UIButton *buttonCool       = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonCool.frame           = frame;
    [buttonCool setTitleColor:titleColor forState:UIControlStateNormal];
    buttonCool.titleLabel.font = font;
    buttonCool.backgroundColor = backgroundColor;
    UIBezierPath *maskPath     = [UIBezierPath bezierPathWithRoundedRect:buttonCool.bounds
                                                   byRoundingCorners:UIRectCornerTopRight | UIRectCornerTopLeft | UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                         cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer    = [[CAShapeLayer alloc] init];
    maskLayer.frame            = buttonCool.bounds;
    maskLayer.path             = maskPath.CGPath;
    buttonCool.layer.mask      = maskLayer;

    return buttonCool;
}

@end
