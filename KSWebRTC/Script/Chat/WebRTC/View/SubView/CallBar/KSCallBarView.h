//
//  KSCallBarView.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//  静音/切换摄像头/挂断等菜单

#import "KSEventCallbackView.h"
#import "KSConfigure.h"
#import "KSDeviceSwitch.h"
@class KSCallBarView;
@protocol KSCallBarViewDataSource <NSObject>

-(KSDeviceSwitch *)deviceSwitchOfCallBarView:(KSCallBarView *)callBarView;
-(KSCallType)callTypeOfCallBarView:(KSCallBarView *)callBarView;

@end
@interface KSCallBarView : KSEventCallbackView
@property(nonatomic,weak)id<KSCallBarViewDataSource> dataSource;

- (void)initKits;
- (void)reloadBar;

@end
