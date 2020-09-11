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
#import "KSSocketHandler.h"
static int const kLocalRTCIdentifier = 10101024;

@interface KSRTCConnect : NSObject
@property (nonatomic,assign) int          ID;
@property (nonatomic,strong) NSDictionary *jsep;
@end
@implementation KSRTCConnect
@end

@interface KSWebRTCManager()<KSMessageHandlerDelegate,KSMediaConnectionDelegate,KSMediaCapturerDelegate,KSMediaTrackDataSource,KSCoolTileDelegate>
@property (nonatomic, strong) KSMessageHandler  *msgHandler;
@property (nonatomic, strong) KSMediaCapturer   *mediaCapturer;
@property (nonatomic, strong) KSMediaConnection *peerConnection;
@property (nonatomic, strong) NSMutableArray    *mediaTracks;
@property (nonatomic, strong) KSTimekeeper      *timekeeper;
@property (nonatomic, strong) KSCoolTile        *coolTile;
@property (nonatomic, strong) KSAudioPlayer     *audioPlayer;

@end

@implementation KSWebRTCManager

+ (instancetype)shared {
    static KSWebRTCManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.testType = KSTestTypeSignalling;
        [instance initManager];
    });
    return instance;
}

- (void)initManager {
    if (_testType == KSTestTypeSignalling) {
        _msgHandler          = [[KSSocketHandler alloc] init];
    }
    else if (_testType == KSTestTypeJanus) {
        _msgHandler          = [[KSMessageHandler alloc] init];
    }
    
    _msgHandler.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate:)
                                                 name:KS_NotificationName_ApplicationWillTerminate
                                               object:nil];
}

