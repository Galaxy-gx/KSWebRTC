//
//  KSVideoPreviewView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/7/24.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSVideoPreviewView.h"
#import "KSVisualEffectView.h"

@interface KSVideoPreviewView()
@property(nonatomic,weak)KSVisualEffectView *visualEffectView;
@end
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
    /*
    KSVisualEffectView *visualEffectView = [[KSVisualEffectView alloc] initWithFrame:self.bounds];
    [self addSubview:visualEffectView];
    _visualEffectView = visualEffectView;
     */
}

-(void)layoutSubviews {
    [super layoutSubviews];
    _previewLayer.frame = self.bounds;
    //_visualEffectView.frame = self.bounds;
}
@end
