//
//  KSMediaConnection.h
//  KSWebRTC
//
//  Created by saeipi on 2020/7/11.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>
#import "KSMediaCapturer.h"
#import "KSCallState.h"
#import "KSMediaSetting.h"

@class KSMediaConnection;
@protocol KSMediaConnectionDelegate <NSObject>
// 收到远端流处理
//- (void)mediaConnection:(KSMediaConnection *)mediaConnection peerConnection:(RTCPeerConnection *)peerConnection didAddStream:(RTCMediaStream *)stream;
// 收到候选者
- (void)mediaConnection:(KSMediaConnection *)mediaConnection peerConnection:(RTCPeerConnection *)peerConnection didGenerateIceCandidate:(RTCIceCandidate *)candidate;
- (void)mediaConnection:(KSMediaConnection *)mediaConnection peerConnection:(RTCPeerConnection *)peerConnection didAddReceiver:(RTCRtpReceiver *)rtpReceiver streams:(NSArray<RTCMediaStream *> *)mediaStreams;
- (void)mediaConnection:(KSMediaConnection *)mediaConnection didChangeIceConnectionState:(RTCIceConnectionState)newState;
@end

@protocol KSMediaConnectionUpdateDelegate <NSObject>
- (void)mediaConnection:(KSMediaConnection *)mediaConnection didChangeMediaState:(KSMediaState)mediaState;
@end

@interface KSMediaConnection : NSObject

@property (nonatomic, weak  ) id<KSMediaConnectionDelegate> delegate;
@property (nonatomic, weak  ) id<KSMediaConnectionUpdateDelegate> updateDelegate;
@property (nonatomic, weak  ) UIView<RTCVideoRenderer>  *videoView;
@property (nonatomic, strong) RTCVideoTrack       *videoTrack;// 视频轨
@property (nonatomic, strong) KSConnectionSetting *setting;
@property (nonatomic, strong) NSNumber            *handleId;
@property (nonatomic,assign ) int                 index;
@property (nonatomic, assign) BOOL                isClose;
@property (nonatomic, assign) BOOL                isLocal;
@property (nonatomic,assign ) KSMediaState        mediaState;
@property (nonatomic,assign ) KSCallType          callType;

- (instancetype)initWithSetting:(KSConnectionSetting *)setting;
- (RTCPeerConnection *)createPeerConnectionWithMediaCapturer:(KSMediaCapturer *)capture;
- (void)addRenderer:(id<RTCVideoRenderer>)renderer;
- (void)createOfferWithCompletionHandler:(void (^)(RTCSessionDescription *sdp, NSError *error))completionHandler;
// 创建answer
- (void)createAnswerWithCompletionHandler:(void (^)(RTCSessionDescription *sdp, NSError *error))completionHandler;
- (void)setRemoteDescriptionWithJsep:(NSDictionary *)jsep;

- (void)closeConnection;
- (void)clearRenderer;

@end