#pragma mark - applicationWillTerminate
- (void)applicationWillTerminate:(UIApplication *)application {
    if (self.callState != KSCallStateMaintenanceNormal) {
        [KSWebRTCManager leave];
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
    [self createLocalConnection];
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
- (void)createLocalConnection {
    KSMediaConnection *peerConnection = [self createPeerConnection];
    peerConnection.handleId           = kLocalRTCIdentifier;
    _peerConnection                   = peerConnection;
    
    KSMediaTrack *localMediaTrack     = [[KSMediaTrack alloc] init];
    localMediaTrack.peerConnection    = peerConnection;
    localMediaTrack.videoTrack        = _mediaCapturer.videoTrack;
    localMediaTrack.audioTrack        = _mediaCapturer.audioTrack;
    localMediaTrack.dataSource        = self;
    localMediaTrack.isLocal           = YES;
    localMediaTrack.index             = 0;
    localMediaTrack.sessionId         = kLocalRTCIdentifier;//[self randomNumber];
    localMediaTrack.userInfo          = [KSUserInfo myself];
    _localMediaTrack                  = localMediaTrack;
    [self.mediaTracks insertObject:localMediaTrack atIndex:0];
}

- (KSMediaConnection *)createPeerConnection {
    KSMediaConnection *peerConnection = [[KSMediaConnection alloc] initWithSetting:_mediaSetting.connectionSetting];
    peerConnection.delegate           = self;
    [peerConnection createPeerConnectionWithMediaCapturer:_mediaCapturer];
    return peerConnection;
}

#pragma mark - KSMessageHandlerDelegate 调试
- (KSMediaConnection *)remotePeerConnectionOfMessageHandler:(KSMessageHandler *)messageHandler handleId:(NSNumber *)handleId sdp:(NSString *)sdp {
    return [self remoteMediaTrackWithSdp:sdp userId:[handleId longLongValue]].peerConnection;
}
- (KSMediaConnection *)localPeerConnectionOfMessageHandler:(KSMessageHandler *)messageHandler {
    return self.peerConnection;
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

- (void)messageHandler:(KSMessageHandler *)messageHandler didReceiveOffer:(NSDictionary *)offer {
    if (offer) {
        KSMediaTrack *mediaTrack = [self remoteMediaTrackOfUserId:[offer[@"user_id"] intValue]];
        [self createAnswerOfJsep:offer];
    }
}

- (void)messageHandler:(KSMessageHandler *)messageHandler didReceiveAnswer:(NSDictionary *)answer {
    if (answer) {
        KSMediaTrack *mediaTrack = [self remoteMediaTrackOfUserId:[answer[@"user_id"] intValue]];
        [self setRemoteOfJsep:answer];
    }
}

- (void)messageHandler:(KSMessageHandler *)messageHandler addIceCandidate:(NSDictionary *)candidate {
    if (candidate) {
        [self.peerConnection addIceCandidate:candidate];
    }
}

- (void)messageHandler:(KSMessageHandler *)messageHandler requestError:(KSRequestError *)error {
    if ([self.delegate respondsToSelector:@selector(webRTCManager:requestError:)]) {
        [self.delegate webRTCManager:self requestError:error];
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
    }
    [_msgHandler trickleCandidate:body];
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
        //case RTCIceConnectionStateFailed:
        {
            [self.msgHandler sendMessage:jseps type:@"peerdesc_req"];
            __weak typeof(self) weakSelf = self;
            [self.timekeeper countdownOfSecond:5 callback:^(BOOL isEnd) {
                //未及时响应则挂断
                [weakSelf closeCall];
                //通话中断回调
                if ([weakSelf.delegate respondsToSelector:@selector(webRTCManagerDisconnected:)]) {
                    [weakSelf.delegate webRTCManagerDisconnected:self];
                }
            }];
        }
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

- (int)peerId {
    return self.session.peerId;
}

-(BOOL)isCalled {
    return self.session.isCalled;
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

+ (void)stopCapture {
    [self closeVideo];
    
    [[KSWebRTCManager shared].mediaCapturer muteVideo];
    //[[KSWebRTCManager shared].mediaCapture stopCapture];
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

+ (void)unmuteAudio {
     [self openVoice];
    
    [[KSWebRTCManager shared].mediaCapturer unmuteAudio];
}

+ (void)switchToSingleVideo {
    [[KSWebRTCManager shared] switchToSingleVideo];
    
    //[self switchToVideoCall];
}

//在此之前需更新callType
- (void)switchToSingleVideo {
    if (_callType == KSCallTypeSingleVideo) {
        if (_mediaCapturer.videoTrack == nil) {
            [_peerConnection addVideoTrack];
            [_mediaCapturer startCapture];
            _localMediaTrack.videoTrack = _mediaCapturer.videoTrack;
        }
        else{
            [_mediaCapturer unmuteVideo];
        }
    }
}

+ (void)switchToSingleAudio {
    [[KSWebRTCManager shared] switchToSingleAudio];
    
    //[self switchToVoiceCall];
}

//在此之前需更新callType
- (void)switchToSingleAudio {
    if (_callType == KSCallTypeSingleAudio) {
        [_mediaCapturer muteVideo];
    }
}

#pragma mark - Socket测试
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
    //[[KSWebRTCManager shared].msgHandler requestHangup];
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
    return [KSWebRTCManager shared].mediaTracks.count;
}

+ (void)removeMediaTrackAtIndex:(int)index {
    if (index >= (int)[KSWebRTCManager shared].mediaTracks.count) {
        return;
    }
    KSMediaTrack *videoTrack = [KSWebRTCManager shared].mediaTracks[index];
    [[KSWebRTCManager shared].mediaTracks removeObjectAtIndex:index];
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

#pragma mark - 关闭
- (void)close {
    for (KSMediaTrack *mediaTrack in _mediaTracks) {
        mediaTrack.delegate = nil;
        mediaTrack.dataSource = nil;
        [mediaTrack clearRenderer];
    }
    [_mediaTracks removeAllObjects];
    
    [self.mediaCapturer closeCapturer];

    [self.peerConnection closeConnection];
    self.peerConnection = nil;

    _session            = nil;

    _startingTime       = 0;
    
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
    
    [_msgHandler close];
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

#pragma mark - 消息读取
+ (void)didReceivedMessage:(NSDictionary *)message {
    [[KSWebRTCManager shared] didReceivedMessage:message];
}

- (void)didReceivedMessage:(NSDictionary *)message {
    NSLog(@"|======Start %@ ======|\n %@ \n|======End======|",[NSThread currentThread],message);
    KSAckMessage *ack = [KSAckMessage ackWithMessage:message];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf handleThreadOfAck:ack];
    });
}

- (void)handleThreadOfAck:(KSAckMessage *)ack {
    switch (ack.ackType) {
        case KSAckTypeCall:
        {
            [self receivedCall:(KSAckCall *)ack];
        }
            break;
        case KSAckTypeJoined:
            [self receivedJoined:(KSAckJoined *)ack];
            break;
        case KSAckTypeAnswer:
            //[self receivedAnswer:(KSAckAnswer *)ack];
            break;
        case KSAckTypeCurrentMessage:
            [self receivedCurrentMessage:(KSAckCurrentMessage *)ack];
            break;
        case KSAckTypeStart:
            [self receivedStart:(KSAckStart *)ack];
            break;
        case KSAckTypeRing:
            [self receivedRing:(KSAckRing *)ack];
            break;
        case KSAckTypeLeft:
            [self receivedLeft:(KSAckLeft *)ack];
            break;
        case KSAckTypeDecline:
            [self receivedDecline:(KSAckDecline *)ack];
            break;
        default:
            break;
    }
}

- (void)receivedCall:(KSAckCall *)call {
    if (_callState != KSCallStateMaintenanceNormal) {//正在通话中
        if (call.user_id == self.peerId) {//之前双方正在通话，中途故障
            [self resetSession];
        }
        else{//与其他用户通话中
            [KSWebRTCManager lineBusy];
        }
        return;
    }
    
    [self.audioPlayer play];//播放响铃02（有两处）
    [KSWebRTCManager shared].callState = KSCallStateMaintenanceRinger;//02:被叫方收到Call准备响铃

    self.callType                      = call.callType;
    self.msgHandler.peerId             = [NSString stringWithFormat:@"%d",call.from];

    //记录
    self.session.peerId                = call.from;//对方ID更新02（有两处）
    self.session.isCalled              = YES;//设置为被叫
    self.session.session_id            = call.session_id;
    self.session.room                  = call.room;
    
    [[KSWebRTCManager shared] remoteMediaTrackOfUserId:self.peerId];//创建对方媒体对象02（有两处）
    
    [self enterChat];
}

- (void)receivedJoined:(KSAckJoined *)joined {
    if ((joined.isMe == NO) && joined.payload && [joined.payload[@"type"] isEqualToString:@"offer"]) {
        [self createAnswerOfJoined:joined];
        
        [self.timekeeper invalidate];//取消倒计时
        [KSWebRTCManager updateStartingTime];//更新倒计时开始时间(点击接听和收到接听两处更新)
        self.session.room = joined.room;
        //一对一语音倒计时
        [KSWebRTCManager start];
        if ([self.delegate respondsToSelector:@selector(webRTCManager:ackJoined:)]) {
            [self.delegate webRTCManager:self ackJoined:joined];
        }
        [[KSWebRTCManager shared].audioPlayer stop];//关闭响铃02（有3处）
    }
}

/*
- (void)receivedAnswer:(KSAckAnswer *)answer {
    if (answer == nil) {
        return;
    }
    [self.timekeeper invalidate];//取消倒计时
    [KSWebRTCManager updateStartingTime];//更新倒计时开始时间(点击接听和收到接听两处更新)
    
    self.session.room = answer.room;
    self.callType     = answer.call_type;
    if ([self.delegate respondsToSelector:@selector(webRTCManager:ackAnswer:)]) {
        [self.delegate webRTCManager:self ackAnswer:answer];
    }
}
*/
+ (void)updateStartingTime {
    NSDate *startDate                     = [NSDate dateWithTimeIntervalSinceNow:0];
    [KSWebRTCManager shared].startingTime = (int)[startDate timeIntervalSince1970];
}

#pragma mark - 通用消息处理
- (void)receivedCurrentMessage:(KSAckCurrentMessage *)message {
    switch (message.messageType) {
        case KSCurrentMessageTypeOffer://弃用
            //[self createAnswerOfJsep:message.jsep];
            break;
        case KSCurrentMessageTypeAnswer:
            [self setRemoteOfMessage:message];
            //[self setRemoteJsep:message.jsep];
            break;
        case KSCurrentMessageTypeCandidate:
        {
            [self.peerConnection addIceCandidate:message.jsep];
            
        }
            break;
        case KSCurrentMessageTypePeerdescReq:
        {
            KSMediaConnection *mc = self.peerConnection;
            [mc setRemoteDescriptionWithJsep:message.jsep];
            //消息应答
            [self peerdescAck];
            
        }
            break;
        case KSCurrentMessageTypePeerdescAck:
        {
            [_timekeeper invalidate];
        }
            break;
        case KSCurrentMessageTypeSwitch:
        {
            KSMediaTrack *mediaTrack = [self mediaTrackOfUserId:message.user_id];
            if (mediaTrack) {
                mediaTrack.mediaState = message.switchType;
            }
            if ([self.delegate respondsToSelector:@selector(webRTCManager:mediaState:userInfo:)]) {
                [self.delegate webRTCManager:self mediaState:message.switchType userInfo:[self getUserinfoWithMessage:message]];
            }
        }
            break;
        case KSCurrentMessageTypeChangeMedia:
        {
            KSMediaTrack *mediaTrack = [self mediaTrackOfUserId:message.user_id];
            if (mediaTrack) {
                mediaTrack.mediaState = message.switchType;
            }
            if (self.callType == KSCallTypeSingleVideo && message.mediaType == KSChangeMediaTypeVoice) {
                //切换到单人音频
                self.callType = KSCallTypeSingleAudio;
            }
            if (self.callType == KSCallTypeSingleAudio && message.mediaType == KSChangeMediaTypeVideo) {
                //切换到单人视频
                self.callType = KSCallTypeSingleVideo;
            }
            if ([self.delegate respondsToSelector:@selector(webRTCManager:changeMediaType:userInfo:)]) {
                [self.delegate webRTCManager:self changeMediaType:message.mediaType userInfo:[self getUserinfoWithMessage:message]];
            }
        }
            break;
        case KSCurrentMessageTypeLineBusy:
        {
            if ([self.delegate respondsToSelector:@selector(webRTCManagerLineBusy:userInfo:)]) {
                [self.delegate webRTCManagerLineBusy:self userInfo:[self getUserinfoWithMessage:message]];
            }
        }
            break;
        default:
            break;
    }
}

- (KSUserInfo *)getUserinfoWithMessage:(KSAckCurrentMessage *)message {
    KSUserInfo *info = [[KSUserInfo alloc] init];
    info.name        = message.user_name;
    info.ID          = message.user_id;
    return info;
}

- (void)receivedLeft:(KSAckLeft *)left {
    //对方挂断
    if ([KSWebRTCManager shared].callState == KSCallStateMaintenanceNormal) {
        NSLog(@"|============| 对方挂断 |============|");
        return;
    }
    
    [KSWebRTCManager shared].callState = KSCallStateMaintenanceNormal;
    
    KSMediaTrack *mediaTrack = [self mediaTrackOfUserId:left.user_id];
    if (mediaTrack == nil) {
        NSLog(@"|============| 未接听挂断 |============|");
        [self callLeft:left mediaTrack:mediaTrack];
        [self endDetection];
        return;
    }
    [self removeMediaTrack:mediaTrack];
    
    [self callLeft:left mediaTrack:mediaTrack];
    [self endDetection];
}

- (void)callLeft:(KSAckLeft *)left mediaTrack:(KSMediaTrack *)mediaTrack {
    if ([self.delegate respondsToSelector:@selector(webRTCManager:ackLeft:mediaTrack:)]) {
        [self.delegate webRTCManager:self ackLeft:left mediaTrack:mediaTrack];
    }
}
- (void)endDetection {
    if (self.mediaTracks.count == 1) {//只剩下自己
        //离开与关闭
        [self closeCall];
        
        if ([self.delegate respondsToSelector:@selector(webRTCManagerHandlerEnd:)]) {
            [self.delegate webRTCManagerHandlerEnd:self];
        }
    }
}

- (void)receivedDecline:(KSAckDecline *)decline {
}

- (void)receivedStart:(KSAckStart *)start {
    if ([self.delegate respondsToSelector:@selector(webRTCManager:ackStart:)]) {
        [self.delegate webRTCManager:self ackStart:start];
    }
}

- (void)receivedRing:(KSAckRing *)ring {
    [KSWebRTCManager shared].callState = KSCallStateMaintenanceRinged;//03:主叫方收到响铃（此时等待被叫方接听）
}

#pragma mark - 消息发送
//1、call
+ (void)callToPeerId:(int)peerId {
    [KSWebRTCManager shared].callState        = KSCallStateMaintenanceCaller;//01:主叫方发起Call
    [KSWebRTCManager shared].session.peerId   = peerId;//对方ID更新01（有两处）
    [KSWebRTCManager shared].session.isCalled = NO;
    [[KSWebRTCManager shared].msgHandler callToPeerId:peerId type:[KSWebRTCManager shared].callType];
    [[KSWebRTCManager shared] callCountdown];
    [[KSWebRTCManager shared] remoteMediaTrackOfUserId:peerId];//创建对方媒体对象01（有两处）
    [[KSWebRTCManager shared].audioPlayer play];//播放响铃01（有两处）
}

- (void)callCountdown {
    __weak typeof(self) weakSelf = self;
    int second = 600;
    [self.timekeeper countdownOfSecond:second callback:^(BOOL isEnd) {
        //挂断
        [weakSelf closeCall];

        if ([weakSelf.delegate respondsToSelector:@selector(webRTCManagerCallTimeout:)]) {
            [weakSelf.delegate webRTCManagerCallTimeout:self];
        }
    }];
}

- (void)closeCall {
    [KSWebRTCManager leave];
    [KSWebRTCManager close];
}

//2、响铃
+ (void)ringed {
    [KSWebRTCManager shared].callState = KSCallStateMaintenanceRinged;//03:被叫方发送响铃
    [[KSWebRTCManager shared].msgHandler ringed];
    //[self sendOffer];
}

//3、
+ (void)sendOffer {
    [[KSWebRTCManager shared] sendOffer];
}

- (void)sendOffer {
    [KSWebRTCManager shared].callState = KSCallStateMaintenanceAnswoer;//04:被叫方按下接听
    KSMediaConnection *mc        = self.peerConnection;
    __weak typeof(self) weakSelf = self;
    [mc createOfferWithCompletionHandler:^(RTCSessionDescription *sdp, NSError *error) {
        NSString *type = [RTCSessionDescription stringForType:sdp.type];
        NSMutableDictionary *jsep =[NSMutableDictionary dictionary];
        jsep[@"type"]      = type;
        jsep[@"sdp"]       = [sdp sdp];
        jsep[@"call_type"] = @(weakSelf.callType);
        jsep[@"user_id"]   = @([KSUserInfo myID]);
        [weakSelf.msgHandler sendPayload:jsep];
    }];
}

//4、
- (void)createAnswerOfJoined:(KSAckJoined *)joined {
    //NSLog(@"|============| 此处不会调用 |============|");
    //return;
    //创建媒体
    KSMediaTrack *mediaTrack = [self remoteMediaTrackWithSdp:joined.payload[@"sdp"] userId:joined.user_id];
    //mediaTrack.userInfo.ID   = joined.user_id;
    //mediaTrack.userInfo.name = joined.user_name;
    [self createAnswerOfJsep:joined.payload];
}

// 观察者收到远端offer后，发送anwser
- (void)createAnswerOfJsep:(NSDictionary *)jsep {
    self.callType                      = [jsep[@"call_type"] intValue];
    [KSWebRTCManager shared].callState = KSCallStateMaintenanceAnswoer;//主叫方收到接听
    KSMediaConnection *mc              = self.peerConnection;
    [mc setRemoteDescriptionWithJsep:jsep];
    
    __weak typeof(self) weakSelf = self;
    [mc createAnswerWithCompletionHandler:^(RTCSessionDescription *sdp, NSError *error) {
        NSString *type = [RTCSessionDescription stringForType:sdp.type];
        NSMutableDictionary *jseps =[NSMutableDictionary dictionary];
        jseps[@"type"]      = type;
        jseps[@"sdp"]       = [sdp sdp];
        jseps[@"call_type"] = @(weakSelf.callType);
        jseps[@"user_id"]   = @([KSUserInfo myID]);
        [weakSelf.msgHandler sendPayload:jseps];
    }];
}

- (void)setRemoteOfMessage:(KSAckCurrentMessage *)message {
    //创建媒体
    KSMediaTrack *mediaTrack = [self remoteMediaTrackWithSdp:message.jsep[@"sdp"] userId:[message.payload[@"user_id"] intValue]];
    //mediaTrack.userInfo.name = message.payload[@"user_name"];
    [self setRemoteOfJsep:message.jsep];
}

// 发布者收到远端媒体信息后的回调 answer
- (void)setRemoteOfJsep:(NSDictionary *)jsep {
    if (jsep[@"flag"]) {
        //RTC错误时回调
        [self receivedStart:nil];
    }
    //self.callType         = [jsep[@"call_type"] intValue];
    KSMediaConnection *mc = self.peerConnection;
    [mc setRemoteDescriptionWithJsep:jsep];
}

//5、
+ (void)answoer {
    [[KSWebRTCManager shared].msgHandler startFlag];
    return;
    
    [KSWebRTCManager shared].callState = KSCallStateMaintenanceAnswoer;//被叫方按下接听
    [self sendOffer];
    //[[KSWebRTCManager shared].msgHandler answoerOfCallType:[KSWebRTCManager shared].callType];
    [self start];
    [[KSWebRTCManager shared].audioPlayer stop];//关闭响铃01（有3处）
}

//6、
+ (void)start {
    NSLog(@"|============| 发送开始消息 |============|");
    //语音倒计时
    [[KSWebRTCManager shared].msgHandler start];
}
//7、
+ (void)leave {
    [KSWebRTCManager shared].callState = KSCallStateMaintenanceNormal;
    [[KSWebRTCManager shared].msgHandler leave];
}

//8、切换到视频通话
+ (void)switchToVideoCall {
    NSMutableDictionary *media = [NSMutableDictionary dictionary];
    media[@"media_type"]       = @(KSChangeMediaTypeVideo);
    [[KSWebRTCManager shared].msgHandler sendMessage:media type:@"change_media"];
}

//9、切换到语音通话
+ (void)switchToVoiceCall {
    NSMutableDictionary *media = [NSMutableDictionary dictionary];
    media[@"media_type"]       = @(KSChangeMediaTypeVoice);
    [[KSWebRTCManager shared].msgHandler sendMessage:media type:@"change_media"];
}

//开启语音
+ (void)openVoice {
    NSMutableDictionary *media = [NSMutableDictionary dictionary];
    media[@"switch_type"]      = @(KSMediaStateUnmuteAudio);
    [[KSWebRTCManager shared].msgHandler sendMessage:media type:@"switch"];
}

//关闭语音
+ (void)closeVoice {
    NSMutableDictionary *media = [NSMutableDictionary dictionary];
    media[@"switch_type"]      = @(KSMediaStateMuteAudio);
    [[KSWebRTCManager shared].msgHandler sendMessage:media type:@"switch"];
}

//开启视频
+ (void)openVideo {
    NSMutableDictionary *media = [NSMutableDictionary dictionary];
    media[@"switch_type"]      = @(KSMediaStateUnmuteVideo);
    [[KSWebRTCManager shared].msgHandler sendMessage:media type:@"switch"];
}

//关闭视频
+ (void)closeVideo {
    NSMutableDictionary *media = [NSMutableDictionary dictionary];
    media[@"switch_type"]      = @(KSMediaStateMuteVideo);
    [[KSWebRTCManager shared].msgHandler sendMessage:media type:@"switch"];
}

//占线
+ (void)lineBusy {
    NSMutableDictionary *media = [NSMutableDictionary dictionary];
    [[KSWebRTCManager shared].msgHandler sendMessage:media type:@"line_busy"];
}


- (void)peerdescAck {
    if (self.callState != KSCallStateMaintenanceRecording) {
        return;
    }
    NSMutableDictionary *media = [NSMutableDictionary dictionary];
    [[KSWebRTCManager shared].msgHandler sendMessage:media type:@"peerdesc_ack"];
}

//重置会话
- (void)resetSession {
    if (self.callType == KSCallTypeSingleAudio || self.callType == KSCallTypeSingleVideo) {
        // 逆序遍历
        for (KSMediaTrack *mediaTrack in [self.mediaTracks reverseObjectEnumerator]) {
            if (mediaTrack.isLocal == NO) {
                [mediaTrack clearRenderer];
                [self.mediaTracks removeObject:mediaTrack];
            }
        }
        [KSWebRTCManager answoer];
    }
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
    [KSChatController callWithType:self.callType callState:self.callState isCaller:NO peerId:self.peerId target:currentCtrl];
}

@end

