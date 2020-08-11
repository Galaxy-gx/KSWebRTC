//
//  KSVideoView.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/11.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebRTC/WebRTC.h>
#import "KSConfigure.h"

@interface KSVideoView : UIView

@property (nonatomic,assign) KSCallType      callType;
@property (nonatomic,weak  ) RTCMTLVideoView *videoView;

- (instancetype)initWithFrame:(CGRect)frame callType:(KSCallType)callType;
- (void)updateCallType:(KSCallType)callType;
- (void)embedView:(UIView *)view containerView:(UIView *)containerView;
@end

