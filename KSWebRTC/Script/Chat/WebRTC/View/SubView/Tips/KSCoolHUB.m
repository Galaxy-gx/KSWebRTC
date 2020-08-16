//
//  KSCoolHUB.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/8.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSCoolHUB.h"
#import "KSCoolTipsView.h"

@interface KSCoolHUB()

@property(nonatomic,weak)KSCoolTipsView *tipsView;

@end

@implementation KSCoolHUB

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
    }
    return self;
}

- (void)initKit {
    KSCoolTipsView *tipsView = [[KSCoolTipsView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, 180, KS_Extern_Point44)];
    _tipsView = tipsView;
    [self addSubview:tipsView];
    self.hidden = YES;
    self.userInteractionEnabled = NO;
}

- (void)showMessage:(NSString *)message {
    [_tipsView updateMessage:message];
    __weak __typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf showTips];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf hiddenTips];
        });
    });
    
}

- (void)showTips {
    self.hidden = NO;
    self.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hiddenTips {
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

@end
