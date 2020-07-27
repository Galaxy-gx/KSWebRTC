//
//  UIButton+Category.h
//  KSWebRTC
//
//  Created by saeipi on 2020/7/10.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Category)

+ (UIButton *)initWithTitle:(NSString *)title titleColor:(UIColor *)titleColor font:(UIFont *)font backgroundColor:(UIColor *)backgroundColor borderColor:(UIColor *)borderColor borderWidth:(CGFloat )borderWidth;

@end
