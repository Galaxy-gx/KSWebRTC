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
#import "KSMessageHandler.h"
#import "KSMediaTrack.h"
#import "KSAckMessage.h"
#import "KSSession.h"
#import "KSUserInfo.h"
#import "KSDeviceSwitch.h"

@class KSWebRTCManager;
@protocol KSWebRTCManagerDelegate <NSObject>
@optional

//测试
- (void)webRTCManager:(KSWebRTCManager *)webRTCManager didReceivedMessage:(KSMsg *)message;
- (void)webRTCManagerSocketDidOpen:(KSWebRTCManager *)webRTCManager;
- (void)webRTCManagerSocketDidFail:(KSWebRTCManager *)webRTCManager;

//KSMediaConnection
- (void)webRTCManager:(KSWebRTCManager *)webRTCManager didAddMediaTrack:(KSMediaTrack *)mediaTrack;
- (void)webRTCManager:(KSWebRTCManager *)webRTCManager mediaConnection:(KSMediaConnection *)mediaConnection peerConnection:(RTCPeerConnection *)peerConnection didChangeIceConnectionState:(RTCIceConnectionState)newState;

//Message
- (void)webRTCManager:(KSWebRTCManager *)webRTCManager ackCall:(KSAckCall *)ackCall;
- (void)webRTCManager:(KSWebRTCManager *)webRTCManager ackJoined:(KSAckJoined *)ackJoined;
- (void)webRTCManager:(KSWebRTCManager *)webRTCManager ackStart:(KSAckStart *)ackStart;
- (void)webRTCManager:(KSWebRTCManager *)webRTCManager ackAnswer:(KSAckAnswer *)answer;
- (void)webRTCManagerCallTimeout:(KSWebRTCManager *)webRTCManager;
- (void)webRTCManagerHandlerEnd:(KSWebRTCManager *)webRTCManager;
- (void)webRTCManagerDisconnected:(KSWebRTCManager *)webRTCManager;

- (void)webRTCManager:(KSWebRTCManager *)webRTCManager ackLeft:(KSAckLeft *)ackLeft mediaTrack:(KSMediaTrack *)mediaTrack;
- (void)webRTCManager:(KSWebRTCManager *)webRTCManager mediaState:(KSMediaState)mediaState userInfo:(KSUserInfo *)userInfo;
- (void)webRTCManager:(KSWebRTCManager *)webRTCManager changeMediaType:(KSChangeMediaType)mediaType userInfo:(KSUserInfo *)userInfo;//调用代理前修改callType
- (void)webRTCManagerLineBusy:(KSWebRTCManager *)webRTCManager userInfo:(KSUserInfo *)userInfo;//通话中

- (void)webRTCManager:(KSWebRTCManager *)webRTCManager requestError:(KSRequestError *)error;
//- (void)webRTCManager:(KSWebRTCManager *)webRTCManager ackDecline:(KSAckDecline *)ackDecline;

@end

@interface KSWebRTCManager : NSObject

@property (nonatomic, weak)id<KSWebRTCManagerDelegate>         delegate;
@property (nonatomic, weak, readonly  ) AVCaptureSession       *captureSession;
@property (nonatomic, weak, readonly  ) KSMediaTrack           *localMediaTrack;
@property (nonatomic, assign, readonly) int                    mediaTrackCount;
@property (nonatomic, strong          ) KSMediaSetting         *mediaSetting;
@property (nonatomic, assign          ) KSCallType             callType;
@property (nonatomic, assign          ) BOOL                   isConnect;
@property (nonatomic, assign          ) KSCallStateMaintenance callState;
@property (nonatomic, assign          ) BOOL                   isTest;
@property (nonatomic, assign          ) BOOL                   isRemote;
@property (nonatomic, assign          ) int                    startingTime;
@property (nonatomic, weak, readonly  ) KSMediaTrack           *screenMediaTrack;
@property (nonatomic, weak, readonly  ) KSMediaTrack           *tileMediaTrack;
@property (nonatomic, strong          ) KSDeviceSwitch         *deviceSwitch;
@property (nonatomic, strong          ) KSSession              *session;
@property (nonatomic, assign, readonly) int                    peerId;
@property (nonatomic, assign, readonly) BOOL                   isCalled;
+ (instancetype)shared;
- (void)initRTCWithMediaSetting:(KSMediaSetting *)mediaSetting;

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

+ (void)clearAllRenderer;

- (void)close;
+ (void)close;

//Socket
+ (void)socketConnectServer:(NSString *)server;
+ (void)socketClose;
+ (void)socketCreateSession;
- (void)sendOffer;
+ (void)socketSendHangup;

//Track
+ (KSMediaTrack *)mediaTrackOfIndex:(NSInteger)index;

//Message
- (void)didReceivedMessage:(NSDictionary *)message;

//Call
+ (void)callToPeerId:(int)peerId;
+ (void)ringed;
+ (void)answoer;
+ (void)updateStartingTime;
+ (void)leave;
//开启语音
+ (void)openVoice;
//关闭语音
+ (void)closeVoice;
//开启视频
+ (void)openVideo;
//关闭视频
+ (void)closeVideo;

+ (void)switchToVideoCall;//发送消息
+ (void)switchToVoiceCall;

//显示小窗
- (void)displayTile;
@end
