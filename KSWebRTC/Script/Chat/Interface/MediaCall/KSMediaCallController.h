//
//  KSMediaCallController.h
//  KSWebRTC
//
//  Created by saeipi on 2020/9/15.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSSuperController.h"
#import "KSConfigure.h"
#import "KSAckMessage.h"
@interface KSMediaCallController : KSSuperController

/// 进入通话页面
/// @param type 通话类型
/// @param callState 通话状态
/// @param isCaller 是否创建呼叫（主叫）
/// @param peerId 对方id
/// @param target 跳转控制器
+ (void)callWithType:(KSCallType)type callState:(KSCallStateMaintenance)callState isCaller:(BOOL)isCaller peerId:(long long)peerId target:(UIViewController *)target;

@end
