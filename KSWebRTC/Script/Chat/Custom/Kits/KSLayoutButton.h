//
//  KSLayoutButton.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/8.
//  Copyright © 2020 saeipi. All rights reserved.
//  暂时不使用

#import <UIKit/UIKit.h>
#import "KSButton.h"

@interface KSLayoutButton : UIButton

@property (nonatomic, assign) KSButtonLayoutType layoutType;
@property (nonatomic, assign) CGFloat space;
@property (nonatomic, assign) CGFloat imgWidth;
@property (nonatomic, assign) CGFloat imgHeight;

- (instancetype)initWithFrame:(CGRect)frame layoutType:(KSButtonLayoutType)layoutType title:(NSString *)title font:(UIFont *)font textColor:(UIColor *)textColor normalImg:(NSString *)normalImg selectImg:(NSString *) selectImg  space:(CGFloat)space imageWidth:(CGFloat)imageWidth imageHeight:(CGFloat)imageHeight;
- (instancetype)initWithFrame:(CGRect)frame layoutType:(KSButtonLayoutType)layoutType font:(UIFont *)font textColor:(UIColor *)textColor space:(CGFloat)space imageWidth:(CGFloat)imageWidth imageHeight:(CGFloat)imageHeight;
-(void)updateTitle:(NSString *)title;
-(void)updateTitle:(NSString *)title normalIcon:(NSString *)normalIcon selectedIcon:(NSString *)selectedIcon selected:(BOOL)selected;
@end
