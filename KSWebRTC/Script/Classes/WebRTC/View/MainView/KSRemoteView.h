//
//  KSRemoteView.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/2.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebRTC/WebRTC.h>
#import "KSConfigure.h"
#import "KSMediaConnection.h"

@interface KSEAGLVideoView : RTCEAGLVideoView
@end

@interface KSRemoteView : UIView
@property (nonatomic,weak) KSMediaConnection *connection;

- (void)removeVideoView;

@end
