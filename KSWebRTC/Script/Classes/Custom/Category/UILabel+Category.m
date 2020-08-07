//
//  UILabel+Category.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "UILabel+Category.h"
#import "NSString+Category.h"
#import "UIFont+Category.h"

@implementation UILabel (Category)

+ (instancetype)ks_labelWithWidth:(CGFloat)width height:(CGFloat)height textColor:(UIColor *)textColor font:(UIFont *)font alignment:(NSTextAlignment)alignment {
    UILabel *labeCool = [[UILabel alloc] init];
    labeCool.frame =CGRectMake(0, 0, width, height);
    labeCool.textAlignment = alignment;
    labeCool.textColor = textColor;
    labeCool.font = font;
    labeCool.adjustsFontSizeToFitWidth = YES;
    labeCool.numberOfLines = 0;
    return labeCool;
}

+ (instancetype)ks_labelWithDefaultColor:(UIColor *)textColor font:(UIFont *)font width:(float)width height:(float)height margin:(float)margin index:(int)index {
    UILabel *labeCool = [[UILabel alloc] init];
    labeCool.textAlignment =  NSTextAlignmentCenter;
    labeCool.textColor = textColor;
    labeCool.font = font;
    labeCool.adjustsFontSizeToFitWidth = YES;
    labeCool.numberOfLines = 0;
    labeCool.frame = CGRectMake(margin*index, 0, width, height);
    return labeCool;
}

+ (UILabel *)ks_labelWithFrame:(CGRect)frame textColor:(UIColor *)textColor font:(UIFont *)font alignment:(NSTextAlignment)alignment {
    UILabel *labeCool = [[UILabel alloc] initWithFrame:frame];
    labeCool.textAlignment = alignment;
    labeCool.textColor = textColor;
    labeCool.font = font;
    labeCool.adjustsFontSizeToFitWidth = YES;
    labeCool.numberOfLines = 0;
    return labeCool;
}

+ (instancetype)ks_labelWithText:(NSString *)text textColor:(UIColor *)textColor font:(UIFont *)font alignment:(NSTextAlignment)alignment {
    UILabel *labeCool = [[UILabel alloc] init];
    labeCool.text = text.localizde;
    labeCool.textAlignment = alignment;
    labeCool.textColor = textColor;
    labeCool.font = font;
    labeCool.adjustsFontSizeToFitWidth = YES;
    labeCool.numberOfLines = 0;
    return labeCool;
}

+ (instancetype)ks_labelWithTextColor:(UIColor *)textColor font:(UIFont *)font alignment:(NSTextAlignment)alignment {
    UILabel *labeCool = [UILabel ks_labelWithFont:font alignment:alignment];
    labeCool.textColor = textColor;
    return labeCool;
}

+ (instancetype)ks_labelWithFont:(UIFont *)font alignment:(NSTextAlignment)alignment {
    UILabel *labeCool = [[UILabel alloc] init];
    labeCool.textAlignment = alignment;
    labeCool.font = font;
    labeCool.adjustsFontSizeToFitWidth = YES;
    labeCool.numberOfLines = 0;
    return labeCool;
}

/**
 计算字体长度 和 宽度
 */
- (CGSize)ks_sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize {
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}
/**
 计算字体长度 和 宽度
 */
- (CGSize)ks_sizeWithMaxSize:(CGSize)maxSize {
    if(self.text == nil){
        return CGSizeZero;
    }
    NSDictionary *attrs = @{NSFontAttributeName : self.font};
    return [self.text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}


/**
 计算字体长度 和 宽度
 */
+ (CGSize)ks_sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize {
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

- (void)ks_setLabelSpaceWithContent:(NSString*)str withFont:(UIFont*)font {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode            = NSLineBreakByCharWrapping;
    paraStyle.alignment                = NSTextAlignmentLeft;
    paraStyle.lineSpacing              = 4;//设置行间距
    paraStyle.hyphenationFactor        = 1.0;
    paraStyle.firstLineHeadIndent      = 0.0;
    paraStyle.paragraphSpacingBefore   = 0.0;
    paraStyle.headIndent               = 0;
    paraStyle.tailIndent               = 0;
    //设置字间距 NSKernAttributeName:@1.5f
    NSDictionary *dic                  = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@1.5f
                                           };
    NSAttributedString *attributeStr   = [[NSAttributedString alloc] initWithString:str attributes:dic];
    self.attributedText = attributeStr;
}

- (void)ks_setText:(NSString*)text font:(UIFont*)font alignment:(NSTextAlignment)alignment lineSpacing:(CGFloat)lineSpacing {
    //防止数据为空引起的闪退
    if (text == nil){
        text = @"";
    }
    if (font == nil){
        font = [UIFont systemFontOfSize:14];
    }
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode            = NSLineBreakByCharWrapping;
    paraStyle.alignment                = alignment;
    paraStyle.lineSpacing              = lineSpacing;//设置行间距
    paraStyle.hyphenationFactor        = 1.0;
    paraStyle.firstLineHeadIndent      = 0.0;
    paraStyle.paragraphSpacingBefore   = 0.0;
    paraStyle.headIndent               = 0;
    paraStyle.tailIndent               = 0;
    //设置字间距 NSKernAttributeName:@1.5f
    NSDictionary *dict                  = @{NSFontAttributeName:font,
                                            NSParagraphStyleAttributeName:paraStyle,
                                            NSKernAttributeName:@1.5f
                                           };
    NSAttributedString *attributeStr   = [[NSAttributedString alloc] initWithString:text attributes:dict];
    self.attributedText = attributeStr;
}

- (void)ks_setLineSpace:(CGFloat)lineSpace withText:(NSString *)text {
    if (text.length == 0) {
        return;
    }
    NSMutableParagraphStyle *paragraphStyle     = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing                  = lineSpace;//设置行间距
    paragraphStyle.lineBreakMode                = self.lineBreakMode;
    paragraphStyle.alignment                    = self.textAlignment;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
    self.attributedText                         = attributedString;
}

@end
