//
//  KSMediaConnection.m
//  KSWebRTC
//
//  Created by saeipi on 2020/7/11.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSMediaConnection.h"
#import "RTCSessionDescription+Category.h"

@interface KSMediaConnection ()<RTCPeerConnectionDelegate>
@property (nonatomic, weak)KSMediaCapturer *capturer;
@end

@implementation KSMediaConnection

- (instancetype)initWithSetting:(KSConnectionSetting *)setting {
    if (self = [super init]) {
        _setting  = setting;
        _callType = setting.callType;
    }
    return self;
}

/*
 要想从远端获取数据，我们就必须创建 PeerConnection 对象。该对象的用处就是与远端建立联接，并最终为双方通讯提供网络通道。
 
 当 PeerConnection 对象创建好后，我们应该将本地的音视频轨添加进去，这样 WebRTC 才能帮我们生成包含相应媒体信息的 SDP，以便于后面做媒体能力协商使用。
 //---------- !!! ----------
 以 PeerConnection 对象的创建为例，该在什么时候创建 PeerConnection 对象呢？最好的时机当然是在用户加入房间之后了 。
 
 客户端收到 joined 消息后，就要创建 RTCPeerConnection 了，也就是要建立一条与远端通话的音视频数据传输通道。
 
 对于 iOS 的 RTCPeerConnection 对象有三个参数：
    第一个，是 RTCConfiguration 类型的对象，该对象中最重要的一个字段是 iceservers。它里边存放了 stun/turn 服务器地址。其主要作用是用于NAT穿越。对于 NAT 穿越的知识大家可以自行学习。
    第二个参数，是 RTCMediaConstraints 类型对象，也就是对 RTCPeerConnection 的限制。如，是否接收视频数据？是否接收音频数据？如果要与浏览器互通还要开启 DtlsSrtpKeyAgreement 选项。
    第三个参数，是委拖类型。相当于给 RTCPeerConnection 设置一个观察者。这样RTCPeerConnection 可以将一个状态/信息通过它通知给观察者。但它并不属于观察者模式，这一点大家一定要清楚。
    RTCPeerConnection 对象创建好后，接下来我们介绍的是整个实时通话过程中，最重要的一部分知识，那就是 媒体协商。
 */
- (RTCPeerConnection *)createPeerConnectionWithMediaCapturer:(KSMediaCapturer *)capturer {
    // 媒体约束
    RTCMediaConstraints *constraints  = [self defaultMediaConstraint];
    // 创建配置
    RTCConfiguration *config          = [[RTCConfiguration alloc] init];
    // ICE 中继服务器地址
    NSArray *iceServers               = @[[self defaultIceServer]];
    config.iceServers                 = iceServers;
    // 创建一个peerconnection
    RTCPeerConnection *peerConnection = [capturer.factory peerConnectionWithConfiguration:config constraints:constraints delegate:self];

    NSArray *mediaStreamLabels        = @[ @"ARDAMS" ];
    // 添加视频轨
    [peerConnection addTrack:capturer.videoTrack streamIds:mediaStreamLabels];
    // 添加音频轨
    [peerConnection addTrack:capturer.audioTrack streamIds:mediaStreamLabels];
    _peerConnection                   = peerConnection;
    _capturer                         = capturer;
    return peerConnection;
}

- (void)addRenderer:(id<RTCVideoRenderer>)renderer {
    [self.videoTrack addRenderer:renderer];
}

-(AVCaptureSession *)captureSession {
    return _capturer.capturer.captureSession;
}

// 设置远端的媒体描述
- (void)setRemoteDescriptionWithJsep:(NSDictionary *)jsep {
    RTCSessionDescription *answerDescription = [RTCSessionDescription ks_descriptionFromJSONDictionary:jsep];
    [_peerConnection setRemoteDescription:answerDescription
                        completionHandler:^(NSError *_Nullable error){
        if(!error){
            NSLog(@"Success to set remote Answer SDP");
        }else{
            NSLog(@"Failure to set remote Answer SDP, err=%@", error);
        }
    }];
}

