//
//  KSVideoPreviewView.h
//  KSWebRTC
//
//  Created by saeipi on 2020/7/24.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface KSVideoPreviewView : UIView

@property(nonatomic,weak)AVCaptureVideoPreviewLayer *previewLayer;

@end
