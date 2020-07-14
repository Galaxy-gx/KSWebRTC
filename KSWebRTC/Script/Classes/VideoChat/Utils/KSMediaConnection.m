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

@end

@implementation KSMediaConnection

- (RTCPeerConnection *)createPeerConnection:(RTCPeerConnectionFactory *)factory
                                 audioTrack:(RTCAudioTrack *)audioTrack
                                 videoTrack:(RTCVideoTrack *)videoTrack {
    // 媒体约束
    RTCMediaConstraints *constraints = [self defaultMediaConstraint];
    // 创建配置
    RTCConfiguration *config = [[RTCConfiguration alloc] init];
    // ICE 中继服务器地址
    NSArray *iceServers = @[[self defaultIceServer]];
    config.iceServers = iceServers;
    // 创建一个peerconnection
    RTCPeerConnection *peerConnection = [factory peerConnectionWithConfiguration:config constraints:constraints delegate:self];
    
    NSArray *mediaStreamLabels = @[ @"ARDAMS" ];
    // 添加视频轨
    [peerConnection addTrack:videoTrack streamIds:mediaStreamLabels];
    // 添加音频轨
    [peerConnection addTrack:audioTrack streamIds:mediaStreamLabels];
    _connection = peerConnection;
    return peerConnection;
}

// 设置远端的媒体描述
- (void)setRemoteDescriptionWithJsep:(NSDictionary *)jsep {
    RTCSessionDescription *answerDescription = [RTCSessionDescription descriptionFromJSONDictionary:jsep];
    [_connection setRemoteDescription:answerDescription
                    completionHandler:^(NSError *_Nullable error){

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
    NSDictionary *mandatoryContraints = [self mandatoryConstraints];
    
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryContraints optionalConstraints:nil];
    
    __weak KSMediaConnection *weakSelf = self;
    [_connection answerForConstraints:constraints
                    completionHandler:^(RTCSessionDescription *_Nullable sdp, NSError *_Nullable error) {
        
        [weakSelf.connection setLocalDescription:sdp
                               completionHandler:^(NSError *_Nullable error) {
            completionHandler(sdp, error);
        }];
        
    }];
}

// 创建offer
- (void)createOfferWithCompletionHandler:(void (^)(RTCSessionDescription *sdp, NSError *error))completionHandler {
    __weak KSMediaConnection *weakSelf = self;
    [_connection offerForConstraints:[self defaultOfferConstraints]
                   completionHandler:^(RTCSessionDescription *_Nullable sdp, NSError *_Nullable error) {
        
        [weakSelf.connection setLocalDescription:sdp
                               completionHandler:^(NSError *_Nullable error) {
            completionHandler(sdp, error);
            
        }];
    }];
}

- (void)close {
    [_connection close];
    _connection = NULL;

    [_videoTrack removeRenderer:_videoView];
    _videoTrack = NULL;
    [_videoView renderFrame:nil];
    [_videoView removeFromSuperview];
}

// PeerConnection 媒体约束
- (RTCMediaConstraints *)defaultMediaConstraint {
    // DTLS
    NSDictionary *option = @{ @"DtlsSrtpKeyAgreement" : @"true" };
    RTCMediaConstraints *constrants = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:nil optionalConstraints:option];
    return constrants;
}

// stun 、 turn服务地址
- (RTCIceServer *)defaultIceServer {
    NSArray *array = [NSArray arrayWithObject:@"turn:turn.al.mancangyun:3478"];
    return [[RTCIceServer alloc] initWithURLStrings:array username:@"root" credential:@"mypasswd"];
}

- (NSDictionary *)mandatoryConstraints {
    return @{
        @"OfferToReceiveAudio" : @"true",
        @"OfferToReceiveVideo" : @"true"
    };
}

// offer约束
- (RTCMediaConstraints *)defaultOfferConstraints {
    NSDictionary *mandatoryContraints = [self mandatoryConstraints];
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryContraints optionalConstraints:@{ @"DtlsSrtpKeyAgreement" : @"true" }];
    return constraints;
}

//RTCPeerConnectionDelegate
- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didAddStream:(nonnull RTCMediaStream *)stream { 
    [self.delegate mediaConnection:self peerConnection:peerConnection didAddStream:stream];
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didGenerateIceCandidate:(nonnull RTCIceCandidate *)candidate {
    [self.delegate mediaConnection:self peerConnection:peerConnection didGenerateIceCandidate:candidate];
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didChangeIceConnectionState:(RTCIceConnectionState)newState {
    
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didChangeIceGatheringState:(RTCIceGatheringState)newState {
    
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didChangeSignalingState:(RTCSignalingState)stateChanged {
    
}


- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didOpenDataChannel:(nonnull RTCDataChannel *)dataChannel {
    
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didRemoveIceCandidates:(nonnull NSArray<RTCIceCandidate *> *)candidates {
    
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didRemoveStream:(nonnull RTCMediaStream *)stream {
    
}

- (void)peerConnectionShouldNegotiate:(nonnull RTCPeerConnection *)peerConnection {
    
}

@end
