//
//  KSLocalView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/2.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSLocalView.h"

@implementation KSLocalView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
    }
    return self;
}

- (void)initKit {
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] init];
    _previewLayer = previewLayer;
    [self.layer addSublayer:previewLayer];
}

- (void)setLocalViewSession:(AVCaptureSession *)session {
    _previewLayer.session = session;
}

- (void)setFrameWithSize:(CGSize)size resizingMode:(KSResizingMode)resizingMode {
    switch (resizingMode) {
        case KSResizingModeTile:
            _previewLayer.frame = CGRectMake((self.frame.size.width - size.width)/2.0,
                                             (self.frame.size.height - size.height)/2.0,
                                             size.width, size.height);
            break;
        case KSResizingModeScreen:
            _previewLayer.frame = self.bounds;
            break;
            
        default:
            break;
    }
}

@end
