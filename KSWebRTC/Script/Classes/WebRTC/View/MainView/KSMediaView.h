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
#import "KSMediaConnection.h"
#import "KSTileLayout.h"
#import "KSProfileBarView.h"
#import "KSRoundImageView.h"

@interface KSMediaView : UIView

@property (nonatomic,weak) KSMediaConnection *connection;
@property (nonatomic,weak) RTCMTLVideoView   *videoView;

@property (nonatomic,weak) KSProfileBarView  *profileBarView;
@property (nonatomic,weak) KSRoundImageView  *roundImageView;

- (void)removeVideoView;

@end
