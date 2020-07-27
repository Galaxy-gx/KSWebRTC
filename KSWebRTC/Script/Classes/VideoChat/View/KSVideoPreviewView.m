//
//  KSVideoPreviewView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/7/24.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSVideoPreviewView.h"

@implementation KSVideoPreviewView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initLayer];
    }
    return self;
}

-(void)initLayer {
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] init];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//填充模式
    previewLayer.frame = self.bounds;
    [self.layer addSublayer:previewLayer];
    _previewLayer = previewLayer;
}

@end
