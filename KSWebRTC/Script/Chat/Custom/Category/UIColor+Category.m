//
//  UIColor+Category.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "UIColor+Category.h"

@implementation UIColor (Category)

+ (UIColor *)ks_colorWithHexString:(NSString *)hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self ks_colorComponentFrom:colorString start:0 length:1];
            green = [self ks_colorComponentFrom:colorString start:1 length:1];
            blue  = [self ks_colorComponentFrom:colorString start:2 length:1];
            break;
        case 4: // #ARGB
            alpha = [self ks_colorComponentFrom:colorString start:0 length:1];
            red   = [self ks_colorComponentFrom:colorString start:1 length:1];
            green = [self ks_colorComponentFrom:colorString start:2 length:1];
            blue  = [self ks_colorComponentFrom:colorString start:3 length:1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self ks_colorComponentFrom:colorString start:0 length:2];
            green = [self ks_colorComponentFrom:colorString start:2 length:2];
            blue  = [self ks_colorComponentFrom:colorString start:4 length:2];
            break;
        case 8: // #AARRGGBB
            alpha = [self ks_colorComponentFrom:colorString start:0 length:2];
            red   = [self ks_colorComponentFrom:colorString start:2 length:2];
            green = [self ks_colorComponentFrom:colorString start:4 length:2];
            blue  = [self ks_colorComponentFrom:colorString start:6 length:2];
            break;
        default:
            blue  = 0;
            green = 0;
            red   = 0;
            alpha = 0;
            break;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (CGFloat)ks_colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length {
    NSString *substring = [string substringWithRange:NSMakeRange(start, length)];
    NSString *fullHex   = length == 2 ? substring : [NSString stringWithFormat:@"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
    return hexComponent / 255.0;
}

+ (UIImage *)ks_imageWithColor:(UIColor *)color {
    CGRect rect          = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image       = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIColor *)ks_white {
    return [UIColor whiteColor];
}

+ (UIColor *)ks_blueBtn {
    return [UIColor ks_colorWithHexString:@"#3478F6"];
}

+ (UIColor *)ks_grayBar {
    return [UIColor ks_colorWithHexString:@"#292C33"];
}

+ (UIColor *)ks_blackMenu {
    return [UIColor ks_colorWithHexString:@"#0F131A"];
}

+ (UIColor *)ks_grayMenu {
    return [UIColor ks_colorWithHexString:@"#F5F7FA"];
}

@end
