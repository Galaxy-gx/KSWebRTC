//
//  NSObject+Category.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "NSObject+Category.h"

@implementation NSObject (Category)

-(void)ks_delayExecuteForTime:(CGFloat)time action:(SEL)action info:(id)info {
    __weak __typeof(self)weakSelf = self;
    //延迟执行
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([weakSelf respondsToSelector:action]) {
            [weakSelf performSelector:action withObject:info];
        }
#pragma clang diagnostic pop
    });
}

@end
