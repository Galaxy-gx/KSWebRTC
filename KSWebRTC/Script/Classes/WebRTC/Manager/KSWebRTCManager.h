//
//  KSWebRTCManager.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/12.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSMediaCapture.h"
#import "KSMediaConnection.h"
#import "KSCallState.h"
#import "KSMsg.h"
#import "KSMessageHandler.h"

@class KSWebRTCManager;
@protocol KSWebRTCManagerDelegate <NSObject>

@required
- (void)webRTCManagerHandlerEndOfSession:(KSWebRTCManager *)webRTCManager;
- (RTCEAGLVideoView *)remoteViewOfWebRTCManager:(KSWebRTCManager *)webRTCManager handleId:(NSNumber *)handleId;

@optional
//socket
- (void)webRTCManager:(KSWebRTCManager *)webRTCManager didReceivedMessage:(KSMsg *)message;
- (void)webRTCManager:(KSWebRTCManager *)webRTCManager leaveOfHandleId:(NSNumber *)handleId;
- (void)webRTCManagerSocketDidOpen:(KSWebRTCManager *)webRTCManager;
- (void)webRTCManagerSocketDidFail:(KSWebRTCManager *)webRTCManager;
@end

@interface KSWebRTCManager : NSObject

@property(nonatomic,weak)id<KSWebRTCManagerDelegate>      delegate;
@property (nonatomic, strong          ) KSMediaCapture    *mediaCapture;
@property (nonatomic, weak, readonly  ) KSMediaConnection *localConnection;
@property (nonatomic, assign, readonly) KSCallState       callState;
@property (nonatomic, assign          ) KSCallType        callType;
@property (nonatomic, assign          ) BOOL              isConnect;
@property (nonatomic, weak, readonly  ) AVCaptureSession  *captureSession;

+ (instancetype)shared;
- (void)initRTC;

//MediaCapture
+ (void)switchCamera;
+ (void)switchTalkMode;
+ (void)startCapture;
+ (void)stopCapture;
+ (void)speakerOff;
+ (void)speakerOn;
+ (void)closeMediaCapture;

//MediaConnection
+ (void)closeMediaConnection;
+ (void)muteAudio;
+ (void)unmuteAudio;

//Socket
+ (void)socketConnectServer:(NSString *)server;
+ (void)socketClose;
+ (void)socketCreateSession;
+ (void)socketSendHangup;

@end
