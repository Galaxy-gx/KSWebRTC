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
- (void)ks_embedView:(UIView *)view containerView:(UIView *)containerView;
//- (void)ks_moveAnimationFromValue:(CGRect)fromValue toValue:(CGRect)toValue bounciness:(CGFloat)bounciness speed:(CGFloat)speed;
//- (void)ks_scaleAnimationFromValue:(CGPoint)fromValue toValue:(CGPoint)toValue bounciness:(CGFloat)bounciness speed:(CGFloat)speed;
//- (void)ks_frameAnimationToTarget:(CGRect)target bounciness:(CGFloat)bounciness speed:(CGFloat)speed;
@end
