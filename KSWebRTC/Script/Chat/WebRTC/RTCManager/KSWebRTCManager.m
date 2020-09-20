//
//  KSWebRTCManager.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/12.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSWebRTCManager.h"
#import <WebRTC/WebRTC.h>
#import "NSDictionary+Category.h"
#import "NSString+Category.h"
#import "UIViewController+Category.h"
#import "KSChatController.h"
#import "KSUserInfo.h"
#import "KSRegex.h"
#import "KSTimekeeper.h"
#import "KSNotification.h"
#import "KSCoolTile.h"
#import "KSAudioPlayer.h"

typedef NS_ENUM(NSInteger, KSChangeMediaType) {
    KSChangeMediaTypeUnknown = 0,
    KSChangeMediaTypeVoice   = 1,
    KSChangeMediaTypeVideo   = 2,
};

@interface KSWebRTCManager()<KSMessageHandlerDelegate,KSMediaConnectionDelegate,KSMediaCapturerDelegate,KSMediaTrackDataSource,KSCoolTileDelegate>
@property (nonatomic, strong) KSMessageHandler   *msgHandler;
@property (nonatomic, strong) KSMediaCapturer    *mediaCapturer;
@property (nonatomic, weak  ) KSMediaTrack       *myMediaTrack;
@property (nonatomic, strong) NSMutableArray     *mediaTracks;
@property (nonatomic, strong) KSTimekeeper       *timekeeper;
@property (nonatomic, strong) KSCoolTile         *coolTile;
@property (nonatomic, strong) KSAudioPlayer      *audioPlayer;
@end

@implementation KSWebRTCManager

+ (instancetype)shared {
    static KSWebRTCManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance          = [[self alloc] init];
        [instance initManager];
    });
    return instance;
}

- (void)initManager {
    _msgHandler          = [[KSMessageHandler alloc] init];
    _msgHandler.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate:)
                                                 name:KS_NotificationName_ApplicationWillTerminate
                                               object:nil];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - applicationWillTerminate
- (void)applicationWillTerminate:(UIApplication *)application {
    if (self.callState != KSCallStateMaintenanceNormal) {
        //TODO:关闭app时，非默认状态，则发送离开消息
        
    }
}

#pragma mark - RTC初始化
+ (void)initRTCWithMediaSetting:(KSMediaSetting *)mediaSetting {
    [[KSWebRTCManager shared] initRTCWithMediaSetting:mediaSetting];
}

- (void)initRTCWithMediaSetting:(KSMediaSetting *)mediaSetting {
    _mediaSetting           = mediaSetting;
    _callType               = mediaSetting.callType;
    
    [self createMediaCapturer];
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
/*
- (void)createLocalMediaTrack {
    KSMediaTrack *localMediaTrack     = [[KSMediaTrack alloc] init];
    localMediaTrack.videoTrack        = _mediaCapturer.videoTrack;
    localMediaTrack.audioTrack        = _mediaCapturer.audioTrack;
    localMediaTrack.dataSource        = self;
    localMediaTrack.isLocal           = YES;
    localMediaTrack.index             = 0;
    localMediaTrack.userInfo          = [KSUserInfo myself];
    _localMediaTrack                  = localMediaTrack;
    [self.mediaTracks insertObject:localMediaTrack atIndex:0];
}
 */

- (KSMediaConnection *)createPeerConnection {
    KSMediaConnection *peerConnection = [[KSMediaConnection alloc] initWithSetting:[_mediaSetting.connectionSetting mutableCopy]];
    peerConnection.delegate           = self;
    [peerConnection createPeerConnectionWithMediaCapturer:_mediaCapturer];
    return peerConnection;
}

#pragma mark - KSMessageHandlerDelegate 调试
- (KSMediaConnection *)peerConnectionOfMessageHandler:(KSMessageHandler *)messageHandler handleId:(NSNumber *)handleId {
    return [self mediaTrackOfHandleId:[handleId longLongValue]].peerConnection;
}

- (KSCallType)callTypeOfMessageHandler:(KSMessageHandler *)messageHandler {
    return _callType;
}

- (void)messageHandler:(KSMessageHandler *)messageHandler socketDidOpen:(KSWebSocket *)socket {
    if ([self.delegate respondsToSelector:@selector(webRTCManagerSocketDidOpen:)]) {
        [self.delegate webRTCManagerSocketDidOpen:self];
    }
}

- (void)messageHandler:(KSMessageHandler *)messageHandler socketDidFail:(KSWebSocket *)socket {
    if ([self.delegate respondsToSelector:@selector(webRTCManagerSocketDidFail:)]) {
        [self.delegate webRTCManagerSocketDidFail:self];
    }
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
        body[@"sdp"] = candidate.sdp;
        body[@"sdpMid"] = candidate.sdpMid;
        body[@"sdpMLineIndex"]  = @(candidate.sdpMLineIndex);
        [_msgHandler sendCandidate:body];
    }
}

