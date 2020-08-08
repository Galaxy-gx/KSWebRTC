//
//  UIView+Category.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/3.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSConfigure.h"

@interface UIView (Category)

- (CGRect)ks_rectOfSuperFrame:(CGRect)frame width:(CGFloat)width height:(CGFloat)height scale:(KSScale)scale mode:(KSContentMode)mode;
- (void)ks_drawFilletOfRadius:(CGFloat)radius backgroundColor:(UIColor *)backgroundColor;
@end
