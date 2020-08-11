//
//  KSRemoteView.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/2.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSEAGLVideoView.h"
#import "KSConfigure.h"

@interface KSRemoteView : UIView
@property(nonatomic,weak) KSEAGLVideoView *remoteView;
@property(nonatomic,strong)NSNumber *handleId;

- (instancetype)initWithFrame:(CGRect)frame scale:(KSScale)scale mode:(KSContentMode)mode callType:(KSCallType)callType;
- (void)updatePreviewWidth:(CGFloat)width height:(CGFloat)height scale:(KSScale)scale mode:(KSContentMode)mode;
- (void)removeVideoView;

@end
