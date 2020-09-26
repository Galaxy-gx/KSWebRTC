//
//  KSLogicMessage.h
//  KSWebRTC
//
//  Created by saeipi on 2020/9/26.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSConfigure.h"
typedef NS_ENUM(NSInteger, KSMsgType) {
    KSMsgTypeRegistert = 1,
    KSMsgTypeCall      = 2,
    KSMsgTypeAnswer    = 3,
};

@interface KSLogicMsg : NSObject
@property (nonatomic,assign) KSMsgType  type;
@property (nonatomic,copy  ) NSString   *name;
@property (nonatomic,assign) long long  ID;
@property (nonatomic,assign) KSCallType callType;

+ (KSLogicMsg *)deserializeForMsg:(NSDictionary *)msg;
@end

@interface KSRegistert : KSLogicMsg
@property(nonatomic,strong)NSMutableArray *users;
@end

@interface KSRoom : NSObject
@property (nonatomic,assign) int  room;
@end

@interface KSCall : KSLogicMsg
@property(nonatomic,strong) KSRoom *body;
@end

@interface KSAnswer : KSLogicMsg

@end
