//
//  KSRemoteView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/2.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSRemoteView.h"
#import "UIView+Category.h"

@implementation KSRemoteView

- (instancetype)initWithFrame:(CGRect)frame scale:(KSScale)scale mode:(KSContentMode)mode {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
        [self updatePreviewWidth:frame.size.width height:frame.size.height scale:scale mode:mode];
    }
    return self;
}

- (void)initKit {
    KSEAGLVideoView *remoteView = [[KSEAGLVideoView alloc] init];
    _remoteView = remoteView;
    [self addSubview:remoteView];
}

-(void)setHandleId:(NSNumber *)handleId {
    _handleId = handleId;
    _remoteView.handleId = handleId;
}

- (void)updatePreviewWidth:(CGFloat)width height:(CGFloat)height scale:(KSScale)scale mode:(KSContentMode)mode {
    _remoteView.frame = [self rectOfSuperFrame:self.frame width:width height:height scale:scale mode:mode];
}

@end
