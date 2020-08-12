//
//  KSMediaInfo.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/12.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>
#import "KSCallState.h"
#import "KSConfigure.h"

@interface KSMediaInfo : NSObject

@property (nonatomic, assign) BOOL              isLocal;
@property (nonatomic,assign ) KSAudioStateType  audioStateType;
@property (nonatomic,assign ) KSCallType        callType;
@property (nonatomic,assign ) KSIdentity        identity;
@property (nonatomic,copy   ) NSString          *name;

@end
