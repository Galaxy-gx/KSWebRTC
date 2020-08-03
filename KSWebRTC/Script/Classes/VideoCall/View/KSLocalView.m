//
//  KSLocalView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/2.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSLocalView.h"
@interface KSLocalView()

@property(nonatomic,weak)AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation KSLocalView

-(instancetype)initWithFrame:(CGRect)frame resizingMode:(KSResizingMode)resizingMode {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
        [self updatePreviewWidth:frame.size.width height:frame.size.height resizingMode:resizingMode];
    }
    return self;
}

- (void)initKit {
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] init];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//填充模式
    _previewLayer = previewLayer;
    [self.layer addSublayer:previewLayer];
}

- (void)setLocalViewSession:(AVCaptureSession *)session {
    _previewLayer.session = session;
}

- (void)updatePreviewWidth:(CGFloat)width height:(CGFloat)height resizingMode:(KSResizingMode)resizingMode {
    switch (resizingMode) {
        case KSResizingModeTile:
            _previewLayer.frame = CGRectMake((self.frame.size.width - width)/2.0,
                                             (self.frame.size.height - height)/2.0,
                                             width, height);
            break;
        case KSResizingModeScreen:
            _previewLayer.frame = self.bounds;
            break;
            
        default:
            break;
    }
}

@end
