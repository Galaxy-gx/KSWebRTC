//
//  UIColor+Category.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Category)

//设置十六进制颜色
+ (UIColor *)ks_colorWithHexString:(NSString *)hexString;
+ (UIImage *)ks_imageWithColor:(UIColor *)color;
+ (UIColor *)ks_white;
+ (UIColor *)ks_blueBtn;
+ (UIColor *)ks_grayBar;
+ (UIColor *)ks_blackMenu;
+ (UIColor *)ks_grayMenu;

@end
