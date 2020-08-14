//
//  KSLocalView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/2.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSLocalView.h"
#import "UIView+Category.h"

@implementation KSPreviewLayer
-(id<CAAction>)actionForKey:(NSString *)event {
    return nil;
}
@end

@interface KSLocalView()<KSMediaConnectionUpdateDelegate>

@property (nonatomic,weak) KSPreviewLayer *previewLayer;

@end

@implementation KSLocalView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
    }
    return self;
}

- (void)initKit {
    KSPreviewLayer *previewLayer = [[KSPreviewLayer alloc] init];
    previewLayer.videoGravity    = AVLayerVideoGravityResizeAspectFill;//填充模式
    _previewLayer                = previewLayer;
    [self.layer addSublayer:previewLayer];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    _previewLayer.frame = self.bounds;
}

-(void)setConnection:(KSMediaConnection *)connection {
    _connection               = connection;
    connection.updateDelegate = self;
    if (connection.mediaInfo.isFocus) {
        [self setSession:connection.captureSession];
    }
    if (connection == nil) {
        [self removeVideoView];
    }
}

- (void)setSession:(AVCaptureSession *)session {
    _previewLayer.session = session;
    _previewLayer.hidden  = session == nil ? YES : NO;
}

- (void)removeVideoView {
    [_previewLayer removeFromSuperlayer];
    _previewLayer.session = nil;
    _previewLayer = nil;
}

//KSMediaConnectionUpdateDelegate
- (void)mediaConnection:(KSMediaConnection *)mediaConnection didChangeMediaState:(KSMediaState)mediaState {
    
}

@end
