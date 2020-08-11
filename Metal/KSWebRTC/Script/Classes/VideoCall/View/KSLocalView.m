//
//  KSLocalView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/2.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSLocalView.h"
#import "UIView+Category.h"

@interface KSLocalView()

@end

@implementation KSLocalView

- (void)updateCallType:(KSCallType)callType {
    self.callType = callType;
    if (self.callType == KSCallTypeManyVideo || self.callType == KSCallTypeSingleVideo) {
        [self createVideoView];
    }
}

- (void)createVideoView {
    if (self.videoView) {
        return;
    }
    RTCMTLVideoView *videoView = [[RTCMTLVideoView alloc] initWithFrame:self.bounds];
    videoView.videoContentMode = UIViewContentModeScaleAspectFill;
    self.videoView             = videoView;
    [self embedView:videoView containerView:self];
}

@end