- (void)mediaConnection:(KSMediaConnection *)mediaConnection peerConnection:(RTCPeerConnection *)peerConnection didAddReceiver:(RTCRtpReceiver *)rtpReceiver streams:(NSArray<RTCMediaStream *> *)mediaStreams {
    /*
     RTCSessionDescription *remoteDescription = peerConnection.remoteDescription;
     NSString *remoteSDP                      = remoteDescription.sdp;
     */
    RTCMediaStreamTrack *track               = rtpReceiver.track;
    NSLog(@"|============| didAddReceiver kind : %@, handleId : %lld, myHandleId : %lld |============|",track.kind,mediaConnection.handleId,self.localMediaTrack.peerConnection.handleId);
    
    if (_callType == KSCallTypeSingleAudio || _callType == KSCallTypeManyAudio) {
        if([track.kind isEqualToString:kRTCMediaStreamTrackKindAudio]) {
            KSMediaTrack *mediaTrack = [self mediaTrackOfHandleId:mediaConnection.handleId];
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
            KSMediaTrack *mediaTrack = [self mediaTrackOfHandleId:mediaConnection.handleId];
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
    [KSWebRTCManager shared].callState = KSCallStateMaintenanceRecording;//05:通话中
    if ([self.delegate respondsToSelector:@selector(webRTCManager:didAddMediaTrack:)]) {
        [self.delegate webRTCManager:self didAddMediaTrack:mediaTrack];
    }
    //小窗显示逻辑
    [self updateTileMediaTrack];
}

- (void)mediaConnection:(KSMediaConnection *)mediaConnection peerConnection:(RTCPeerConnection *)peerConnection didChangeIceConnectionState:(RTCIceConnectionState)newState jseps:(NSMutableDictionary *)jseps {
    if ([KSWebRTCManager shared].callState != KSCallStateMaintenanceRecording) {//非连接状态不处理
        return;
    }
    switch (newState) {
        case RTCIceConnectionStateDisconnected:
        case RTCIceConnectionStateFailed:
            break;
        default:
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(webRTCManager:mediaConnection:peerConnection:didChangeIceConnectionState:)]) {
        [self.delegate webRTCManager:self mediaConnection:mediaConnection peerConnection:peerConnection didChangeIceConnectionState:newState];
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

-(BOOL)isCalled {
    return self.session.isCalled;
}

-(KSMediaTrack *)localMediaTrack {
    if (_myMediaTrack) {
        return _myMediaTrack;
    }
    for (KSMediaTrack *mediaTrack in self.mediaTracks) {
        if (mediaTrack.isLocal) {
            _myMediaTrack = mediaTrack;
            return mediaTrack;
        }
    }
    return nil;
}
#pragma mark - 设备操作
//MediaCapture
+ (void)switchCamera {
    [[KSWebRTCManager shared].mediaCapturer switchCamera];
}

+ (void)switchTalkMode {
    [[KSWebRTCManager shared].mediaCapturer switchTalkMode];
}

+ (void)startCapture {
    [self openVideo];
    
    [[KSWebRTCManager shared].mediaCapturer unmuteVideo];
}

//开启视频
+ (void)openVideo {
    NSMutableDictionary *media = [NSMutableDictionary dictionary];
    media[@"switch_type"]      = @(KSMediaStateUnmuteVideo);
    [[KSWebRTCManager shared].msgHandler sendMessage:media type:@"switch"];
}

+ (void)stopCapture {
    [self closeVideo];
    
    [[KSWebRTCManager shared].mediaCapturer muteVideo];
}

//关闭视频
+ (void)closeVideo {
    NSMutableDictionary *media = [NSMutableDictionary dictionary];
    media[@"switch_type"]      = @(KSMediaStateMuteVideo);
    [[KSWebRTCManager shared].msgHandler sendMessage:media type:@"switch"];
}

+ (void)speakerOff {
    [[KSWebRTCManager shared].mediaCapturer speakerOff];
}

+ (void)speakerOn {
    [[KSWebRTCManager shared].mediaCapturer speakerOn];
}

+ (void)muteAudio {
    [self closeVoice];
    
    [[KSWebRTCManager shared].mediaCapturer muteAudio];
}

//关闭语音
+ (void)closeVoice {
    NSMutableDictionary *media = [NSMutableDictionary dictionary];
    media[@"switch_type"]      = @(KSMediaStateMuteAudio);
    [[KSWebRTCManager shared].msgHandler sendMessage:media type:@"switch"];
}

+ (void)unmuteAudio {
    [self openVoice];
    
    [[KSWebRTCManager shared].mediaCapturer unmuteAudio];
}

//开启语音
+ (void)openVoice {
    NSMutableDictionary *media = [NSMutableDictionary dictionary];
    media[@"switch_type"]      = @(KSMediaStateUnmuteAudio);
    [[KSWebRTCManager shared].msgHandler sendMessage:media type:@"switch"];
}

+ (void)switchToSingleVideo {
    [[KSWebRTCManager shared] switchToSingleVideo];
}

//在此之前需更新callType
- (void)switchToSingleVideo {
    if (_callType == KSCallTypeSingleVideo) {
        if (_mediaCapturer.videoTrack == nil) {
            [self.localMediaTrack.peerConnection addVideoTrack];
            [_mediaCapturer startCapture];
            self.localMediaTrack.videoTrack = _mediaCapturer.videoTrack;
        }
        else{
            [_mediaCapturer unmuteVideo];
        }
    }
}

+ (void)switchToSingleAudio {
    [[KSWebRTCManager shared] switchToSingleAudio];
}

//在此之前需更新callType
- (void)switchToSingleAudio {
    if (_callType == KSCallTypeSingleAudio) {
        [_mediaCapturer muteVideo];
    }
}

//切换同步
//切换到视频通话
+ (void)switchToVideoCall {
    NSMutableDictionary *media = [NSMutableDictionary dictionary];
    media[@"media_type"]       = @(KSChangeMediaTypeVideo);
    [[KSWebRTCManager shared].msgHandler sendMessage:media type:@"change_media"];
}

//切换到语音通话
+ (void)switchToVoiceCall {
    NSMutableDictionary *media = [NSMutableDictionary dictionary];
    media[@"media_type"]       = @(KSChangeMediaTypeVoice);
    [[KSWebRTCManager shared].msgHandler sendMessage:media type:@"change_media"];
}


#pragma mark - Socket消息
+ (void)socketConnectServer:(NSString *)server {
    [[KSWebRTCManager shared].msgHandler connectServer:server];
}

+ (void)socketClose {
    [[KSWebRTCManager shared].msgHandler close];
}

+ (void)socketCreateSession {
    [[KSWebRTCManager shared].msgHandler createSession];
}

+ (void)sendOffer {
    
}

+ (void)socketSendHangup {
    //[[KSWebRTCManager shared].msgHandler requestHangup];
}

//业务消息
+ (void)joinRoom:(int)room {
    [[KSWebRTCManager shared].msgHandler joinRoom:room];
}

+ (void)createRoom:(int)room {
    [[KSWebRTCManager shared].msgHandler createRoom:room];
}

#pragma mark - KSMediaTrack管理
+ (void)clearAllRenderer {
    for (KSMediaTrack *videoTrack in [KSWebRTCManager shared].mediaTracks) {
        [videoTrack clearRenderer];
    }
}

+ (KSMediaTrack *)mediaTrackOfIndex:(NSInteger)index {
    if (index >= (int)[KSWebRTCManager shared].mediaTracks.count) {
        return nil;
    }
    return [KSWebRTCManager shared].mediaTracks[index];
}

+ (NSInteger)mediaTrackCount {
    return [KSWebRTCManager shared].mediaTracks.count;
}

+ (void)removeMediaTrackAtIndex:(int)index {
    if (index >= (int)[KSWebRTCManager shared].mediaTracks.count) {
        return;
    }
    KSMediaTrack *mediaTrack = [KSWebRTCManager shared].mediaTracks[index];
    [[KSWebRTCManager shared].mediaTracks removeObjectAtIndex:index];
    [mediaTrack clearRenderer];
    [mediaTrack.peerConnection closeConnection];
    mediaTrack               = nil;
}

- (void)removeMediaTrack:(KSMediaTrack *)mediaTrack {
    if (mediaTrack == nil) {
        return;
    }
    [self.mediaTracks removeObject:mediaTrack];
    [mediaTrack clearRenderer];
    [mediaTrack.peerConnection closeConnection];
}


- (KSMediaTrack *)mediaTrackOfHandleId:(long long)handleId {
    for (KSMediaTrack *mediaTrack in self.mediaTracks) {
        if (mediaTrack.peerConnection.handleId == handleId) {
            return mediaTrack;
        }
    }
    KSMediaConnection *peerConnection = [self createPeerConnection];
    peerConnection.handleId           = handleId;
    
    KSMediaTrack *track               = [[KSMediaTrack alloc] init];
    track.peerConnection              = peerConnection;
    track.index                       = self.mediaTrackCount;
    track.dataSource                  = self;
    track.mediaState                  = KSMediaStateUnmuteAudio;
    KSUserInfo *userInfo              = [KSUserInfo userWithId:handleId];
    track.userInfo                    = userInfo;
    [self.mediaTracks addObject:track];//添加到数组
    return track;
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

#pragma mark - 关闭
- (void)close {
    for (KSMediaTrack *mediaTrack in _mediaTracks) {
        mediaTrack.delegate       = nil;
        mediaTrack.dataSource     = nil;
        [mediaTrack clearRenderer];
        [mediaTrack.peerConnection closeConnection];
        mediaTrack.peerConnection = nil;
    }
    [_mediaTracks removeAllObjects];
    
    [_mediaCapturer closeCapturer];
    _mediaCapturer = nil;

    _myMediaTrack  = nil;

    _session       = nil;
    _startingTime  = 0;

    
    if (_timekeeper) {
        [_timekeeper invalidate];
    }
    
    if (_deviceSwitch) {
        [_deviceSwitch resetSwitch];
    }
    
    if (_coolTile) {
        [_coolTile callEnded];
    }
    
    if (_audioPlayer) {
        [_audioPlayer stop];//关闭响铃03（有3处）
    }
    
    [_msgHandler leave];
}

+ (void)close {
    [[KSWebRTCManager shared] close];
}

#pragma mark - 懒加载
- (NSMutableArray *)mediaTracks {
    if (_mediaTracks == nil) {
        _mediaTracks = [NSMutableArray array];
    }
    return _mediaTracks;
}

-(KSSession *)session {
    if (_session == nil) {
        _session = [[KSSession alloc] init];
    }
    return _session;
}

-(KSTimekeeper *)timekeeper {
    if (_timekeeper == nil) {
        _timekeeper = [[KSTimekeeper alloc] init];
    }
    return _timekeeper;
}

-(KSDeviceSwitch *)deviceSwitch {
    if (_deviceSwitch == nil) {
        _deviceSwitch = [[KSDeviceSwitch alloc] init];
    }
    return _deviceSwitch;
}

-(KSCoolTile *)coolTile {
    if (_coolTile == nil) {
        CGFloat tile_width   = 99;
        CGFloat tile_height  = 176;
        CGFloat tile_padding = 10;
        CGFloat tile_x       = [UIScreen mainScreen].bounds.size.width - tile_width - tile_padding;
        CGRect rect          = CGRectMake(tile_x, 64, tile_width, tile_height);
        _coolTile            = [[KSCoolTile alloc] initWithFrame:rect];
        _coolTile.delegate   = self;
    }
    return _coolTile;
}

- (KSAudioPlayer *)audioPlayer {
    if (_audioPlayer == nil) {
        _audioPlayer = [[KSAudioPlayer alloc] init];
    }
    return _audioPlayer;
}

+ (void)updateStartingTime {
    NSDate *startDate                     = [NSDate dateWithTimeIntervalSinceNow:0];
    [KSWebRTCManager shared].startingTime = (int)[startDate timeIntervalSince1970];
}

#pragma mark - KSCoolTile
- (KSMediaTrack *)displayMediaTrack {
    if (self.callType == KSCallTypeSingleAudio) {
        return [self tileMediaTrack];
    }
    return [self screenMediaTrack];
    /*
     if (self.callState == KSCallStateMaintenanceRecording) {
     return [self screenMediaTrack];
     }
     else{
     return [self screenMediaTrack];
     }*/
}
+ (void)displayTile {
    [[KSWebRTCManager shared] displayTile];
}

- (void)displayTile {
    KSMediaTrack *mediaTrack = [self displayMediaTrack];
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
    UIViewController *targetCtrl = [UIViewController currentViewController];
    [KSChatController callWithType:self.callType callState:self.callState isCaller:NO room:self.session.room target:targetCtrl];
}

@end

