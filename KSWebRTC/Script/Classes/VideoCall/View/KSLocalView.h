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

@interface KSLocalView : UIView

-(instancetype)initWithFrame:(CGRect)frame resizingMode:(KSResizingMode)resizingMode;
- (void)setLocalViewSession:(AVCaptureSession *)session;
- (void)updatePreviewWidth:(CGFloat)width height:(CGFloat)height resizingMode:(KSResizingMode)resizingMode;

@end
