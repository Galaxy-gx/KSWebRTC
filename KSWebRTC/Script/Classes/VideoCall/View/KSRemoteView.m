//
//  KSRemoteView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/2.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSRemoteView.h"

@implementation KSRemoteView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
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
@end
