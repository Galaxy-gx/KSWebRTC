//
//  KSWebRTCManager.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/12.
//  Copyright © 2020 saeipi. All rights reserved.
//  尽量在此类修改callType

#import <Foundation/Foundation.h>
#import "KSMediaCapturer.h"
#import "KSMediaConnection.h"
#import "KSCallState.h"
#import "KSMsg.h"
#import "KSSignalingHandler.h"
#import "KSMessageHandler.h"
#import "KSMediaTrack.h"
#import "KSSession.h"
#import "KSUserInfo.h"
#import "KSDeviceSwitch.h"
#import "KSLogicMsg.h"
@class KSWebRTCManager;
@protocol KSWebRTCManagerDelegate <NSObject>
@optional
//KSSignalingHandler
- (void)webRTCManager:(KSWebRTCManager *)webRTCManager signalingHandler:(KSSignalingHandler *)signalingHandler socketDidOpen:(KSWebSocket *)socket;
- (void)webRTCManager:(KSWebRTCManager *)webRTCManager signalingHandler:(KSSignalingHandler *)signalingHandler socketDidFail:(KSWebSocket *)socket;
//- (void)webRTCManager:(KSWebRTCManager *)webRTCManager signalingHandler:(KSSignalingHandler *)signalingHandler requestError:(KSMsg *)message;
//- (void)webRTCManager:(KSWebRTCManager *)webRTCManager signalingHandler:(KSSignalingHandler *)signalingHandler didReceivedMessage:(KSMsg *)message;
- (CGFloat)tileYOfWebRTCManager:(KSWebRTCManager *)webRTCManager;

//KSMessageHandler
- (void)webRTCManager:(KSWebRTCManager *)webRTCManager messageHandler:(KSMessageHandler *)messageHandler didReceivedMessage:(KSLogicMsg *)message;
//KSMediaConnection
- (void)webRTCManager:(KSWebRTCManager *)webRTCManager didAddMediaTrack:(KSMediaTrack *)mediaTrack;
- (void)webRTCManager:(KSWebRTCManager *)webRTCManager mediaConnection:(KSMediaConnection *)mediaConnection peerConnection:(RTCPeerConnection *)peerConnection didChangeIceConnectionState:(RTCIceConnectionState)newState;
@end

@interface KSWebRTCManager : NSObject

@property (nonatomic, weak)id<KSWebRTCManagerDelegate>         delegate;
@property (nonatomic, assign, readonly) int                    mediaTrackCount;
@property (nonatomic, assign          ) KSCallType             callType;
@property (nonatomic, assign          ) KSCallStateMaintenance callState;
@property (nonatomic, assign          ) int                    startingTime;
@property (nonatomic, weak, readonly  ) KSMediaTrack           *screenMediaTrack;
@property (nonatomic, weak, readonly  ) KSMediaTrack           *tileMediaTrack;
@property (nonatomic, strong          ) KSDeviceSwitch         *deviceSwitch;
@property (nonatomic, strong          ) KSSession              *session;
@property (nonatomic, assign, readonly) BOOL                   isCalled;//是否是被叫
@property (nonatomic, assign          ) long long              callerId;
+ (instancetype)shared;
+ (void)initRTCWithMediaSetting:(KSMediaSetting *)mediaSetting;

//MediaCapture
+ (void)switchCamera;
+ (void)switchTalkMode;
+ (void)startCapture;
+ (void)stopCapture;
+ (void)speakerOff;
+ (void)speakerOn;
+ (void)muteAudio;
+ (void)unmuteAudio;

+ (void)switchToSingleVideo;//功能设置
+ (void)switchToSingleAudio;
+ (void)switchToVideoCall;//切换同步
+ (void)switchToVoiceCall;

+ (void)clearAllRenderer;
//Track
+ (KSMediaTrack *)mediaTrackOfIndex:(NSInteger)index;
+ (void)close;

//Signaling Socket
+ (void)connectToSignalingServer:(NSString *)server room:(int)room;
+ (void)requestLeave;

//Message Socket
+ (void)connectToMessageServer:(NSString *)server user:(KSUserInfo *)user;
+ (void)refreshAddressBook;
+ (void)callToUserId:(long long)userId room:(int)room;
+ (void)answoerOfTime:(int)time;
+ (void)leave;
//显示小窗
+ (void)displayTile;

@end
