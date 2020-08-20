//
//  KSWebRTCManager.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/12.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSMediaCapturer.h"
#import "KSMediaConnection.h"
#import "KSCallState.h"
#import "KSMsg.h"
#import "KSMessageHandler.h"
#import "KSVideoTrack.h"

@class KSWebRTCManager;
@protocol KSWebRTCManagerDelegate <NSObject>
@optional
//socket
- (void)webRTCManagerHandlerEnd:(KSWebRTCManager *)webRTCManager;
- (void)webRTCManager:(KSWebRTCManager *)webRTCManager didReceivedMessage:(KSMsg *)message;
- (void)webRTCManagerSocketDidOpen:(KSWebRTCManager *)webRTCManager;
- (void)webRTCManagerSocketDidFail:(KSWebRTCManager *)webRTCManager;

//Media
- (void)webRTCManager:(KSWebRTCManager *)webRTCManager didAddVideoTrack:(KSVideoTrack *)videoTrack;
- (void)webRTCManager:(KSWebRTCManager *)webRTCManager leaveOfVideoTrack:(KSVideoTrack *)videoTrack;
@end

@interface KSWebRTCManager : NSObject

@property(nonatomic,weak)id<KSWebRTCManagerDelegate>    delegate;
@property (nonatomic, weak, readonly) AVCaptureSession  *captureSession;
@property (nonatomic, weak, readonly) KSVideoTrack *localVideoTrack;
@property (nonatomic, assign, readonly) int     videoTrackCount;
@property (nonatomic, strong) KSMediaSetting *mediaSetting;
@property (nonatomic, assign) KSCallType     callType;
@property (nonatomic, assign) BOOL           isConnect;
@property (nonatomic, assign) KSCallState    callState;

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

+ (void)clearAllRenderer;

- (void)close;
+ (void)close;

//Socket
+ (void)socketConnectServer:(NSString *)server;
+ (void)socketClose;
+ (void)socketCreateSession;
+ (void)socketSendHangup;

//data
+ (KSVideoTrack *)videoTrackOfIndex:(NSInteger)index;
+ (NSInteger)connectionCount;
+ (void)removeConnectionAtIndex:(int)index;

@end
