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

@property(nonatomic,weak)AVCaptureVideoPreviewLayer *previewLayer;

- (void)setLocalViewSession:(AVCaptureSession *)session;
- (void)setFrameWithSize:(CGSize)size resizingMode:(KSResizingMode)resizingMode;

@end
