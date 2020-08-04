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

- (CGRect)rectOfSuperFrame:(CGRect)frame width:(CGFloat)width height:(CGFloat)height scale:(KSScale)scale mode:(KSContentMode)mode;

@end
