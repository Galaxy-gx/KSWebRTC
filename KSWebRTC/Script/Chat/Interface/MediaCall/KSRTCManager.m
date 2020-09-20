//
//  KSRTCManager.m
//  KSWebRTC
//
//  Created by saeipi on 2020/9/15.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSRTCManager.h"
#import <WebRTC/WebRTC.h>
#import "NSDictionary+Category.h"
#import "NSString+Category.h"
#import "UIViewController+Category.h"
#import "KSUserInfo.h"
#import "KSRegex.h"
#import "KSTimekeeper.h"
#import "KSNotification.h"
#import "KSCoolTile.h"
#import "KSAudioPlayer.h"
#import "KSSocketHandler.h"
#import "KSMediaCallController.h"
static int const kLocalRTCIdentifier = 10101024;

@interface KSRTCManager()<KSMessageHandlerDelegate,KSMediaConnectionDelegate,KSMediaCapturerDelegate,KSMediaTrackDataSource,KSCoolTileDelegate>
@property (nonatomic, strong) KSMessageHandler  *msgHandler;
@property (nonatomic, strong) KSMediaCapturer   *mediaCapturer;
@property (nonatomic, weak  ) KSMediaConnection *peerConnection;
@property (nonatomic, strong) NSMutableArray    *mediaTracks;
@property (nonatomic, strong) KSTimekeeper      *timekeeper;
@property (nonatomic, strong) KSCoolTile        *coolTile;
@property (nonatomic, strong) KSAudioPlayer     *audioPlayer;
@end

@implementation KSRTCManager

+ (instancetype)shared {
    static KSRTCManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        [instance initManager];
    });
    return instance;
}

- (void)initManager {
    _msgHandler          = [[KSSocketHandler alloc] init];
    _msgHandler.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate:)
                                                 name:KS_NotificationName_ApplicationWillTerminate
                                               object:nil];
}

#pragma mark - applicationWillTerminate
- (void)applicationWillTerminate:(UIApplication *)application {
    if (self.callState != KSCallStateMaintenanceNormal) {
       //TODO:关闭app时，非默认状态，则发送离开消息
        
    }
}

#pragma mark - RTC初始化
+ (void)initRTCWithMediaSetting:(KSMediaSetting *)mediaSetting {
    [[KSRTCManager shared] initRTCWithMediaSetting:mediaSetting];
}

- (void)initRTCWithMediaSetting:(KSMediaSetting *)mediaSetting {
    _mediaSetting           = mediaSetting;
    _callType               = mediaSetting.callType;

    [self createMediaCapturer];
    [self createLocalMediaTrack];
}

#pragma mark - KSMediaCapturer
- (void)createMediaCapturer {
    _mediaCapturer          = [[KSMediaCapturer alloc] initWithSetting:_mediaSetting.capturerSetting];
    _mediaCapturer.delegate = self;
    [_mediaCapturer addMediaSource];
    
    if (_callType == KSCallTypeSingleVideo || _callType == KSCallTypeManyVideo) {
        [_mediaCapturer startCapture];
    }
}

#pragma mark - KSMediaConnection
- (void)createLocalMediaTrack {
    KSMediaTrack *localMediaTrack     = [[KSMediaTrack alloc] init];
    localMediaTrack.videoTrack        = _mediaCapturer.videoTrack;
    localMediaTrack.audioTrack        = _mediaCapturer.audioTrack;
    localMediaTrack.dataSource        = self;
    localMediaTrack.isLocal           = YES;
    localMediaTrack.index             = 0;
    localMediaTrack.sessionId         = kLocalRTCIdentifier;
    localMediaTrack.userInfo          = [KSUserInfo myself];
    _localMediaTrack                  = localMediaTrack;
    [self.mediaTracks insertObject:localMediaTrack atIndex:0];
}

- (KSMediaConnection *)createPeerConnection {
    KSMediaConnection *peerConnection = [[KSMediaConnection alloc] initWithSetting:[_mediaSetting.connectionSetting mutableCopy]];
    peerConnection.delegate           = self;
    [peerConnection createPeerConnectionWithMediaCapturer:_mediaCapturer];
    return peerConnection;
}

