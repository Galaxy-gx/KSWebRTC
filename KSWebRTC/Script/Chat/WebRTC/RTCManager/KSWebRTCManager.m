//
//  KSWebRTCManager.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/12.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSWebRTCManager.h"

@interface KSWebRTCManager()<KSMessageHandlerDelegate,KSMediaConnectionDelegate>
@property (nonatomic, strong) KSMessageHandler  *msgHandler;
@property (nonatomic, strong) KSMediaCapturer   *mediaCapture;
@property (nonatomic, strong) KSMediaConnection *peerConnection;
@property (nonatomic, strong) NSMutableArray    *videoTracks;
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

- (void)initRTCWithMediaSetting:(KSMediaSetting *)mediaSetting {
    _mediaSetting              = mediaSetting;
    _callType                  = mediaSetting.callType;
    _mediaCapture              = [[KSMediaCapturer alloc] initWithSetting:mediaSetting.capturerSetting];

    [self createLocalConnection];
}

- (void)createLocalConnection {
    KSMediaConnection *peerConnection = [[KSMediaConnection alloc] initWithSetting:_mediaSetting.connectionSetting];
    peerConnection.delegate           = self;
    _peerConnection                   = peerConnection;
    [peerConnection createPeerConnectionWithMediaCapturer:_mediaCapture];
    
    KSVideoTrack *videoTrack = [[KSVideoTrack alloc] init];
    videoTrack.videoTrack    = _mediaCapture.videoTrack;
    videoTrack.isLocal       = YES;
    videoTrack.callType      = _callType;
    videoTrack.handleId      = [self randomNumber];
    _localVideoTrack         = videoTrack;
    [self.videoTracks addObject:videoTrack];
}

- (NSNumber *)randomNumber {
    int random = (arc4random() % 10000) + 10000;
    return [NSNumber numberWithInt:random];
}

#pragma mark - KSMessageHandlerDelegate
- (KSMediaConnection *)messageHandlerOfLocalConnection {
    return self.peerConnection;
}

- (KSMediaCapturer *)mediaCaptureOfSectionsInMessageHandler:(KSMessageHandler *)messageHandler {
    return _mediaCapture;
}

- (void)messageHandler:(KSMessageHandler *)messageHandler didReceivedMessage:(KSMsg *)message {
    if ([self.delegate respondsToSelector:@selector(webRTCManager:didReceivedMessage:)]) {
        [self.delegate webRTCManager:self didReceivedMessage:message];
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

#pragma mark - KSMediaConnectionDelegate
// 收到远端流处理
//- (void)mediaConnection:(KSMediaConnection *)mediaConnection peerConnection:(RTCPeerConnection *)peerConnection didAddStream:(RTCMediaStream *)stream;

- (RTCVideoTrack *)mediaConnectionOfVideoTrack:(KSMediaConnection *)mediaConnection {
    return _mediaCapture.videoTrack;
}

// 收到候选者
- (void)mediaConnection:(KSMediaConnection *)mediaConnection peerConnection:(RTCPeerConnection *)peerConnection didGenerateIceCandidate:(RTCIceCandidate *)candidate {
    NSMutableDictionary *body =[NSMutableDictionary dictionary];
    if (candidate) {
        body[@"sdp"] = candidate.sdp;
        body[@"sdpMid"] = candidate.sdpMid;
        body[@"sdpMLineIndex"]  = @(candidate.sdpMLineIndex);
        [_msgHandler trickleCandidate:body];
    }
    else{
        [_msgHandler trickleCandidate:body];
    }
}

- (void)mediaConnection:(KSMediaConnection *)mediaConnection peerConnection:(RTCPeerConnection *)peerConnection didAddReceiver:(RTCRtpReceiver *)rtpReceiver streams:(NSArray<RTCMediaStream *> *)mediaStreams {
    RTCMediaStreamTrack *track = rtpReceiver.track;
    if([track.kind isEqualToString:kRTCMediaStreamTrackKindVideo]) {
        RTCVideoTrack *remoteVideoTrack = (RTCVideoTrack*)track;
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf addVideoTrack:remoteVideoTrack];
        });
    }
}

- (void)addVideoTrack:(RTCVideoTrack *)videoTrack {
    KSVideoTrack *remoteVideoTrack = [[KSVideoTrack alloc] init];
    remoteVideoTrack.videoTrack    = videoTrack;
    remoteVideoTrack.callType      = _callType;
    remoteVideoTrack.handleId      = [self randomNumber];
    remoteVideoTrack.index         = self.videoTrackCount;
    [self.videoTracks addObject:remoteVideoTrack];
    if ([self.delegate respondsToSelector:@selector(webRTCManager:didAddVideoTrack:)]) {
        [self.delegate webRTCManager:self didAddVideoTrack:remoteVideoTrack];
    }
}

