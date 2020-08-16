//
//  UILabel+Category.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Category)

+ (instancetype)ks_labelWithWidth:(CGFloat)width height:(CGFloat)height textColor:(UIColor *)textColor font:(UIFont *)font alignment:(NSTextAlignment)alignment;
+ (instancetype)ks_labelWithDefaultColor:(UIColor *)textColor font:(UIFont *)font width:(float)width height:(float)height margin:(float)margin index:(int)index;
+ (UILabel *)ks_labelWithFrame:(CGRect)frame textColor:(UIColor *)textColor font:(UIFont *)font alignment:(NSTextAlignment)alignment;
+ (instancetype)ks_labelWithText:(NSString *)text textColor:(UIColor *)textColor font:(UIFont *)font alignment:(NSTextAlignment)alignment;
+ (instancetype)ks_labelWithTextColor:(UIColor *)textColor font:(UIFont *)font alignment:(NSTextAlignment)alignment;
+ (instancetype)ks_labelWithFont:(UIFont *)font alignment:(NSTextAlignment)alignment;
- (CGSize)ks_sizeOfMaxSize:(CGSize)maxSize;
- (CGSize)ks_textSize;
+ (CGSize)ks_sizeOfText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize;
- (void)ks_setLabelSpaceWithContent:(NSString*)str withFont:(UIFont*)font;
- (void)ks_setText:(NSString*)text font:(UIFont*)font alignment:(NSTextAlignment)alignment lineSpacing:(CGFloat)lineSpacing;
- (void)ks_setLineSpace:(CGFloat)lineSpace withText:(NSString *)text;

@end
