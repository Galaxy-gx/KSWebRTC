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
#import "KSMediaInfo.h"

@class KSWebRTCManager;
@protocol KSWebRTCManagerDelegate <NSObject>
@optional
//socket
- (void)webRTCManagerHandlerEndOfSession:(KSWebRTCManager *)webRTCManager;
- (void)webRTCManager:(KSWebRTCManager *)webRTCManager didReceivedMessage:(KSMsg *)message;
- (void)webRTCManager:(KSWebRTCManager *)webRTCManager leaveOfHandleId:(NSNumber *)handleId connection:(KSMediaConnection *)connection;
- (void)webRTCManagerSocketDidOpen:(KSWebRTCManager *)webRTCManager;
- (void)webRTCManagerSocketDidFail:(KSWebRTCManager *)webRTCManager;

//Media
//若使用UICollectionView则不必实现
- (RTCEAGLVideoView *)remoteViewOfWebRTCManager:(KSWebRTCManager *)webRTCManager handleId:(NSNumber *)handleId;
- (void)webRTCManager:(KSWebRTCManager *)webRTCManager didAddMediaConnection:(KSMediaConnection *)connection;

@end

@interface KSWebRTCManager : NSObject

@property(nonatomic,weak)id<KSWebRTCManagerDelegate>      delegate;
@property (nonatomic, strong          ) KSMediaCapture    *mediaCapture;//本地
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

//data
+ (KSMediaConnection *)connectionOfIndex:(NSInteger)index;
+ (NSInteger)connectionCount;
+ (void)removeConnectionAtIndex:(int)index;
+ (void)removeConnection:(KSMediaConnection *)connection;

@end
