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
    [self.delegate MediaConnection:self peerConnection:peerConnection didAddStream:stream];
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didGenerateIceCandidate:(nonnull RTCIceCandidate *)candidate {
    [self.delegate MediaConnection:self peerConnection:peerConnection didGenerateIceCandidate:candidate];
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
