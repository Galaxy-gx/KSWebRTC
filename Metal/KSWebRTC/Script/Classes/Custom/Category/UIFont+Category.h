//
//  UIFont+Category.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (Category)

+ (UIFont *)ks_setFont:(CGFloat)font isBold:(BOOL)isBold;
+ (UIFont *)ks_fontMediumOfSize:(CGFloat)font;
+ (UIFont *)ks_fontRegularOfSize:(CGFloat)font;
@end
