//
//  KSMediaCapture.h
//  KSWebRTC
//
//  Created by saeipi on 2020/7/10.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>

@interface KSMediaCapture : NSObject
//连接工厂
@property (nonatomic, strong) RTCPeerConnectionFactory *factory;
//视频生产者
@property (nonatomic, strong) RTCCameraVideoCapturer *capturer;
//轨道
@property (nonatomic, strong) RTCVideoTrack *videoTrack;
@property (nonatomic, strong) RTCAudioTrack *audioTrack;

- (void)createPeerConnectionFactory;
- (void)captureLocalMedia;
- (void)addRenderer:(id<RTCVideoRenderer>)renderer;

- (void)switchCamera;
- (void)switchTalkMode;
- (void)stopCapture;

@end
