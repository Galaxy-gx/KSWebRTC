//
//  KSLocalView.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/2.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSVideoView.h"

@interface KSLocalView : KSVideoView

@property (nonatomic,assign) BOOL isDrag;

- (void)createVideoView;

@end
