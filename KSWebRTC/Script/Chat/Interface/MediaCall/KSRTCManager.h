//
//  KSRTCManager.h
//  KSWebRTC
//
//  Created by saeipi on 2020/9/15.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSMediaCapturer.h"
#import "KSMediaConnection.h"
#import "KSCallState.h"
#import "KSMsg.h"
#import "KSMessageHandler.h"
#import "KSMediaTrack.h"
#import "KSAckMessage.h"
#import "KSSession.h"
#import "KSUserInfo.h"
#import "KSDeviceSwitch.h"
@class KSRTCManager;

@protocol KSRTCManagerDelegate <NSObject>
- (void)rtcManager:(KSRTCManager *)rtcManager didAddMediaTrack:(KSMediaTrack *)mediaTrack;
- (void)rtcManager:(KSRTCManager *)rtcManager call:(KSCall *)call;
- (void)rtcManager:(KSRTCManager *)rtcManager answer:(KSAnswer *)answer;
@end

@interface KSRTCManager : NSObject
@property (nonatomic, weak)id<KSRTCManagerDelegate>         delegate;
@property (nonatomic, weak, readonly  ) AVCaptureSession       *captureSession;
@property (nonatomic, weak, readonly  ) KSMediaTrack           *localMediaTrack;
@property (nonatomic, assign, readonly) int                    mediaTrackCount;
@property (nonatomic, strong          ) KSMediaSetting         *mediaSetting;
@property (nonatomic, assign          ) KSCallType             callType;
@property (nonatomic, assign          ) KSCallStateMaintenance callState;
@property (nonatomic, assign          ) BOOL                   isRemote;
@property (nonatomic, assign          ) int                    startingTime;
@property (nonatomic, weak, readonly  ) KSMediaTrack           *screenMediaTrack;
@property (nonatomic, weak, readonly  ) KSMediaTrack           *tileMediaTrack;
@property (nonatomic, strong          ) KSDeviceSwitch         *deviceSwitch;
@property (nonatomic, strong          ) KSSession              *session;
@property (nonatomic, assign, readonly) long long              peerId;
@property (nonatomic, assign, readonly) BOOL                   isCalled;

+ (instancetype)shared;
+ (void)initRTCWithMediaSetting:(KSMediaSetting *)mediaSetting;
+ (void)close;

+ (void)switchCamera;
//显示小窗
+ (void)displayTile;

//Scoekt
+ (void)callToUserid:(long long)userid;
+ (void)answerToUserid:(long long)userid;

//MediaTrack
+ (KSMediaTrack *)mediaTrackOfIndex:(NSInteger)index;
@end
