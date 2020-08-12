//
//  KSWebRTCManager.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/12.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSWebRTCManager.h"

@interface KSWebRTCManager()<KSMessageHandlerDelegate>

@property (nonatomic, strong) KSMessageHandler  *msgHandler;

@end

@implementation KSWebRTCManager

+ (instancetype)shared {
    static KSWebRTCManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)initRTC {
    _mediaCapture                    = [[KSMediaCapture alloc] init];
    [_mediaCapture createPeerConnectionFactory];
    [_mediaCapture captureLocalMedia];
    
    _msgHandler                      = [[KSMessageHandler alloc] init];
    _msgHandler.delegate             = self;
}

#pragma mark - KSMessageHandlerDelegate
- (void)messageHandlerEndOfSession:(KSMessageHandler *)messageHandler {
    if ([self.delegate respondsToSelector:@selector(webRTCManagerHandlerEndOfSession:)]) {
        [self.delegate webRTCManagerHandlerEndOfSession:self];
    }
}

- (void)messageHandler:(KSMessageHandler *)messageHandler didReceivedMessage:(KSMsg *)message {
    if ([self.delegate respondsToSelector:@selector(webRTCManager:didReceivedMessage:)]) {
        [self.delegate webRTCManager:self didReceivedMessage:message];
    }
}

- (void)messageHandler:(KSMessageHandler *)messageHandler leaveOfHandleId:(NSNumber *)handleId {
    if ([self.delegate respondsToSelector:@selector(webRTCManager:leaveOfHandleId:)]) {
        [self.delegate webRTCManager:self leaveOfHandleId:handleId];
    }
}

- (KSMediaCapture *)mediaCaptureOfSectionsInMessageHandler:(KSMessageHandler *)messageHandler {
    return _mediaCapture;
}

- (RTCEAGLVideoView *)remoteViewOfSectionsInMessageHandler:(KSMessageHandler *)messageHandler handleId:(NSNumber *)handleId {
    return [self.delegate remoteViewOfWebRTCManager:self handleId:handleId];
}

- (void)messageHandler:(KSMessageHandler *)messageHandler socketDidOpen:(KSWebSocket *)socket {
    _isConnect = YES;
    if ([self.delegate respondsToSelector:@selector(webRTCManagerSocketDidOpen:)]) {
        [self.delegate webRTCManagerSocketDidOpen:self];
    }
}

- (void)messageHandler:(KSMessageHandler *)messageHandler socketDidFail:(KSWebSocket *)socket {
    _isConnect = NO;
    if ([self.delegate respondsToSelector:@selector(webRTCManagerSocketDidFail:)]) {
        [self.delegate webRTCManagerSocketDidFail:self];
    }
}

#pragma mark - Get
-(AVCaptureSession *)captureSession {
    return self.mediaCapture.capturer.captureSession;
}

-(KSCallState)callState {
    return _msgHandler.callState;
}

-(KSMediaConnection *)localConnection {
    return _msgHandler.localConnection;
}

#pragma mark - 事件
//MediaCapture
+ (void)switchCamera {
    [[KSWebRTCManager shared].mediaCapture switchCamera];
}
+ (void)switchTalkMode {
    [[KSWebRTCManager shared].mediaCapture switchTalkMode];
}
+ (void)startCapture {
    [[KSWebRTCManager shared].mediaCapture startCapture];
}
+ (void)stopCapture {
    [[KSWebRTCManager shared].mediaCapture stopCapture];
}
+ (void)speakerOff {
    [[KSWebRTCManager shared].mediaCapture speakerOff];
}
+ (void)speakerOn {
    [[KSWebRTCManager shared].mediaCapture speakerOn];
}
+ (void)closeMediaCapture {
    [[KSWebRTCManager shared].mediaCapture close];
    [KSWebRTCManager shared].mediaCapture = nil;
}

//MediaConnection
+ (void)closeMediaConnection {
    [[KSWebRTCManager shared].localConnection close];
}
+ (void)muteAudio {
    [[KSWebRTCManager shared].localConnection muteAudio];
}
+ (void)unmuteAudio {
    [[KSWebRTCManager shared].localConnection unmuteAudio];
}

//Socket
+ (void)socketConnectServer:(NSString *)server {
     [[KSWebRTCManager shared].msgHandler connectServer:server];
}

+ (void)socketClose {
    [[KSWebRTCManager shared].msgHandler close];
}

+ (void)socketCreateSession {
    [[KSWebRTCManager shared].msgHandler createSession];
}

+ (void)socketSendHangup {
    [[KSWebRTCManager shared].msgHandler requestHangup];
}

@end