#pragma mark - KSMediaCapturerDelegate
- (KSCallType)callTypeOfMediaCapturer:(KSMediaCapturer *)mediaCapturer {
    return _callType;
}

- (KSScale)scaleOfMediaCapturer:(KSMediaCapturer *)mediaCapturer {
    switch (_callType) {
        case KSCallTypeSingleVideo:
            return KSScaleMake(9, 16);
            break;
        case KSCallTypeManyVideo:
            return KSScaleMake(3, 4);
            break;
        default:
            break;
    }
    return KSScaleMake(9, 16);
}

#pragma mark - KSMediaConnectionDelegate
// 收到远端流处理
//- (void)mediaConnection:(KSMediaConnection *)mediaConnection peerConnection:(RTCPeerConnection *)peerConnection didAddStream:(RTCMediaStream *)stream;

- (KSMediaCapturer *)mediaCapturerOfMediaConnection:(KSMediaConnection *)mediaConnection {
    return _mediaCapturer;
}

- (KSCallType)callTypeOfMediaConnection:(KSMediaConnection *)mediaConnection {
    return _callType;
}

// 收到候选者
- (void)mediaConnection:(KSMediaConnection *)mediaConnection peerConnection:(RTCPeerConnection *)peerConnection didGenerateIceCandidate:(RTCIceCandidate *)candidate {
    NSMutableDictionary *body =[NSMutableDictionary dictionary];
    if (candidate) {
        body[@"sdp"]           = candidate.sdp;
        body[@"sdpMid"]        = candidate.sdpMid;
        body[@"sdpMLineIndex"] = @(candidate.sdpMLineIndex);
        [_msgHandler trickleCandidate:body];
    }
}

- (void)mediaConnection:(KSMediaConnection *)mediaConnection peerConnection:(RTCPeerConnection *)peerConnection didAddReceiver:(RTCRtpReceiver *)rtpReceiver streams:(NSArray<RTCMediaStream *> *)mediaStreams {
    RTCSessionDescription *remoteDescription = peerConnection.remoteDescription;
    NSString *remoteSDP                      = remoteDescription.sdp;
    RTCMediaStreamTrack *track               = rtpReceiver.track;
    NSLog(@"|============| didAddReceiver kind : %@, handleId : %lld, myHandleId : %lld |============|",track.kind,mediaConnection.handleId,self.peerConnection.handleId);
    
    if (_callType == KSCallTypeSingleAudio || _callType == KSCallTypeManyAudio) {
        if([track.kind isEqualToString:kRTCMediaStreamTrackKindAudio]) {
            KSMediaTrack *mediaTrack = [self mediaTrackOfSdp:remoteSDP];
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                RTCAudioTrack *remoteAudioTrack = (RTCAudioTrack*)track;
                mediaTrack.audioTrack           = remoteAudioTrack;
                [weakSelf callbackMediaTrack:mediaTrack];
            });
        }
    }
    else if (_callType == KSCallTypeSingleVideo || _callType == KSCallTypeManyVideo) {
        if([track.kind isEqualToString:kRTCMediaStreamTrackKindVideo]) {
            KSMediaTrack *mediaTrack = [self mediaTrackOfSdp:remoteSDP];
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                RTCVideoTrack *remoteVideoTrack = (RTCVideoTrack*)track;
                mediaTrack.videoTrack           = remoteVideoTrack;
                [weakSelf callbackMediaTrack:mediaTrack];
            });
        }
    }
}

- (void)callbackMediaTrack:(KSMediaTrack *)mediaTrack {
    [KSRTCManager shared].callState = KSCallStateMaintenanceRecording;//05:通话中
    if ([self.delegate respondsToSelector:@selector(rtcManager:didAddMediaTrack:)]) {
        [self.delegate rtcManager:self didAddMediaTrack:mediaTrack];
    }
    //小窗显示逻辑
    [self updateTileMediaTrack];
}

