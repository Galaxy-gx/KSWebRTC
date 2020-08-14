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

@interface KSMediaInfo : NSObject

@property (nonatomic, assign) BOOL         isLocal;
@property (nonatomic,assign ) KSCallType   callType;
@property (nonatomic,copy   ) NSString     *name;
@property (nonatomic, assign) BOOL         isOpenSpeaker;
@property (nonatomic, assign) BOOL         isFocus;

@end

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
@property (nonatomic, weak, readonly) AVCaptureSession  *captureSession;
@property (nonatomic, strong) RTCPeerConnection *peerConnection;//WebRTC连接对象
@property (nonatomic, strong) RTCVideoTrack     *remoteVideoTrack;//视频轨
@property (nonatomic, weak  ) RTCEAGLVideoView  *remoteVideoView;
@property (nonatomic, strong) NSNumber          *handleId;
@property (nonatomic, strong) KSMediaInfo       *mediaInfo;
@property (nonatomic,assign ) int               index;
@property (nonatomic, assign) BOOL              isClose;
@property (nonatomic,assign ) KSMediaState      mediaState;

- (RTCPeerConnection *)createPeerConnectionOfKSMediaCapture:(KSMediaCapturer *)capture;
- (void)createOfferWithCompletionHandler:(void (^)(RTCSessionDescription *sdp, NSError *error))completionHandler;
// 创建answer
- (void)createAnswerWithCompletionHandler:(void (^)(RTCSessionDescription *sdp, NSError *error))completionHandler;
- (void)setRemoteDescriptionWithJsep:(NSDictionary *)jsep;

- (void)muteAudio;
- (void)unmuteAudio;

- (void)muteVideo;
- (void)unmuteVideo;

- (void)speakerOff;
- (void)speakerOn;

- (void)switchTalkMode;
- (void)switchCamera;

- (void)stopCapture;
- (void)startCapture;

- (void)close;

@end
