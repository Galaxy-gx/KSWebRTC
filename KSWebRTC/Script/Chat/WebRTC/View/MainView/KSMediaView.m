//
//  KSMediaView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/15.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSMediaView.h"
#import "UIView+Category.h"
#import "UIColor+Category.h"
#import "KSProfileView.h"

@interface KSMediaView()<KSVideoTrackDelegate,RTCVideoViewDelegate>
@end

@implementation KSMediaView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
    }
    return self;
}

- (void)initKit {
    #if TARGET_IPHONE_SIMULATOR //模拟器
    RTCEAGLVideoView *videoView      = [[RTCEAGLVideoView alloc] initWithFrame:self.bounds];
    videoView.delegate               = self;
    #elif TARGET_OS_IPHONE //真机
    RTCMTLVideoView *videoView       = [[RTCMTLVideoView alloc] initWithFrame:self.bounds];
    videoView.videoContentMode       = UIViewContentModeScaleAspectFill;
    #endif
    _videoView                       = videoView;
    
    [self ks_embedView:videoView containerView:self];

    KSProfileBarView *profileBarView = [[KSProfileBarView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - KS_Extern_Point20, self.bounds.size.width, KS_Extern_Point20)];
    _profileBarView                  = profileBarView;
    [self addSubview:profileBarView];
    [profileBarView setUserName:@"Sevtin"];
    [profileBarView updateMediaState:KSMediaStateMuteAudio];

    KSRoundImageView *roundImageView = [[KSRoundImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width - KS_Extern_Point50)/2, (self.bounds.size.height - KS_Extern_Point50)/2, KS_Extern_Point50, KS_Extern_Point50) strokeColor:[UIColor ks_white] lineWidth:0.5];
    _roundImageView                  = roundImageView;
    [self addSubview:roundImageView];
    
    self.clipsToBounds               = YES;
}

-(void)setVideoTrack:(KSVideoTrack *)videoTrack {
    [self removeVideoView];
    
    if (videoTrack) {
        _videoTrack         = videoTrack;
        videoTrack.delegate = self;
        if (videoTrack.videoTrack) {
            [videoTrack addRenderer:_videoView];
        }
    }
    [self updateKit];
}

- (void)updateKit {
    
}

- (void)removeVideoView {
    if (_videoTrack) {
        [_videoTrack clearRenderer];
    }
}
//KSVideoTrackDelegate
- (void)videoTrack:(KSVideoTrack *)videoTrack didChangeMediaState:(KSMediaState)mediaState {
    
}

//模拟器RTCEAGLVideoView RTCVideoViewDelegate
- (void)videoView:(id<RTCVideoRenderer>)videoView didChangeVideoSize:(CGSize)size {
    
}

@end
