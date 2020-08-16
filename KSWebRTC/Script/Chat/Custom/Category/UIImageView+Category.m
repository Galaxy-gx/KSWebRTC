//
//  UIImageView+Category.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "UIImageView+Category.h"

@implementation UIImageView (Category)

/**
 创建默认UIImageView
 
 @param imgName 图片名
 @param width 宽
 @param height 高
 @return UIImageView
 */
+(instancetype)ks_imageViewWithName:(NSString *)imgName width:(CGFloat)width height:(CGFloat)height {
    UIImageView *imageViewCool = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    imageViewCool.image = [UIImage imageNamed:imgName];
    return imageViewCool;
}


/**
 创建默认UIImageView

 @param imgName 图片名
 @return UIImageView
 */
+(instancetype)ks_imageViewWithName:(NSString *)imgName {
    UIImageView *imageViewCool = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
    return imageViewCool;
}

@end
