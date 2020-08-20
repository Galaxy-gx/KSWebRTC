//
//  KSSuperClient.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/20.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>
#import "KSMediaSetting.h"
#import "KSMediaCapturer.h"

@protocol KSSuperClientDelegate <NSObject>


@end

@interface KSSuperClient : NSObject {
    
}
@property(nonatomic,weak)id<KSSuperClientDelegate> delegate;
@property(nonatomic,strong)RTCPeerConnection *peerConnection;
@property(nonatomic,weak)RTCAudioSession *rtcAudioSession;

@property(nonatomic,strong)RTCVideoCapturer *videoCapturer;

@property(nonatomic,strong)RTCVideoTrack *localVideoTrack;
@property(nonatomic,strong)RTCVideoTrack *remoteVideoTrack;
@property(nonatomic,strong)RTCDataChannel *localDataChannel;
@property(nonatomic,strong)RTCDataChannel *remoteDataChannel;



@property (nonatomic, strong) KSConnectionSetting *setting;
@property (nonatomic,assign ) KSCallType          callType;
@end
