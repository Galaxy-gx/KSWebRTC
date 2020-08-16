//
//  UIFont+Category.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "UIFont+Category.h"

@implementation UIFont (Category)

+ (UIFont *)ks_setFont:(CGFloat)font isBold:(BOOL)isBold {
    return [UIFont systemFontOfSize:font];
}
+ (UIFont *)ks_fontMediumOfSize:(CGFloat)font {
    return [UIFont systemFontOfSize:font weight:UIFontWeightMedium];
}

+ (UIFont *)ks_fontRegularOfSize:(CGFloat)font {
    return [UIFont systemFontOfSize:font weight:UIFontWeightRegular];
}

@end
