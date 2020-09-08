//
//  KSTileMediaView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/2.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSTileMediaView.h"
#import "UIView+Category.h"
#import "KSProfileView.h"
#import "KSProfileBarView.h"
#import "KSRoundImageView.h"
#import "UIColor+Category.h"
#import "UIFont+Category.h"
#import "KSUserInfo.h"

@interface KSTileMediaView()
@property (nonatomic,assign) KSCallType       callType;
@property (nonatomic,weak  ) KSProfileBarView *profileBarView;
@property (nonatomic,weak  ) KSRoundImageView *avatarView;
@end

@implementation KSTileMediaView

- (void)initKit {
    [super initKit];
    
    self.backgroundColor             = [UIColor ks_grayBar];
    KSProfileBarView *profileBarView = [[KSProfileBarView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - KS_Extern_Point20, self.bounds.size.width, KS_Extern_Point20)];
    _profileBarView                  = profileBarView;
    [self addSubview:profileBarView];
    
    KSRoundImageView *avatarView     = [[KSRoundImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width - KS_Extern_Point50)/2, (self.bounds.size.height - KS_Extern_Point50)/2, KS_Extern_Point50, KS_Extern_Point50)
                                                               backgroundColor:[UIColor ks_blueBtn]
                                                                     textColor:[UIColor ks_white]
                                                                          font:[UIFont ks_fontMediumOfSize:KS_Extern_18Font]
                                                                   strokeColor:[UIColor ks_white]
                                                                     lineWidth:0.5];
    _avatarView                      = avatarView;
    [self addSubview:avatarView];
    avatarView.hidden                = YES;
}

- (void)updateKit {
    [self updateMediaTrack:self.mediaTrack];
}

- (void)updateMediaTrack:(KSMediaTrack *)mediaTrack {
    if (mediaTrack == nil) {
        return;
    }
    _callType = mediaTrack.myType;
    switch (self.mediaTrack.myType) {
        case KSCallTypeSingleAudio:
        {
            if (self.mediaTrack.userInfo != nil) {
                self.profileBarView.hidden = NO;
                self.avatarView.hidden     = NO;
                self.videoView.hidden      = YES;
                [self updateProfileOfMediaTrack:mediaTrack];
            }
        }
            break;
        case KSCallTypeManyAudio:
            
            break;
        case KSCallTypeSingleVideo:
            self.videoView.hidden      = NO;
            self.profileBarView.hidden = NO;
            self.avatarView.hidden     = YES;
            [self updateProfileOfMediaTrack:mediaTrack];
            break;
        case KSCallTypeManyVideo:
            self.profileBarView.hidden = NO;
            self.avatarView.hidden     = YES;
            break;
        default:
            break;
    }
}

- (void)updateProfileOfMediaTrack:(KSMediaTrack *)mediaTrack {
    [self.avatarView updateTitle:self.mediaTrack.userInfo.name];
    [self.profileBarView setUserName:self.mediaTrack.userInfo.name];
    [self.profileBarView updateMediaState:self.mediaTrack.mediaState];
}

//KSMediaTrackDelegate
- (void)mediaTrack:(KSMediaTrack *)mediaTrack didChangeMediaState:(KSMediaState)mediaState {
    if (mediaTrack.myType == _callType) {
        [self updateMediaTrack:mediaTrack];
    }
    else{
        self.mediaTrack = mediaTrack;
    }
}

- (void)hiddenBar {
    self.profileBarView.hidden = YES;
    self.avatarView.hidden     = YES;
}

@end
