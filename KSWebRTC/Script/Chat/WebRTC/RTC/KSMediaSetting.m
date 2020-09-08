//
//  KSMediaSetting.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/15.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSMediaSetting.h"

@implementation KSIceServer
- (id)copyWithZone:(nullable NSZone *)zone {
    KSIceServer *iceServer = [[KSIceServer alloc] init];
    iceServer.servers      = [_servers copy];
    iceServer.username     = _username;
    iceServer.password     = _password;
    return iceServer;
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    KSIceServer *iceServer = [[KSIceServer alloc] init];
    iceServer.servers      = [_servers mutableCopy];
    iceServer.username     = _username;
    iceServer.password     = _password;
    return iceServer;
}

- (instancetype)init {
    if (self = [super init]) {
        /*
        NSArray *array = @[@"stun:stun.l.google.com:19302",
                           @"stun:stun1.l.google.com:19302",
                           @"stun:stun2.l.google.com:19302",
                           @"stun:stun3.l.google.com:19302",
                           @"stun:stun4.l.google.com:19302"];
         _servers       = [NSMutableArray arrayWithArray:array];
         */
        
        NSArray *array = @[@"turn:apturn.hiapponline.com:443", @"turn:209.51.174.23:53"];
        _servers       = [NSMutableArray arrayWithArray:array];
        _username      = @"digi";
        _password      = @"createyourownturnserver";
    }
    return self;
}

@end

@implementation KSCapturerSetting
-(instancetype)init {
    if (self = [super init]) {
        _isSSL          = YES;
        _isFront        = YES;
        _isOpenSpeaker  = YES;
        _isMuteAudio    = NO;
        _isMuteVideo    = NO;
        _isStartCapture = YES;
        //_resolution     = CGSizeMake(540, 960);
    }
    return self;
}

@end

@implementation KSConnectionSetting

- (id)copyWithZone:(nullable NSZone *)zone {
    KSConnectionSetting *setting = [[KSConnectionSetting alloc] init];
    setting.iceServer            = [_iceServer copy];
    return setting;
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    KSConnectionSetting *setting = [[KSConnectionSetting alloc] init];
    setting.iceServer            = [_iceServer copy];
    return setting;
}

@end

@implementation KSMediaSetting
-(instancetype)initWithConnectionSetting:(KSConnectionSetting *)connectionSetting capturerSetting:(KSCapturerSetting *)capturerSetting callType:(KSCallType)callType {
    if (self = [super init]) {
        _connectionSetting = connectionSetting;
        _capturerSetting   = capturerSetting;
        _callType          = callType;
    }
    return self;
}
@end

