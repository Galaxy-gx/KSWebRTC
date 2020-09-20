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


- (void)webRTCManagerCallTimeout:(KSWebRTCManager *)webRTCManager;
- (void)webRTCManagerHandlerEnd:(KSWebRTCManager *)webRTCManager;
- (void)webRTCManagerDisconnected:(KSWebRTCManager *)webRTCManager;

@end

@interface KSWebRTCManager : NSObject

@property (nonatomic, weak)id<KSWebRTCManagerDelegate>         delegate;
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
@property (nonatomic, assign, readonly) BOOL                   isCalled;
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

//Socket
+ (void)socketConnectServer:(NSString *)server;
+ (void)socketClose;
+ (void)socketCreateSession;
+ (void)sendOffer;
+ (void)socketSendHangup;

//业务消息
+ (void)joinRoom:(int)room;
+ (void)createRoom:(int)room;

//显示小窗
+ (void)displayTile;

@end
