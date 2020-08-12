//
//  KSLocalView.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/2.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "KSConfigure.h"

@interface KSPreviewLayer : AVCaptureVideoPreviewLayer

@end

@interface KSLocalView : UIView

@property (nonatomic,assign) BOOL          isDrag;
@property (nonatomic,assign) KSScale       scale;
@property (nonatomic,assign) KSContentMode mode;
@property (nonatomic,assign) KSCallType    callType;
@property (nonatomic,weak  ) KSPreviewLayer *previewLayer;

- (instancetype)initWithFrame:(CGRect)frame scale:(KSScale)scale mode:(KSContentMode)mode callType:(KSCallType)callType;
- (void)setLocalViewSession:(AVCaptureSession *)session;
- (void)updatePreviewWidth:(CGFloat)width height:(CGFloat)height scale:(KSScale)scale mode:(KSContentMode)mode;

@end
