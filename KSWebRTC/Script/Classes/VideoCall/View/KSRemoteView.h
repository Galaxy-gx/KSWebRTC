//
//  KSRemoteView.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/2.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSEAGLVideoView.h"

@interface KSRemoteView : UIView
@property(nonatomic,weak) KSEAGLVideoView *remoteView;
@property(nonatomic,strong)NSNumber *handleId;
@end
