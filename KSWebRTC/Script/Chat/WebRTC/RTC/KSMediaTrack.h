//
//  KSVideoTrack.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/20.
//  Copyright © 2020 saeipi. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>
#import "KSConfigure.h"
#import "KSCallState.h"
#import "KSUserInfo.h"
#import "KSMediaConnection.h"

@class KSMediaTrack;

@protocol KSMediaTrackDelegate <NSObject>
- (void)mediaTrack:(KSMediaTrack *)mediaTrack didChangeMediaState:(KSMediaState)mediaState;
@end

@protocol KSMediaTrackDataSource <NSObject>
- (KSCallType)callTypeOfMediaTrack:(KSMediaTrack *)mediaTrack;
@end

@interface KSMediaTrack : NSObject
@property (nonatomic,weak   ) id<KSMediaTrackDelegate>   delegate;
@property (nonatomic,weak   ) id<KSMediaTrackDataSource> dataSource;
@property (nonatomic, weak  ) UIView<RTCVideoRenderer>   *videoView;
@property (nonatomic, assign,readonly) KSCallType         myType;
@property (nonatomic, strong ) KSMediaConnection *peerConnection;
@property (nonatomic, strong ) RTCVideoTrack     *videoTrack;
@property (nonatomic, strong ) RTCAudioTrack     *audioTrack;
@property (nonatomic, assign ) KSMediaState      mediaState;
@property (nonatomic, assign ) BOOL              isLocal;
@property (nonatomic, assign ) int               index;
@property (nonatomic, strong ) KSUserInfo        *userInfo;
@property (nonatomic, assign ) long long         sessionId;

- (void)addRenderer:(UIView<RTCVideoRenderer> *)renderer;
- (void)clearRenderer;

@end

