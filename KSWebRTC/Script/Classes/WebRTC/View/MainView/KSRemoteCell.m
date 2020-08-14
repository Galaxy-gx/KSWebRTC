//
//  KSRemoteCell.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/12.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSRemoteCell.h"
#import "UIView+Category.h"
#import "KSProfileView.h"
#import "KSProfileBarView.h"
#import "KSRoundImageView.h"
#import "KSRemoteView.h"

@interface KSRemoteCell()
@property (nonatomic,assign) KSCallType       callType;
@property (nonatomic,weak  ) KSProfileBarView *profileBarView;
@property (nonatomic,weak  ) KSRoundImageView *roundImageView;
@property (nonatomic,weak  ) KSEAGLVideoView  *remoteView;

@end
@implementation KSRemoteCell

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
    [profileBarView updateStateType:KSAudioStateTypeMute];

    KSRoundImageView *roundImageView = [[KSRoundImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width - KS_Extern_Point50)/2, (self.bounds.size.height - KS_Extern_Point50)/2, KS_Extern_Point50, KS_Extern_Point50) strokeColor:[UIColor ks_white] lineWidth:0.5];
    _roundImageView                  = roundImageView;
    [self addSubview:roundImageView];
    if (self.callType == KSCallTypeSingleVideo) {
        profileBarView.hidden = YES;
        roundImageView.hidden = YES;
    }
}

-(void)setConnection:(KSMediaConnection *)connection {
    if (_connection) {
        [_connection.remoteVideoTrack removeRenderer:_remoteView];
    }
    _connection = connection;
    if (connection.mediaInfo.isFocus) {
        [connection.remoteVideoTrack addRenderer:_remoteView];
    }
    if (connection.mediaInfo.callType == KSCallTypeSingleVideo) {
        _profileBarView.hidden = YES;
        _roundImageView.hidden = YES;
    }
    else if (connection.mediaInfo.callType == KSCallTypeManyVideo) {
        _profileBarView.hidden = NO;
        _roundImageView.hidden = YES;
    }
    else{
        
    }
}

@end