/*
 在WebRTC的每一端，当创建好RTCPeerConnection对象，且调用了setLocalDescription方法后，就开始收集ICE候选者了。
 
 在WebRTC中有三种类型的候选者，它们分别是：
 主机候选者
 反射候选者
 中继候选者
 
 主机候选者，表示的是本地局域网内的 IP 地址及端口。它是三个候选者中优先级最高的，也就是说在 WebRTC 底层，首先会偿试本地局域网内建立连接。
 反射候选者，表示的是获取 NAT 内主机的外网IP地址和端口。其优先级低于 主机候选者。也就是说当WebRTC偿试本地连接不通时，会偿试通过反射候选者获得的 IP地址和端口进行连接。
 中继候选者，表示的是中继服务器的IP地址与端口，即通过服务器中转媒体数据。当WebRTC客户端通信双方无法穿越 P2P NAT 时，为了保证双方可以正常通讯，此时只能通过服务器中转来保证服务质量了。
 
 所以 中继候选者的优先级是最低的，只有上述两种候选者都无法进行连接时，才会使用它。
 */
// 创建answer
- (void)createAnswerWithCompletionHandler:(void (^)(RTCSessionDescription *sdp, NSError *error))completionHandler {
    RTCMediaConstraints *constraints = [self defaultMediaConstraint];
    __weak KSMediaConnection *weakSelf = self;
    [_peerConnection answerForConstraints:constraints
                        completionHandler:^(RTCSessionDescription *_Nullable sdp, NSError *_Nullable error) {
        if (error) {
            NSLog(@"Failure to create local answer sdp!");
        }
        else{
            NSLog(@"Success to create local answer sdp!");
        }
        [weakSelf.peerConnection setLocalDescription:sdp
                                   completionHandler:^(NSError *_Nullable error) {
            completionHandler(sdp, error);
        }];
        
    }];
}

// 创建offer 进行媒体协商
- (void)createOfferWithCompletionHandler:(void (^)(RTCSessionDescription *sdp, NSError *error))completionHandler {
    RTCMediaConstraints *constraints = [self defaultMediaConstraint];
    __weak KSMediaConnection *weakSelf = self;
    [_peerConnection offerForConstraints:constraints
                       completionHandler:^(RTCSessionDescription *_Nullable sdp, NSError *_Nullable error) {
        if(error){
            NSLog(@"Failed to create offer SDP, err=%@", error);
        }
        [weakSelf.peerConnection setLocalDescription:sdp
                                   completionHandler:^(NSError *_Nullable error) {
            completionHandler(sdp, error);
        }];
    }];
}

#pragma mark - Set
-(void)setMediaState:(KSMediaState)mediaState {
    if ([self.updateDelegate respondsToSelector:@selector(mediaConnection:didChangeMediaState:)]) {
        [self.updateDelegate mediaConnection:self didChangeMediaState:mediaState];
    }
    _mediaState = mediaState;
}

#pragma mark - Audio mute/unmute
- (void)muteAudio {
    NSLog(@"audio muted");
    _capturer.audioTrack.isEnabled = NO;
}

- (void)unmuteAudio {
    NSLog(@"audio unmuted");
    _capturer.audioTrack.isEnabled = YES;
}

#pragma mark - Video mute/unmute
- (void)muteVideo {
    _capturer.videoTrack.isEnabled = NO;
    NSLog(@"video muted");

}
- (void)unmuteVideo {
    NSLog(@"video unmuted");
    _capturer.videoTrack.isEnabled = YES;
}

#pragma mark - enable/disable speaker
/*
- (void)enableSpeaker {
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
}

- (void)disableSpeaker {
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
}
*/
- (void)speakerOff {
    [self setSpeakerEnabled:NO];
}

- (void)speakerOn {
    [self setSpeakerEnabled:YES];
}

- (void)setSpeakerEnabled:(BOOL)enabled {
    [_capturer setSpeakerEnabled:enabled];
    /*
    if (enabled) {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        //此方法设置之后，如果此时插入耳机在拔掉。播放的声音会从听筒输出，而不是回到扬声器
        //[[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        //此方法设置之后，始终输出到扬声器，而不是其他接收器 如果此时插入耳机在拔掉。播放的声音会从扬声器输出
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    }else{
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers error:nil];
    }*/
}
- (void)switchTalkMode {
    [_capturer switchTalkMode];
}
- (void)switchCamera {
    [_capturer switchCamera];
}

