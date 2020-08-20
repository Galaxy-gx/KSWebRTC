//
//  KSMediaView.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/15.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebRTC/WebRTC.h>
#import "KSConfigure.h"
#import "KSTileLayout.h"
#import "KSProfileBarView.h"
#import "KSRoundImageView.h"
#import "KSVideoTrack.h"

@interface KSMediaView : UIView

@property (nonatomic,weak) KSProfileBarView *profileBarView;
@property (nonatomic,weak) KSRoundImageView *roundImageView;
@property (nonatomic,weak) KSVideoTrack     *videoTrack;
@property (nonatomic,weak) UIView<RTCVideoRenderer> *videoView;

- (void)removeVideoView;

@end
