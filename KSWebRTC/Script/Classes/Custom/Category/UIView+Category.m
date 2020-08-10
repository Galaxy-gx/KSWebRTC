//
//  UIView+Category.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/3.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "UIView+Category.h"
@implementation UIView (Category)

- (CGRect)ks_rectOfSuperFrame:(CGRect)frame width:(CGFloat)width height:(CGFloat)height scale:(KSScale)scale mode:(KSContentMode)mode {
    int w = width;
    int h = height;
    
    switch (mode) {
        case KSContentModeScaleAspectFit://完整高
            h = frame.size.height;
            w = frame.size.height / scale.height * scale.width;
            break;
        case KSContentModeScaleAspectFill:
            w = frame.size.width;
            h = frame.size.width / scale.width * scale.height;
            break;
        default:
            break;
    }
    
    return CGRectMake((frame.size.width - w)/2, (frame.size.height - height)/2, w, h);
}

- (void)ks_drawFilletOfRadius:(CGFloat)radius backgroundColor:(UIColor *)backgroundColor {
    self.backgroundColor = backgroundColor;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:UIRectCornerTopRight | UIRectCornerTopLeft | UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                         cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

//- (void)ks_moveAnimationFromValue:(CGRect)fromValue toValue:(CGRect)toValue bounciness:(CGFloat)bounciness speed:(CGFloat)speed {
//    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
//    anim.fromValue           = [NSValue valueWithCGRect:fromValue];
//    anim.toValue             = [NSValue valueWithCGRect:toValue];
//    anim.springBounciness    = bounciness;
//    anim.springSpeed         = speed;
//    anim.beginTime           = CACurrentMediaTime();
//    [self pop_addAnimation:anim forKey:nil];
//}
//
//- (void)ks_scaleAnimationFromValue:(CGPoint)fromValue toValue:(CGPoint)toValue bounciness:(CGFloat)bounciness speed:(CGFloat)speed {
//    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
//    anim.fromValue           = [NSValue valueWithCGPoint:fromValue];
//    anim.toValue             = [NSValue valueWithCGPoint:toValue];
//    anim.springBounciness    = bounciness;
//    anim.beginTime           = CACurrentMediaTime();
//    anim.springSpeed         = speed;
//    /*
//    //动画结束之后的回调方法
//    [anim setCompletionBlock:^(POPAnimation * animation, BOOL flag) {
//
//    }];
//     */
//    [self.layer pop_addAnimation:anim forKey:nil];
//}
//
//- (void)ks_frameAnimationToTarget:(CGRect)target bounciness:(CGFloat)bounciness speed:(CGFloat)speed {
//    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
//    anim.toValue             = [NSValue valueWithCGRect:target];
//    anim.springBounciness    = bounciness;
//    anim.beginTime           = CACurrentMediaTime();
//    anim.springSpeed         = speed;
//    [self.layer pop_addAnimation:anim forKey:nil];
//}


@end
