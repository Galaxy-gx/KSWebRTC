//
//  KSScreenMediaView.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/2.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSMediaView.h"
#import "KSProfileInfo.h"

@interface KSScreenMediaView : KSMediaView

@property (nonatomic,assign) BOOL isDrag;
@property (nonatomic,strong) KSProfileInfo *profileInfo;

- (void)hiddenProfileView;
- (void)displayAvatar;
@end
