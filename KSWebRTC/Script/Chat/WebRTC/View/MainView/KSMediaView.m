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

@interface KSMediaView()<KSMediaConnectionUpdateDelegate,RTCVideoViewDelegate>
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

- (void)setConnection:(KSMediaConnection *)connection {
    if (_connection) {
        [_connection.videoTrack removeRenderer:_videoView];
        [_videoView renderFrame:nil];
    }
    //记录Renderer
    _connection.videoView = _videoView;
    if (connection == nil) {
        [self removeVideoView];
    }
    else{
        _connection               = connection;
        connection.updateDelegate = self;
        if (_connection.setting.isFocus) {
            [_connection.videoTrack addRenderer:_videoView];
        }
    }
    
    [self updateKit];
}

- (void)updateKit {
    
}

- (void)removeVideoView {
    [self.connection.videoTrack removeRenderer:self.videoView];
    [self.videoView renderFrame:nil];
    self.videoView = nil;
}

//KSMediaConnectionUpdateDelegate
- (void)mediaConnection:(KSMediaConnection *)mediaConnection didChangeMediaState:(KSMediaState)mediaState {
    
}

//模拟器RTCEAGLVideoView RTCVideoViewDelegate
- (void)videoView:(id<RTCVideoRenderer>)videoView didChangeVideoSize:(CGSize)size {
    
}

@end
