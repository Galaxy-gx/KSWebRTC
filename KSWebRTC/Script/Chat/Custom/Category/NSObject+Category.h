//
//  NSObject+Category.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSObject (Category)

-(void)ks_delayExecuteForTime:(CGFloat)time action:(SEL)action info:(id)info;

@end
