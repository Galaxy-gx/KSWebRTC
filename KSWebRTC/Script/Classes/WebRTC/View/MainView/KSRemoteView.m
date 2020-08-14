//
//  KSRemoteView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/2.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSRemoteView.h"
#import "UIView+Category.h"
#import "KSProfileView.h"
#import "KSProfileBarView.h"
#import "KSRoundImageView.h"
#import "UIColor+Category.h"

@implementation KSEAGLVideoView
@end

@interface KSRemoteView()<KSMediaConnectionUpdateDelegate>

@property (nonatomic,weak) KSProfileBarView *profileBarView;
@property (nonatomic,weak) KSRoundImageView *roundImageView;
@property (nonatomic,weak) KSEAGLVideoView  *remoteView;

@end

@implementation KSRemoteView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
    }
    return self;
}

- (void)initKit {
    KSEAGLVideoView *remoteView      = [[KSEAGLVideoView alloc] init];
    remoteView.frame                 = self.bounds;
    _remoteView                      = remoteView;
    [self addSubview:remoteView];

    KSProfileBarView *profileBarView = [[KSProfileBarView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - KS_Extern_Point20, self.bounds.size.width, KS_Extern_Point20)];
    _profileBarView                  = profileBarView;
    [self addSubview:profileBarView];
    [profileBarView setUserName:@"Sevtin"];
    [profileBarView updateMediaState:KSMediaStateMuteAudio];

    KSRoundImageView *roundImageView = [[KSRoundImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width - KS_Extern_Point50)/2, (self.bounds.size.height - KS_Extern_Point50)/2, KS_Extern_Point50, KS_Extern_Point50) strokeColor:[UIColor ks_white] lineWidth:0.5];
    _roundImageView                  = roundImageView;
    [self addSubview:roundImageView];
}

-(void)setConnection:(KSMediaConnection *)connection {
    if (_connection) {
        [_connection.remoteVideoTrack removeRenderer:_remoteView];
    }
    _connection = connection;
    connection.updateDelegate = self;
    if (connection.mediaInfo.isFocus) {
        [connection.remoteVideoTrack addRenderer:_remoteView];
    }
    
    switch (connection.mediaInfo.callType) {
        case KSCallTypeSingleAudio:

            break;
        case KSCallTypeManyAudio:
            
            break;
        case KSCallTypeSingleVideo:
            _profileBarView.hidden = YES;
            _roundImageView.hidden = YES;
            break;
        case KSCallTypeManyVideo:
            _profileBarView.hidden = NO;
            _roundImageView.hidden = YES;
            break;
        default:
            break;
    }
}

- (void)removeVideoView {
    if (_connection) {
        [_connection.remoteVideoTrack removeRenderer:_remoteView];
    }
    _connection = nil;
    [_remoteView removeFromSuperview];
}

//KSMediaConnectionUpdateDelegate
- (void)mediaConnection:(KSMediaConnection *)mediaConnection didChangeMediaState:(KSMediaState)mediaState {
    
}
@end
