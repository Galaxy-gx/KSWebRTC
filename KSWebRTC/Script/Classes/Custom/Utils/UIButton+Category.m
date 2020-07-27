//
//  UIButton+Category.m
//  KSWebRTC
//
//  Created by saeipi on 2020/7/10.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "UIButton+Category.h"

@implementation UIButton (Category)

+ (UIButton *)initWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font backgroundColor:(UIColor *)backgroundColor borderColor:(UIColor *)borderColor borderWidth:(CGFloat )borderWidth {
    UIButton *coolBtn         = [UIButton buttonWithType:UIButtonTypeCustom];
    [coolBtn setTitle:title forState:UIControlStateNormal];
    [coolBtn setTitleColor:titleColor forState:UIControlStateNormal];
    coolBtn.titleLabel.font   = font;
    coolBtn.layer.borderColor = borderColor.CGColor;
    coolBtn.layer.borderWidth = borderWidth;
    [coolBtn setBackgroundColor:backgroundColor];
    return coolBtn;
}
@end
