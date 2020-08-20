//
//  KSVideoTrack.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/20.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSVideoTrack.h"

@implementation KSVideoTrack

-(void)setMediaState:(KSMediaState)mediaState {
    _mediaState = mediaState;
    if ([self.delegate respondsToSelector:@selector(videoTrack:didChangeMediaState:)]) {
        [self.delegate videoTrack:self didChangeMediaState:mediaState];
    }
}

- (void)addRenderer:(id<RTCVideoRenderer>)renderer {
    [self.videoTrack addRenderer:renderer];
}

- (void)clearRenderer {
    if (_videoView) {
        if (_videoTrack) {
            [_videoTrack removeRenderer:_videoView];
        }
        [_videoView renderFrame:nil];
    }
    _videoView    = nil;
}
@end
