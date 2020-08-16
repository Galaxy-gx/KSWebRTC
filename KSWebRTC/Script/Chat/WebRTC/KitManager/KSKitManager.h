//
//  KSKitManager.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/14.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSCallView.h"

@interface KSKitManager : UIView

@property (nonatomic, weak) KSCallView *callView;

- (instancetype)initWithFrame:(CGRect)frame callType:(KSCallType)callType tileLayout:(KSTileLayout *)tileLayout callback:(KSEventCallback)callback profile:(KSProfileConfigure *)profile;

@end

