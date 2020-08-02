//
//  KSVideoCallView.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/2.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "KSRemoteView.h"

@class KSVideoCallView;

@protocol KSVideoCallViewDelegate <NSObject>
@optional
- (void)videoCallViewDidChangeRoute:(KSVideoCallView *)view;
- (void)videoCallViewDidEnableStats:(KSVideoCallView *)view;
- (void)videoCallViewDidHangup:(KSVideoCallView *)view;
- (void)videoCallViewDidSwitchCamera:(KSVideoCallView *)view;
@end

@interface KSVideoCallView : UIView

@property(nonatomic,weak)id<KSVideoCallViewDelegate> delegate;


- (void)setLocalViewSession:(AVCaptureSession *)session;
- (void)leaveOfHandleId:(NSNumber *)handleId;
- (RTCEAGLVideoView *)remoteViewOfHandleId:(NSNumber *)handleId;

@end
