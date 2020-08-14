//
//  KSLocalView.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/2.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSConfigure.h"
#import "KSMediaConnection.h"
#import "KSTileLayout.h"
@interface KSPreviewLayer : AVCaptureVideoPreviewLayer
@end

@interface KSLocalView : UIView
@property (nonatomic,weak  ) KSMediaConnection *connection;
@property (nonatomic,strong) KSTileLayout      *tileLayout;
@property (nonatomic,assign) BOOL              isDrag;

- (void)setSession:(AVCaptureSession *)session;

@end
