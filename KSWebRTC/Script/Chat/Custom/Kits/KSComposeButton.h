//
//  KSComposeButton.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/25.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSComposeButton : UIControl

- (instancetype)initWithFrame:(CGRect)frame textColor:(UIColor*)textColor font:(UIFont *)font alignment:(NSTextAlignment)alignment titleHeight:(int)titleHeight imageSize:(CGSize)imageSize backgroundColor:(UIColor *)backgroundColor backgroundSize:(CGSize)backgroundSize spacing:(CGFloat)spacing;
- (void)updateTitle:(NSString *)title defaultIcon:(NSString *)defaultIcon selectedIcon:(NSString *)selectedIcon selected:(BOOL)selected;

@end
