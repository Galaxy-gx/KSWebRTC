//
//  KSMediaSetting.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/15.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSConfigure.h"
#import "KSCallState.h"

@interface KSIceServer : NSObject<NSCopying,NSMutableCopying>
@property(nonatomic,copy)NSMutableArray<NSString *> *servers;
@property(nonatomic,copy)NSString *username;
@property(nonatomic,copy)NSString *password;
@end

@interface KSCapturerSetting : NSObject
@property (nonatomic,assign ) KSCallType callType;
@property (nonatomic,assign ) BOOL       isSSL;
@property (nonatomic,assign ) BOOL       isFront;
@property (nonatomic,assign ) BOOL       isOpenSpeaker;
@property (nonatomic,assign ) BOOL       isMuteAudio;
@property (nonatomic,assign ) BOOL       isMuteVideo;
@property (nonatomic,assign ) BOOL       isStartCapture;
@property (nonatomic,assign ) CGSize     resolution;
@end

@interface KSConnectionSetting : NSObject<NSCopying,NSMutableCopying>
@property (nonatomic,strong ) KSIceServer *iceServer;
@property (nonatomic,assign ) KSCallType  callType;
@property (nonatomic,assign ) BOOL        audio;
@property (nonatomic,assign ) BOOL        video;
@property (nonatomic, assign,readonly) BOOL isFocus;

@end

@interface KSMediaSetting : NSObject
@property (nonatomic,assign) KSCallType          callType;
@property (nonatomic,strong) KSCapturerSetting   *capturerSetting;
@property (nonatomic,strong) KSConnectionSetting *connectionSetting;

-(instancetype)initWithConnectionSetting:(KSConnectionSetting *)connectionSetting capturerSetting:(KSCapturerSetting *)capturerSetting;

@end

