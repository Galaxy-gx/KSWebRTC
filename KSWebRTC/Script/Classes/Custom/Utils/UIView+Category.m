//
//  UIView+Category.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/3.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "UIView+Category.h"

@implementation UIView (Category)

- (CGRect)rectOfSuperFrame:(CGRect)frame width:(CGFloat)width height:(CGFloat)height scale:(KSScale)scale mode:(KSContentMode)mode {
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

@end
