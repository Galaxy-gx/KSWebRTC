//
//  KSVideoView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/11.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSVideoView.h"

@implementation KSVideoView

- (instancetype)initWithFrame:(CGRect)frame callType:(KSCallType)callType {
    if (self = [super initWithFrame:frame]) {
        self.callType = callType;
        [self initKit];
    }
    return self;
}

- (void)initKit {
    
}

- (void)updateCallType:(KSCallType)callType {
    
}

- (void)embedView:(UIView *)view containerView:(UIView *)containerView {
    [containerView addSubview:view];
    view.translatesAutoresizingMaskIntoConstraints = false;
    NSLayoutConstraint *constraintLeft = [NSLayoutConstraint constraintWithItem:view
                                 attribute:NSLayoutAttributeLeft
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:containerView
                                 attribute:NSLayoutAttributeLeft
                                multiplier:1
                                  constant:0];
    
    NSLayoutConstraint *constraintRight = [NSLayoutConstraint constraintWithItem:view
                                 attribute:NSLayoutAttributeRight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:containerView
                                 attribute:NSLayoutAttributeRight
                                multiplier:1
                                  constant:0];
    
    NSLayoutConstraint *constraintTop = [NSLayoutConstraint constraintWithItem:view
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:containerView
                                 attribute:NSLayoutAttributeTop
                                multiplier:1
                                  constant:0];
    
    NSLayoutConstraint *constraintBottom = [NSLayoutConstraint constraintWithItem:view
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:containerView
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1
                                  constant:0];
    [self addConstraints:@[constraintLeft,constraintRight,constraintTop,constraintBottom]];
}

@end
