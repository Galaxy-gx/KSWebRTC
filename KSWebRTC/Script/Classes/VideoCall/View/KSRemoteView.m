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
@interface KSRemoteView()

@property(nonatomic,assign)KSCallType callType;
@property(nonatomic,weak)KSProfileBarView *profileBarView;
@property(nonatomic,weak)KSRoundImageView *roundImageView;

@end

@implementation KSRemoteView

- (instancetype)initWithFrame:(CGRect)frame scale:(KSScale)scale mode:(KSContentMode)mode callType:(KSCallType)callType {
    if (self = [super initWithFrame:frame]) {
        self.callType = callType;
        [self initKit];
        [self updatePreviewWidth:frame.size.width height:frame.size.height scale:scale mode:mode];
    }
    return self;
}

- (void)initKit {
    KSEAGLVideoView *remoteView      = [[KSEAGLVideoView alloc] init];
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

-(void)setHandleId:(NSNumber *)handleId {
    _handleId            = handleId;
    _remoteView.handleId = handleId;
}

- (void)updatePreviewWidth:(CGFloat)width height:(CGFloat)height scale:(KSScale)scale mode:(KSContentMode)mode {
    _remoteView.frame = [self ks_rectOfSuperFrame:self.frame width:width height:height scale:scale mode:mode];
}

- (void)removeVideoView {
    [_remoteView removeFromSuperview];
}

@end
