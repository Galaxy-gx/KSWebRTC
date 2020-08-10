//
//  KSProfileView.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//  头像/名称等

#import <UIKit/UIKit.h>
#import "KSProfileConfigure.h"

@interface KSProfileView : UIView

- (instancetype)initWithFrame:(CGRect)frame configure:(KSProfileConfigure *)configure;
- (void)updateConfiure:(KSProfileConfigure *)configure;
@end
