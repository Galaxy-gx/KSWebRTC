//
//  KSButton.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KSButtonLayoutType) {
    KSButtonLayoutTypeTitleTop,
    KSButtonLayoutTypeTitleBottom,
    KSButtonLayoutTypeTitleCenter
};

@interface KSButton : UIControl
-(instancetype)initWithFrame:(CGRect)frame title:(NSString *)title textColor:(UIColor*)textColor font:(UIFont *)font alignment:(NSTextAlignment)alignment titleHeight:(int)titleHeight defaultIcon:(NSString *)defaultIcon selectedIcon:(NSString *)selectedIcon imageSize:(CGSize)imageSize layoutType:(KSButtonLayoutType)layoutType spacing:(CGFloat)spacing;
-(instancetype)initWithFrame:(CGRect)frame textColor:(UIColor*)textColor font:(UIFont *)font alignment:(NSTextAlignment)alignment titleHeight:(int)titleHeight imageSize:(CGSize)imageSize layoutType:(KSButtonLayoutType)layoutType spacing:(CGFloat)spacing;
-(void)updateDefaultIcon:(NSString *)defaultIcon selectedIcon:(NSString *)selectedIcon selected:(BOOL)selected;
-(void)updateTitle:(NSString *)title;
@end
