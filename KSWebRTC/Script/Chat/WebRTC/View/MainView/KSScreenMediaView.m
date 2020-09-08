//
//  KSScreenMediaView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/2.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSScreenMediaView.h"
#import "UIView+Category.h"
#import "UIColor+Category.h"
#import "UIFont+Category.h"
#import "KSProfileView.h"
@interface KSScreenMediaView()
@property (nonatomic,weak) KSProfileView    *profileView;
@property (nonatomic,weak) KSRoundImageView *avatarView;
@end

@implementation KSScreenMediaView

- (void)initKit {
    [super initKit];
    
    CGFloat self_w               = self.bounds.size.width;
    int icon_wh                  = 140;
    CGFloat icon_x               = (self_w - icon_wh)/2;
    CGFloat icon_y               = (self.bounds.size.height - icon_wh)/2;
    
    KSRoundImageView *avatarView = [[KSRoundImageView alloc] initWithFrame:CGRectMake(icon_x, icon_y, icon_wh, icon_wh)
                                                           backgroundColor:[UIColor ks_blueBtn]
                                                                 textColor:[UIColor ks_white]
                                                                      font:[UIFont ks_fontMediumOfSize:KS_Extern_36Font]
                                                               strokeColor:[UIColor ks_white]
                                                                 lineWidth:0.5];
    _avatarView                  = avatarView;
    [self addSubview:avatarView];
    
    CGFloat pv_h                 = 204;
    CGFloat pv_y                 = (self.bounds.size.height - pv_h)/2 - 50;
    KSProfileView *profileView   = [[KSProfileView alloc] initWithFrame:CGRectMake(0, pv_y, self.bounds.size.width, pv_h)];
    _profileView                 = profileView;
    [self addSubview:profileView];
    
    avatarView.hidden            = YES;
}

- (void)setProfileInfo:(KSProfileInfo *)profileInfo {
    _profileInfo                 = profileInfo;
    self.profileView.hidden      = NO;
    self.avatarView.hidden       = YES;
    self.profileView.profileInfo = profileInfo;
    [self.avatarView updateTitle:profileInfo.myname];
}

- (void)displayAvatar {
    _profileView.hidden = YES;
    _avatarView.hidden  = NO;
}

- (void)hiddenProfileView {
    _profileView.hidden = YES;
    _avatarView.hidden  = YES;
}

//KSMediaTrackDelegate
- (void)mediaTrack:(KSMediaTrack *)mediaTrack didChangeMediaState:(KSMediaState)mediaState {
    
}

@end
