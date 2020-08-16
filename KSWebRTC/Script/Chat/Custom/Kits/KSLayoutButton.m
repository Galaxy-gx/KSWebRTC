//
//  KSLayoutButton.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/8.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSLayoutButton.h"
#import "NSString+Category.h"

@implementation KSLayoutButton

- (instancetype)initWithFrame:(CGRect)frame layoutType:(KSButtonLayoutType)layoutType title:(NSString *)title font:(UIFont *)font textColor:(UIColor *)textColor normalImg:(NSString *)normalImg selectImg:(NSString *) selectImg  space:(CGFloat)space imageWidth:(CGFloat)imageWidth imageHeight:(CGFloat)imageHeight {
    if (self = [super initWithFrame:frame]) {
        self.titleLabel.font = font;
        [self setTitleColor:textColor forState:UIControlStateNormal];
        self.layoutType = layoutType;
        self.space = space;
        self.imgWidth = imageWidth;
        self.imgHeight = imageHeight;
        
        if (normalImg) {
            [self setImage:[UIImage imageNamed:normalImg] forState:UIControlStateNormal];
        }
        if (selectImg) {
            [self setImage:[UIImage imageNamed:selectImg] forState:UIControlStateSelected];
        }
        if (title) {
            [self setTitle:title.localizde forState:UIControlStateNormal];
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame layoutType:(KSButtonLayoutType)layoutType font:(UIFont *)font textColor:(UIColor *)textColor space:(CGFloat)space imageWidth:(CGFloat)imageWidth imageHeight:(CGFloat)imageHeight  {
    if (self = [super initWithFrame:frame]) {
        self.titleLabel.font = font;
        [self setTitleColor:textColor forState:UIControlStateNormal];
        self.layoutType = layoutType;
        self.space = space;
        self.imgWidth = imageWidth;
        self.imgHeight = imageHeight;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
    UIEdgeInsets labelEdgeInsets = UIEdgeInsetsZero;
    
    CGFloat imageWith = self.imgWidth ? self.imgWidth : self.imageView.frame.size.width;
    CGFloat imageHeight = self.imgHeight ? self.imgHeight : self.imageView.frame.size.height;
    
    CGFloat labelWidth = 0.0;
    CGFloat labelHeight = 0.0;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        labelWidth = self.titleLabel.intrinsicContentSize.width;
        labelHeight = self.titleLabel.intrinsicContentSize.height;
    } else {
        labelWidth = self.titleLabel.frame.size.width;
        labelHeight = self.titleLabel.frame.size.height;
    }
    
    switch (self.layoutType) {
        case KSButtonLayoutTypeOriginal: {// 原始位置
            // 不影响原有按钮图片的X，Y值，通过CGRect实现修改按钮图片的宽高。
            CGRect frame = self.imageView.frame;
            frame.size = CGSizeMake(imageWith, imageHeight);
            self.imageView.frame = frame;
        }
            break;
        case KSButtonLayoutTypeTitleRight: {// 图片在左
            imageEdgeInsets = UIEdgeInsetsMake(0, -self.space * 0.5, 0, self.space * 0.5);
            labelEdgeInsets = UIEdgeInsetsMake(0,  self.space * 0.5, 0, -self.space * 0.5);
            
            CGRect frame = self.imageView.frame;
            frame.size = CGSizeMake(imageWith, imageHeight);
            self.imageView.frame = frame;
        }
            break;
        case KSButtonLayoutTypeTitleLeft: {// 图片在右
            imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth + self.space * 0.5, 0, -labelWidth - self.space * 0.5);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith - self.space * 0.5, 0, imageWith + self.space * 0.5);
            
            CGRect frame = self.imageView.frame;
            frame.size = CGSizeMake(imageWith, imageHeight);
            self.imageView.frame = frame;
        }
            break;
        case KSButtonLayoutTypeTitleBottom: {// 图片在上
            //UIEdgeInsets UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
            /*
             imageEdgeInsets = UIEdgeInsetsMake(-labelHeight - self.space * 0.5, 0, 0, -labelWidth);
             labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith, -imageHeight - self.space * 0.5, 0);
             CGRect frame = self.imageView.frame;
             frame.size = CGSizeMake(imageWith, imageHeight);
             self.imageView.frame = frame;
             */
            CGFloat image_x = (self.bounds.size.width - imageWith)/2;
            CGFloat image_y = (self.bounds.size.height - imageHeight - labelHeight - _space)/2;
            self.imageView.frame = CGRectMake(image_x, image_y, imageWith, imageHeight);
            CGFloat title_y = image_y + imageHeight + _space;
            self.titleLabel.frame = CGRectMake(0, title_y, self.bounds.size.width, labelHeight);
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
        }
            break;
        case KSButtonLayoutTypeTitleTop: {// 图片在下
            
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, -labelHeight - self.space * 0.5, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(-imageHeight - self.space * 0.5, -imageWith, 0, 0);
            
            CGRect frame = self.imageView.frame;
            frame.size = CGSizeMake(imageWith, imageHeight);
            self.imageView.frame = frame;
        }
            break;
            
        default:
            break;
    }
    self.titleEdgeInsets = labelEdgeInsets;
    self.imageEdgeInsets = imageEdgeInsets;
}

-(void)updateTitle:(NSString *)title {
    if (title) {
        [self setTitle:title.localizde forState:UIControlStateNormal];
    }
}

-(void)updateTitle:(NSString *)title normalIcon:(NSString *)normalIcon selectedIcon:(NSString *)selectedIcon selected:(BOOL)selected {
    if (normalIcon) {
        [self setImage:[UIImage imageNamed:normalIcon] forState:UIControlStateNormal];
    }
    if (selectedIcon) {
        [self setImage:[UIImage imageNamed:selectedIcon] forState:UIControlStateSelected];
    }
    [self updateTitle:title];
    self.selected = selected;
}
@end

