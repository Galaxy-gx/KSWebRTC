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

@class KSVideoTrack;

@protocol KSVideoTrackDelegate <NSObject>
- (void)videoTrack:(KSVideoTrack *)videoTrack didChangeMediaState:(KSMediaState)mediaState;
@end

@interface KSVideoTrack : NSObject
@property (nonatomic,weak   ) id<KSVideoTrackDelegate> delegate;
@property (nonatomic, weak  ) UIView<RTCVideoRenderer>  *videoView;
@property (nonatomic,strong ) RTCVideoTrack *videoTrack;
@property (nonatomic,assign ) KSCallType    callType;
@property (nonatomic,assign ) KSMediaState  mediaState;
@property (nonatomic, assign) BOOL          isLocal;
@property (nonatomic, assign) int           index;
@property (nonatomic, strong) NSNumber      *handleId;

- (void)addRenderer:(id<RTCVideoRenderer>)renderer;
- (void)clearRenderer;
@end

