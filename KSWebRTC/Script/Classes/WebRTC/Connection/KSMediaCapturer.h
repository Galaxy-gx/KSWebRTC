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

@interface KSCapturerSetting : NSObject
@property (nonatomic,assign ) KSCallType callType;
@property (nonatomic,assign ) BOOL       isSSL;
@property (nonatomic,assign ) BOOL       isFront;
@property (nonatomic,assign ) BOOL       isStartCapture;
@property (nonatomic,assign ) CGSize     resolution;
@end

@interface KSMediaCapturer : NSObject

//连接工厂
@property (nonatomic, strong) RTCPeerConnectionFactory *factory;
//视频生产者
@property (nonatomic, strong) RTCCameraVideoCapturer   *capturer;
//轨
@property (nonatomic, strong) RTCVideoTrack            *videoTrack;
@property (nonatomic, strong) RTCAudioTrack            *audioTrack;
@property (nonatomic, strong) KSCapturerSetting        *setting;

-(instancetype)initWithSetting:(KSCapturerSetting *)setting;
- (void)addVideoSourceOfCallType:(KSCallType)callType;
- (void)switchTalkMode;
- (void)speakerOff;
- (void)speakerOn;
- (void)switchCamera;
- (void)stopCapture;
- (void)startCapture;
- (void)close;

@end
