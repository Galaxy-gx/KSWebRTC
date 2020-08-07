//
//  KSLocalView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/2.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSLocalView.h"
#import "UIView+Category.h"

@interface KSLocalView()

@property(nonatomic,weak)AVCaptureVideoPreviewLayer *previewLayer;
@property(nonatomic,assign)KSCallType callType;
@end

@implementation KSLocalView

- (instancetype)initWithFrame:(CGRect)frame scale:(KSScale)scale mode:(KSContentMode)mode callType:(KSCallType)callType {
    if (self = [super initWithFrame:frame]) {
        self.callType = callType;
        [self updatePreviewWidth:frame.size.width height:frame.size.height scale:scale mode:mode];
    }
    return self;
}

-(void)setCallType:(KSCallType)callType {
    _callType = callType;
    if (_callType == KSCallTypeManyVideo || _callType == KSCallTypeSingleVideo) {
        [self createPreviewLayer];
    }
}

- (void)createPreviewLayer {
    if (_previewLayer) {
        return;
    }
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] init];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//填充模式
    _previewLayer = previewLayer;
    [self.layer addSublayer:previewLayer];
}

- (void)setLocalViewSession:(AVCaptureSession *)session {
    _previewLayer.session = session;
}

- (void)updatePreviewWidth:(CGFloat)width height:(CGFloat)height scale:(KSScale)scale mode:(KSContentMode)mode {
    if (_previewLayer == nil) {
        return;
    }
     _previewLayer.frame = [self ks_rectOfSuperFrame:self.frame width:width height:height scale:scale mode:mode];
}

@end
