//
//  NSString+Category.m
//  KSWebRTC
//
//  Created by saeipi on 2020/7/10.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "NSString+Category.h"

@implementation NSString (Category)
static const NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

+ (NSString *)ks_randomForLength:(int)length {
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    for (int i = 0; i < length; i++) {
        uint32_t data = arc4random_uniform((uint32_t)[letters length]);
        [randomString appendFormat:@"%C", [letters characterAtIndex:data]];
    }
    return randomString;
}

+ (NSString *)ks_localizde:(NSString *)text {
    return text;
}

- (NSString *)ks_localizde {
    return self;
}

- (void)setLocalizde:(NSString *)localizde {
    
}

- (NSString *)localizde {
    return NSLocalizedString(self, nil);
}

+ (NSMutableAttributedString *)ks_attributesOfText:(NSString *)text color:(UIColor *)color font:(UIFont *)font {
    NSUInteger length = [text length];
    if (length == 0) {
        return nil;
    }
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributeString addAttributes:@{NSForegroundColorAttributeName : color,
                                     NSFontAttributeName : font} range:NSMakeRange(0, length)];
    return attributeString;
}
@end
