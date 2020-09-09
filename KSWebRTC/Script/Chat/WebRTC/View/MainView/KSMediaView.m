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

@interface KSMediaView()<KSMediaTrackDelegate,RTCVideoViewDelegate>
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
    #elif TARGET_OS_IPHONE //真机
    RTCMTLVideoView *videoView       = [[RTCMTLVideoView alloc] initWithFrame:self.bounds];
    videoView.videoContentMode       = UIViewContentModeScaleAspectFill;
    #endif
    videoView.delegate               = self;
    videoView.userInteractionEnabled = NO;
    _videoView                       = videoView;
    self.layer.masksToBounds         = YES;
    [self ks_embedView:videoView containerView:self];
}

-(void)setMediaTrack:(KSMediaTrack *)mediaTrack {
    [self removeMediaView];
    
    if (mediaTrack) {
        _mediaTrack         = mediaTrack;
        mediaTrack.delegate = self;
        if (mediaTrack.myType == KSCallTypeSingleVideo || mediaTrack.myType == KSCallTypeManyVideo) {
            if (mediaTrack.videoTrack) {
                [mediaTrack addRenderer:_videoView];
            }
        }
    }
    [self updateKit];
}

- (void)updateKit {
    
}

- (void)removeMediaView {
    if (_mediaTrack) {
        [_mediaTrack clearRenderer];
    }
    _mediaTrack.delegate = nil;
    _mediaTrack          = nil;
}
//KSMediaTrackDelegate
- (void)mediaTrack:(KSMediaTrack *)mediaTrack didChangeMediaState:(KSMediaState)mediaState {
    
}

//模拟器RTCEAGLVideoView RTCVideoViewDelegate
- (void)videoView:(id<RTCVideoRenderer>)videoView didChangeVideoSize:(CGSize)size {
    
}

@end
