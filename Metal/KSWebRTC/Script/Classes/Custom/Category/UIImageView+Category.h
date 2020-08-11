//
//  UIImageView+Category.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Category)

/**
 创建默认UIImageView
 
 @param imgName 图片名
 @param width 宽
 @param height 高
 @return UIImageView
 */
+(instancetype)ks_imageViewWithName:(NSString *)imgName width:(CGFloat)width height:(CGFloat)height;

/**
 创建默认UIImageView
 
 @param imgName 图片名
 @return UIImageView
 */
+(instancetype)ks_imageViewWithName:(NSString *)imgName;

@end
