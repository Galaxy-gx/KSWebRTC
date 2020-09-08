//
//  NSString+Category.h
//  KSWebRTC
//
//  Created by saeipi on 2020/7/10.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (Category)

@property(nonatomic,copy)NSString *localizde;

+ (NSString *)ks_randomForLength:(int)length;
+ (NSString *)ks_localizde:(NSString *)text;
+ (NSMutableAttributedString *)ks_attributesOfText:(NSString *)text color:(UIColor *)color font:(UIFont *)font;
- (CGSize)ks_sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;
- (NSDictionary *)ks_toDictionary;
@end
