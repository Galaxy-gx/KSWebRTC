//
//  KSVideoTrack.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/20.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSMediaTrack.h"

@implementation KSMediaTrack

-(void)setMediaState:(KSMediaState)mediaState {
    _mediaState = mediaState;
    if ([self.delegate respondsToSelector:@selector(mediaTrack:didChangeMediaState:)]) {
        [self.delegate mediaTrack:self didChangeMediaState:mediaState];
    }
}

- (void)addRenderer:(UIView<RTCVideoRenderer> *)renderer {
    _videoView = renderer;
    [self.videoTrack addRenderer:renderer];
}

- (void)clearRenderer {
    //self.dataSource = nil;//数据源需要复用，不用清空
    self.delegate   = nil;
    if (_videoView) {
        if (_videoTrack) {
            [_videoTrack removeRenderer:_videoView];
            //_videoTrack = nil;//需要复用。不用置空
        }
        [_videoView renderFrame:nil];
        _videoView    = nil;
    }
}

-(KSCallType)myType {
    if ([self.dataSource respondsToSelector:@selector(callTypeOfMediaTrack:)]) {
        return [self.dataSource callTypeOfMediaTrack:self];
    }
    return KSCallTypeSingleVideo;
}

-(void)setMyType:(KSCallType)myType {
}

@end
