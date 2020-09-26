//
//  KSLogicMessage.m
//  KSWebRTC
//
//  Created by saeipi on 2020/9/26.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSLogicMsg.h"
#import "MJExtension.h"
@implementation KSLogicMsg

+ (KSLogicMsg *)deserializeForMsg:(NSDictionary *)msg {
    KSMsgType msgType = [msg[@"type"] intValue];
    switch (msgType) {
        case KSMsgTypeRegistert:
        {
            KSRegistert *obj = [KSRegistert mj_objectWithKeyValues:msg];
            return obj;
        }
            break;
        case KSMsgTypeCall:
        {
            KSCall *obj = [KSCall mj_objectWithKeyValues:msg];
            return obj;
        }
            break;
        case KSMsgTypeAnswer:
        {
            KSAnswer *obj = [KSAnswer mj_objectWithKeyValues:msg];
            return obj;
        }
            break;
        default:
            break;
    }
    return nil;
}

@end

@implementation KSRegistert
+ (NSDictionary *)mj_objectClassInArray {
    return @{@"users" : @"KSUserInfo"};
}

@end

@implementation KSRoom
@end

@implementation KSCall
+ (NSDictionary *)mj_objectClassInArray {
    return @{@"body" : @"KSRoom"};
}
@end

@implementation KSAnswer
@end
