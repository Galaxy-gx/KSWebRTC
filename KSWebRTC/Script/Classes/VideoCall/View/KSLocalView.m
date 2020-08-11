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


@interface KSLocalView()

@end

@implementation KSLocalView

- (instancetype)initWithFrame:(CGRect)frame scale:(KSScale)scale mode:(KSContentMode)mode callType:(KSCallType)callType {
    if (self = [super initWithFrame:frame]) {
        self.scale    = scale;
        self.mode     = mode;
        self.callType = callType;
    }
    return self;
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updatePreviewWidth:frame.size.width height:frame.size.height scale:_scale mode:_mode];
}

-(void)setCallType:(KSCallType)callType {
    _callType = callType;
    if (_callType == KSCallTypeManyVideo || _callType == KSCallTypeSingleVideo) {
        [self createPreviewLayer];
        [self updatePreviewWidth:self.bounds.size.width height:self.bounds.size.height scale:_scale mode:_mode];
    }
}

- (void)createPreviewLayer {
    if (_previewLayer) {
        return;
    }
    KSPreviewLayer *previewLayer = [[KSPreviewLayer alloc] init];
    previewLayer.videoGravity    = AVLayerVideoGravityResizeAspectFill;//填充模式
    _previewLayer                = previewLayer;
    [self.layer addSublayer:previewLayer];
}

- (void)setLocalViewSession:(AVCaptureSession *)session {
    _previewLayer.session = session;
    _previewLayer.hidden  = session == nil ? YES : NO;
}

- (void)updatePreviewWidth:(CGFloat)width height:(CGFloat)height scale:(KSScale)scale mode:(KSContentMode)mode {
    if (_previewLayer == nil) {
        return;
    }
     _previewLayer.frame = [self ks_rectOfSuperFrame:self.frame width:width height:height scale:scale mode:mode];
}

@end
