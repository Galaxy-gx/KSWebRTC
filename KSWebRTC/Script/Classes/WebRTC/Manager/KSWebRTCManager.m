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
@property (nonatomic, weak  ) KSMediaConnection *localConnection;
@property (nonatomic, strong) NSMutableArray    *mediaConnections;

@end

@implementation KSWebRTCManager

+ (instancetype)shared {
    static KSWebRTCManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        [instance initMsgHandler];
    });
    return instance;
}

- (void)initMsgHandler {
    _msgHandler          = [[KSMessageHandler alloc] init];
    _msgHandler.delegate = self;
}

- (void)initRTCWithCallType:(KSCallType)callType {
    _callType                  = callType;
    KSCapturerSetting *setting = [[KSCapturerSetting alloc] init];
    setting.isFront            = YES;
    setting.callType           = callType;
    setting.resolution         = CGSizeMake(540, 960);
    _mediaCapture              = [[KSMediaCapturer alloc] initWithSetting:setting];
}

#pragma mark - KSMessageHandlerDelegate
- (KSMediaConnection *)messageHandler:(KSMessageHandler *)messageHandler connectionOfHandleId:(NSNumber *)handleId {
    //若不返回错误，则ICE错误
    return  [self mediaConnectionOfHandleId:handleId];
}

- (KSMediaCapturer *)mediaCaptureOfSectionsInMessageHandler:(KSMessageHandler *)messageHandler {
    return _mediaCapture;
}

- (void)messageHandler:(KSMessageHandler *)messageHandler didReceivedMessage:(KSMsg *)message {
    if ([self.delegate respondsToSelector:@selector(webRTCManager:didReceivedMessage:)]) {
        [self.delegate webRTCManager:self didReceivedMessage:message];
    }
}

- (void)messageHandler:(KSMessageHandler *)messageHandler leaveOfHandleId:(NSNumber *)handleId {
    KSMediaConnection *connection = [self mediaConnectionOfHandleId:handleId];
    if (connection == nil) {
        return;
    }
    [self removeConnection:connection];
    
    if ([self.delegate respondsToSelector:@selector(webRTCManager:leaveOfConnection:)]) {
        [self.delegate webRTCManager:self leaveOfConnection:connection];
    }
    if (self.mediaConnections.count == 1) {
        if ([self.delegate respondsToSelector:@selector(webRTCManagerHandlerEndOfSession:)]) {
            [self.delegate webRTCManagerHandlerEndOfSession:self];
        }
        [self close];
    }
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

- (void)messageHandler:(KSMessageHandler *)messageHandler didAddMediaConnection:(KSMediaConnection *)connection {
    if (connection.mediaInfo.isLocal) {
        _localConnection = connection;
    }
    connection.index = (int)self.mediaConnections.count;
    [self.mediaConnections addObject:connection];
    NSLog(@"|------------| 01 didAddMediaConnection : %lu |------------|",(unsigned long)self.mediaConnections.count);
    [self.delegate webRTCManager:self didAddMediaConnection:connection];
}

#pragma mark - Get
-(AVCaptureSession *)captureSession {
    return self.mediaCapture.capturer.captureSession;
}

-(KSCallState)callState {
    return _msgHandler.callState;
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

//data
+ (KSMediaConnection *)connectionOfIndex:(NSInteger)index {
    if (index >= [KSWebRTCManager shared].mediaConnections.count) {
        return nil;
    }
    return [KSWebRTCManager shared].mediaConnections[index];
}

+ (NSInteger)connectionCount {
    return [KSWebRTCManager shared].mediaConnections.count;
}

+ (void)removeConnectionAtIndex:(int)index {
    if (index >= [KSWebRTCManager shared].mediaConnections.count) {
        return;
    }
    KSMediaConnection *connection = [KSWebRTCManager shared].mediaConnections[index];
    [[KSWebRTCManager shared].mediaConnections removeObjectAtIndex:index];
    [connection close];
    connection                    = nil;
}

- (void)removeConnection:(KSMediaConnection *)connection {
    if (connection == nil) {
        return;
    }
    [self.mediaConnections removeObject:connection];
    [connection close];
}

- (void)close {
    for (KSMediaConnection *connection in self.mediaConnections) {
        [connection close];
    }
    [self.mediaConnections removeAllObjects];
    [self.mediaCapture close];

    self.mediaCapture = nil;
    [self.msgHandler close];
    
    //self.msgHandler   = nil;
}

-(KSMediaConnection *)mediaConnectionOfHandleId:(NSNumber *)handleId {
    for (KSMediaConnection *connection in self.mediaConnections) {
        if (connection.handleId == handleId) {
            return connection;
        }
    }
    return nil;
}

#pragma mark - 懒加载
-(NSMutableArray *)mediaConnections {
    if (_mediaConnections == nil) {
        _mediaConnections = [NSMutableArray array];
    }
    return _mediaConnections;
}

@end