- (void)startCapture {
    [_capturer startCapture];
}

- (void)stopCapture {
    [_capturer stopCapture];
}

- (void)closeConnection {
    if (_isLocal) {
        [_capturer closeCapturer];
        _capturer          = nil;
    }
    
    RTCMediaStream *mediaStream = [_peerConnection.localStreams firstObject];
    if (mediaStream) {
        [_peerConnection removeStream:mediaStream];
    }
    [_peerConnection close];
    _peerConnection       = nil;
    
    [self clearRenderer];

    _videoTrack   = nil;
    self.delegate = nil;
}

- (void)clearRenderer {
    if (_videoView) {
        if (_videoTrack) {
            [_videoTrack removeRenderer:_videoView];
        }
        [_videoView renderFrame:nil];
    }
    _videoView    = nil;
}

// PeerConnection 媒体约束
- (RTCMediaConstraints *)defaultMediaConstraint {
    // DTLS
    NSDictionary *mandatoryContraints = [self mandatoryConstraints];
    NSDictionary *option = @{ @"DtlsSrtpKeyAgreement" : @"true" };
    RTCMediaConstraints *constrants = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryContraints optionalConstraints:option];
    return constrants;
}

- (NSDictionary *)mandatoryConstraints {
    return @{
        kRTCMediaConstraintsOfferToReceiveAudio:kRTCMediaConstraintsValueTrue,
        kRTCMediaConstraintsOfferToReceiveVideo:kRTCMediaConstraintsValueTrue
    };
    /*
     return @{
     @"OfferToReceiveAudio" : @"true",
     @"OfferToReceiveVideo" : @"true"
     };*/
}

// stun 、 turn服务地址
- (RTCIceServer *)defaultIceServer {
    //NSArray *array = [NSArray arrayWithObject:@"turn:turn.al.mancangyun:3478"];
    //return [[RTCIceServer alloc] initWithURLStrings:array username:@"root" credential:@"mypasswd"];
    return [[RTCIceServer alloc] initWithURLStrings:_setting.iceServer.servers
                                           username:_setting.iceServer.username
                                         credential:_setting.iceServer.password];
}

#pragma mark - RTCPeerConnectionDelegate
- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didAddStream:(nonnull RTCMediaStream *)stream { 
    //[self.delegate mediaConnection:self peerConnection:peerConnection didAddStream:stream];
}

//该方法用于收集可用的 Candidate。
- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didGenerateIceCandidate:(nonnull RTCIceCandidate *)candidate {
    NSLog(@"已找到新的候选者。");
    if ([self.delegate respondsToSelector:@selector(mediaConnection:peerConnection:didGenerateIceCandidate:)]) {
        [self.delegate mediaConnection:self peerConnection:peerConnection didGenerateIceCandidate:candidate];
    }
}

//当 ICE 连接状态发生变化时会触发该方法
- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didChangeIceConnectionState:(RTCIceConnectionState)newState {
    if ([self.delegate respondsToSelector:@selector(mediaConnection:didChangeIceConnectionState:)]) {
        [self.delegate mediaConnection:self didChangeIceConnectionState:newState];
    }
    
    NSLog(@"每当IceConnectionState更改时调用。");
    switch (newState) {
        case RTCIceConnectionStateNew:
            NSLog(@"|------| RTCIceConnectionStateNew : %d |------|",(int)newState);
            break;
        case RTCIceConnectionStateChecking:
            NSLog(@"|------| RTCIceConnectionStateChecking : %d |------|",(int)newState);
            break;
        case RTCIceConnectionStateConnected:
            NSLog(@"|------| RTCIceConnectionStateConnected : %d |------|",(int)newState);
            break;
        case RTCIceConnectionStateCompleted:
            NSLog(@"|------| RTCIceConnectionStateCompleted : %d |------|",(int)newState);
            break;
        case RTCIceConnectionStateFailed:
            NSLog(@"|------| RTCIceConnectionStateFailed : %d |------|",(int)newState);
            break;
        case RTCIceConnectionStateDisconnected:
            NSLog(@"|------| RTCIceConnectionStateDisconnected : %d |------|",(int)newState);
            break;
        case RTCIceConnectionStateClosed:
            NSLog(@"|------| RTCIceConnectionStateClosed : %d |------|",(int)newState);
            break;
        case RTCIceConnectionStateCount:
            NSLog(@"|------| RTCIceConnectionStateCount : %d |------|",(int)newState);
            break;
        default:
            break;
    }
}

