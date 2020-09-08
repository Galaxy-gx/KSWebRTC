//
//  KSMediaCapturer.h
//  KSWebRTC
//
//  Created by saeipi on 2020/7/10.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>
#import "KSConfigure.h"
#import "KSMediaSetting.h"
@class KSMediaCapturer;

@protocol KSMediaCapturerDelegate <NSObject>
- (KSCallType)callTypeOfMediaCapturer:(KSMediaCapturer *)mediaCapturer;
@optional
- (KSScale)scaleOfMediaCapturer:(KSMediaCapturer *)mediaCapturer;
@end
@interface KSMediaCapturer : NSObject

@property(nonatomic, weak)id<KSMediaCapturerDelegate>  delegate;
//连接工厂
@property (nonatomic, strong) RTCPeerConnectionFactory *factory;
//视频生产者
@property (nonatomic, strong) RTCCameraVideoCapturer   *capturer;
//轨
@property (nonatomic, strong) RTCVideoTrack            *videoTrack;
@property (nonatomic, strong) RTCAudioTrack            *audioTrack;
@property (nonatomic, strong) KSCapturerSetting        *setting;

- (instancetype)initWithSetting:(KSCapturerSetting *)setting;
- (void)addMediaSource;
- (void)addVideoSource;
//- (void)updateResolution:(CGSize)resolution;

- (void)muteAudio;
- (void)unmuteAudio;

- (void)muteVideo;
- (void)unmuteVideo;

- (void)speakerOff;
- (void)speakerOn;

- (void)switchTalkMode;
- (void)switchCamera;

- (void)startCapture;
- (void)stopCapture;

- (void)closeCapturer;

@end