- (void)mediaConnection:(KSMediaConnection *)mediaConnection peerConnection:(RTCPeerConnection *)peerConnection didChangeIceConnectionState:(RTCIceConnectionState)newState jseps:(NSMutableDictionary *)jseps {
    if ([KSRTCManager shared].callState != KSCallStateMaintenanceRecording) {//非连接状态不处理
        return;
    }
    switch (newState) {
        case RTCIceConnectionStateDisconnected:
        case RTCIceConnectionStateFailed:
        {
            if (self.callState != KSCallStateMaintenanceRecording) {
                return;
            }
            
            [self.msgHandler sendMessage:jseps type:@"peerdesc_req"];
            //__weak typeof(self) weakSelf = self;
            [self.timekeeper countdownOfSecond:5 callback:^(BOOL isEnd) {
                //未及时收到响应
            }];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - KSMediaTrackDataSource
- (KSCallType)callTypeOfMediaTrack:(KSMediaTrack *)mediaTrack {
    return self.callType;
}

#pragma mark - Get
- (AVCaptureSession *)captureSession {
    return self.mediaCapturer.capturer.captureSession;
}

- (long long)peerId {
    return self.session.peerId;
}

-(BOOL)isCalled {
    return self.session.isCalled;
}

#pragma mark - KSMediaTrack管理
+ (void)clearAllRenderer {
    for (KSMediaTrack *videoTrack in [KSRTCManager shared].mediaTracks) {
        [videoTrack clearRenderer];
    }
}

+ (KSMediaTrack *)mediaTrackOfIndex:(NSInteger)index {
    if (index >= (int)[KSRTCManager shared].mediaTracks.count) {
        return nil;
    }
    return [KSRTCManager shared].mediaTracks[index];
}

//创建KSMediaTrack
- (KSMediaTrack *)remoteMediaTrackWithSdp:(NSString *)sdp userId:(long long)userId {
    NSArray *array = [sdp componentsSeparatedByString:@"\n"];
    if (array.count > 1) {
        NSString *ID        = [KSRegex sdpSessionOfString:array[1]];
        KSMediaTrack *track = [self remoteMediaTrackOfUserId:userId];
        track.sessionId     = [ID longLongValue];
        return track;
    }
    return nil;
}

//获取KSMediaTrack
- (KSMediaTrack *)mediaTrackOfSdp:(NSString *)sdp {
    NSArray *array = [sdp componentsSeparatedByString:@"\n"];
    if (array.count > 1) {
        NSString *ID = [KSRegex sdpSessionOfString:array[1]];
        return [self mediaTrackOfSessionId:[ID longLongValue]];
    }
    return nil;
}

- (KSMediaTrack *)mediaTrackOfSessionId:(long long)ID {
    for (KSMediaTrack *track in self.mediaTracks) {
        if (track.sessionId == ID) {
            return track;
        }
    }
    return nil;
}

- (KSMediaTrack *)mediaTrackOfUserId:(long long)ID {
    for (KSMediaTrack *track in self.mediaTracks) {
        if (track.userInfo.ID == ID) {
            return track;
        }
    }
    return nil;
}

- (KSMediaTrack *)remoteMediaTrackOfUserId:(long long)ID  {
    KSMediaTrack *track = [self mediaTrackOfUserId:ID];
    if (track) {
        return track;
    }
    KSMediaConnection *peerConnection = [self createPeerConnection];
    peerConnection.handleId           = ID;
    track                             = [[KSMediaTrack alloc] init];
    track.peerConnection              = peerConnection;
    track.index                       = self.mediaTrackCount;
    track.dataSource                  = self;
    track.mediaState                  = KSMediaStateUnmuteAudio;
    KSUserInfo *userInfo              = [KSUserInfo userWithId:ID];
    track.userInfo                    = userInfo;
    [self.mediaTracks addObject:track];//添加到数组
    return track;
}

+ (NSInteger)mediaTrackCount {
    return [KSRTCManager shared].mediaTracks.count;
}

+ (void)removeMediaTrackAtIndex:(int)index {
    if (index >= (int)[KSRTCManager shared].mediaTracks.count) {
        return;
    }
    KSMediaTrack *videoTrack = [KSRTCManager shared].mediaTracks[index];
    [[KSRTCManager shared].mediaTracks removeObjectAtIndex:index];
    [videoTrack clearRenderer];
    videoTrack               = nil;
}

- (void)removeMediaTrack:(KSMediaTrack *)mediaTrack {
    if (mediaTrack == nil) {
        return;
    }
    [self.mediaTracks removeObject:mediaTrack];
    [mediaTrack clearRenderer];
}

- (int)mediaTrackCount {
    return (int)self.mediaTracks.count;
}

- (KSMediaTrack *)screenMediaTrack {
    if (self.callType == KSCallTypeSingleAudio) {
        return self.mediaTracks.firstObject;
    }
    
    if (self.callState == KSCallStateMaintenanceRecording) {
        return self.mediaTracks.lastObject;
    }
    else{
        return self.mediaTracks.firstObject;
    }
}

- (KSMediaTrack *)tileMediaTrack {
    if (self.callType == KSCallTypeSingleAudio) {
        return self.mediaTracks.lastObject;
    }
    
    if (self.callState == KSCallStateMaintenanceRecording) {
         return self.mediaTracks.firstObject;
    }
    return nil;
}

#pragma mark - KSCoolTile
- (KSMediaTrack *)displayMediaTrack {
    if (self.callType == KSCallTypeSingleAudio) {
        return [self tileMediaTrack];
    }
    return [self screenMediaTrack];
}

+ (void)displayTile {
    [[KSRTCManager shared] displayTile];
}

- (void)displayTile {
    KSMediaTrack *mediaTrack = [self displayMediaTrack];
    if (self.coolTile.isDisplay && (self.coolTile.mediaTrack.sessionId == mediaTrack.sessionId)) {
        return;
    }
    [self.coolTile showMediaTrack:mediaTrack];
}

- (void)updateTileMediaTrack {
    if (_coolTile == nil) {
        return;
    }
    if (_coolTile.isDisplay == NO) {
        return;
    }
    [self displayTile];
}

//KSCoolTileDelegate
- (void)returnToCallInterfaceOfCoolTile:(KSCoolTile *)coolTile {
    [self enterChat];
}

#pragma mark - 进入通话页面
- (void)enterChat {
    UIViewController *currentCtrl = [UIViewController currentViewController];
    [KSMediaCallController callWithType:self.callType callState:self.callState isCaller:NO peerId:self.peerId target:currentCtrl];
}

#pragma mark - Scoekt
+ (void)callToUserid:(long long)userid {
    [[KSRTCManager shared].msgHandler callToUserid:userid];
    
    [KSRTCManager shared].callState        = KSCallStateMaintenanceCaller;//01:主叫方发起Call
    [KSRTCManager shared].session.peerId   = userid;//对方ID更新01（有两处）
    [KSRTCManager shared].session.isCalled = NO;
    [[KSRTCManager shared].audioPlayer play];//播放响铃01（有两处）
}

+ (void)answerToUserid:(long long)userid {
    [[KSRTCManager shared].msgHandler answerToUserid:userid];
}

#pragma mark - KSMessageHandlerDelegate 调试
- (KSMediaConnection *)remotePeerConnectionOfMessageHandler:(KSMessageHandler *)messageHandler handleId:(NSNumber *)handleId sdp:(NSString *)sdp {
    return [self remoteMediaTrackWithSdp:sdp userId:[handleId longLongValue]].peerConnection;
}

- (KSMediaConnection *)localPeerConnectionOfMessageHandler:(KSMessageHandler *)messageHandler {
    if (_peerConnection == nil) {
        KSMediaConnection *peerConnection = [self createPeerConnection];
        peerConnection.handleId           = kLocalRTCIdentifier;
        _peerConnection                   = peerConnection;
        _localMediaTrack.peerConnection   = peerConnection;
    }
    return _peerConnection;
}

- (void)messageHandler:(KSMessageHandler *)messageHandler call:(KSCall *)call {
    [self.audioPlayer play];//播放响铃02（有两处）
    [KSRTCManager shared].callState = KSCallStateMaintenanceRinger;//02:被叫方收到Call准备响铃
    self.callType                   = call.callType;
    //记录
    self.session.peerId             = call.ID;//对方ID更新02（有两处）
    self.session.isCalled           = YES;//设置为被叫

    [self enterChat];
}

- (void)messageHandler:(KSMessageHandler *)messageHandler answer:(KSAnswer *)answer {
    if ([self.delegate respondsToSelector:@selector(rtcManager:answer:)]) {
        [self.delegate rtcManager:self answer:answer];
    }
}

@end
