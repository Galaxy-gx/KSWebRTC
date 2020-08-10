//
//  KSCallView.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/2.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
//Configure
#import "KSConfigure.h"

//ViewModel
#import "KSTileLayout.h"
#import "KSProfileConfigure.h"

//Kit
#import "KSRemoteView.h"

@class KSCallView;

@protocol KSVideoCallViewDelegate <NSObject>
@optional
- (void)videoCallViewDidChangeRoute:(KSCallView *)view;
- (void)videoCallViewDidEnableStats:(KSCallView *)view;
- (void)videoCallViewDidHangup:(KSCallView *)view;
- (void)videoCallViewDidSwitchCamera:(KSCallView *)view;
@end

@interface KSCallView : UIView

@property(nonatomic,weak)id<KSVideoCallViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame layout:(KSTileLayout *)layout callType:(KSCallType)callType;
- (void)createLocalViewWithLayout:(KSTileLayout *)layout resizingMode:(KSResizingMode)resizingMode callType:(KSCallType)callType;
- (void)setLocalViewSession:(AVCaptureSession *)session;
- (void)leaveOfHandleId:(NSNumber *)handleId;
- (RTCEAGLVideoView *)remoteViewOfHandleId:(NSNumber *)handleId;

//KIT:KSProfileView
- (void)setProfileConfigure:(KSProfileConfigure *)configure;
//KIT:KSAnswerBarView
- (void)setAnswerState:(KSAnswerState)state;


@end