- (void)mediaConnection:(KSMediaConnection *)mediaConnection peerConnection:(RTCPeerConnection *)peerConnection didChangeIceConnectionState:(RTCIceConnectionState)newState {
    switch (newState) {
        case RTCIceConnectionStateDisconnected:
        case RTCIceConnectionStateClosed:
        case RTCIceConnectionStateFailed:
        {
            if (mediaConnection.isClose) {
                return;
            }
            mediaConnection.isClose      = YES;
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                //[weakSelf leaveOfHandleId:mediaConnection.handleId];
            });
        }
            break;
            
        default:
            break;
    }
}

- (void)leaveOfHandleId:(NSNumber *)handleId {
    KSVideoTrack *videoTrack = [self videoTrackOfHandleId:handleId];
    if (videoTrack == nil) {
        return;
    }
    [self removeVideoTrack:videoTrack];
    
    if ([self.delegate respondsToSelector:@selector(webRTCManager:leaveOfVideoTrack:)]) {
        [self.delegate webRTCManager:self leaveOfVideoTrack:videoTrack];
    }
    if (self.videoTracks.count == 1) {
        if ([self.delegate respondsToSelector:@selector(webRTCManagerHandlerEnd:)]) {
            [self.delegate webRTCManagerHandlerEnd:self];
        }
        [self close];
    }
}

#pragma mark - Get
- (AVCaptureSession *)captureSession {
    return self.mediaCapture.capturer.captureSession;
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
    [[KSWebRTCManager shared].mediaCapture unmuteVideo];
}
+ (void)stopCapture {
    [[KSWebRTCManager shared].mediaCapture muteVideo];
    //[[KSWebRTCManager shared].mediaCapture stopCapture];
}
+ (void)speakerOff {
    [[KSWebRTCManager shared].mediaCapture speakerOff];
}
+ (void)speakerOn {
    [[KSWebRTCManager shared].mediaCapture speakerOn];
}

+ (void)muteAudio {
    [[KSWebRTCManager shared].mediaCapture muteAudio];
}

+ (void)unmuteAudio {
    [[KSWebRTCManager shared].mediaCapture unmuteAudio];
}

//SMediaConnection
+ (void)clearAllRenderer {
    for (KSVideoTrack *videoTrack in [KSWebRTCManager shared].videoTracks) {
        [videoTrack clearRenderer];
    }
}

//Socket
+ (void)socketConnectServer:(NSString *)server {
     [[KSWebRTCManager shared].msgHandler connectServer:server];
}

+ (void)socketClose {
    [[KSWebRTCManager shared].msgHandler close];
}

+ (void)sendOffer {
    [[KSWebRTCManager shared].msgHandler sendOffer];
}

+ (void)socketCreateSession {
    [[KSWebRTCManager shared].msgHandler createSession];
}

+ (void)socketSendHangup {
    //[[KSWebRTCManager shared].msgHandler requestHangup];
}

//data
+ (KSVideoTrack *)videoTrackOfIndex:(NSInteger)index {
    if (index >= [KSWebRTCManager shared].videoTracks.count) {
        return nil;
    }
    return [KSWebRTCManager shared].videoTracks[index];
}

+ (NSInteger)videoTrackCount {
    return [KSWebRTCManager shared].videoTracks.count;
}

+ (void)removeVideoTrackAtIndex:(int)index {
    if (index >= [KSWebRTCManager shared].videoTracks.count) {
        return;
    }
    KSVideoTrack *videoTrack = [KSWebRTCManager shared].videoTracks[index];
    [[KSWebRTCManager shared].videoTracks removeObjectAtIndex:index];
    [videoTrack clearRenderer];
    videoTrack               = nil;
}

- (void)removeVideoTrack:(KSVideoTrack *)videoTrack {
    if (videoTrack == nil) {
        return;
    }
    [self.videoTracks removeObject:videoTrack];
    [videoTrack clearRenderer];
}

- (void)close {
    for (KSVideoTrack *videoTrack in [KSWebRTCManager shared].videoTracks) {
        [videoTrack clearRenderer];
    }
    [[KSWebRTCManager shared].videoTracks removeAllObjects];

    [self.mediaCapture closeCapturer];
    self.mediaCapture = nil;
    
    [self.msgHandler close];
}

+ (void)close {
    [[KSWebRTCManager shared] close];
}

-(KSVideoTrack *)videoTrackOfHandleId:(NSNumber *)handleId {
    for (KSVideoTrack *videoTrack in self.videoTracks) {
        if (videoTrack.handleId == handleId) {
            return videoTrack;
        }
    }
    return nil;
}

#pragma mark - Get
- (int)videoTrackCount {
    return (int)self.videoTracks.count;
}

#pragma mark - 懒加载
- (NSMutableArray *)videoTracks {
    if (_videoTracks == nil) {
           _videoTracks = [NSMutableArray array];
       }
       return _videoTracks;
}

@end