/** Called when a receiver and its track are created. */
//该方法在侦听到远端 track 时会触发。
//当函数被调用后，我们可以通过 rtpReceiver 参数获取到 track。这个track有可能是音频trak，也有可能是视频trak。所以，我们首先要对 track 做个判断，看其是视频还是音频。
- (void)peerConnection:(RTCPeerConnection *)peerConnection didAddReceiver:(RTCRtpReceiver *)rtpReceiver streams:(NSArray<RTCMediaStream *> *)mediaStreams {
    NSLog(@"在创建接收者及其音轨时调用。");
    if ([self.delegate respondsToSelector:@selector(mediaConnection:peerConnection:didAddReceiver:streams:)]) {
        [self.delegate mediaConnection:self peerConnection:peerConnection didAddReceiver:rtpReceiver streams:mediaStreams];
    }
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didChangeIceGatheringState:(RTCIceGatheringState)newState {
    NSLog(@"每当IceGatheringState更改时调用。");
    switch (newState) {
        case RTCIceGatheringStateNew:
            NSLog(@"|------| RTCIceGatheringStateNew : %d |------|",(int)newState);
            break;
        case RTCIceGatheringStateGathering:
            NSLog(@"|------| RTCIceGatheringStateGathering : %d |------|",(int)newState);
            break;
        case RTCIceGatheringStateComplete:
            NSLog(@"|------| RTCIceGatheringStateComplete : %d |------|",(int)newState);
            break;
        default:
            break;
    }
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didChangeSignalingState:(RTCSignalingState)stateChanged {
    NSLog(@"在SignalingState更改时调用。");
    switch (stateChanged) {
        case RTCSignalingStateStable:
            NSLog(@"|------| RTCSignalingStateStable : %d |------|",(int)stateChanged);
            break;
        case  RTCSignalingStateHaveLocalOffer:
            NSLog(@"|------| RTCSignalingStateHaveLocalOffer : %d |------|",(int)stateChanged);
            break;
        case RTCSignalingStateHaveLocalPrAnswer:
            NSLog(@"|------| RTCSignalingStateHaveLocalPrAnswer : %d |------|",(int)stateChanged);
            break;
        case RTCSignalingStateHaveRemoteOffer:
            NSLog(@"|------| RTCSignalingStateHaveRemoteOffer : %d |------|",(int)stateChanged);
            break;
        case RTCSignalingStateHaveRemotePrAnswer:
            NSLog(@"|------| RTCSignalingStateHaveRemotePrAnswer : %d |------|",(int)stateChanged);
            break;
        case RTCSignalingStateClosed:
            NSLog(@"|------| RTCSignalingStateClosed : %d |------|",(int)stateChanged);
            break;
        default:
            break;
    }
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didOpenDataChannel:(nonnull RTCDataChannel *)dataChannel {
    NSLog(@"新数据通道已打开。");
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didRemoveIceCandidates:(nonnull NSArray<RTCIceCandidate *> *)candidates {
    NSLog(@"在删除一组本地Ice候选对象时调用。");
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didRemoveStream:(nonnull RTCMediaStream *)stream {
    NSLog(@"在远程对等方关闭流时调用。指定RTCSdpSemanticsUnifiedPlan时不调用此方法。");
}

- (void)peerConnectionShouldNegotiate:(nonnull RTCPeerConnection *)peerConnection {
    NSLog(@"在需要协商时调用，例如ICE已重新启动");
}

@end
