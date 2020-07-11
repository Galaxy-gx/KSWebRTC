//
//  KSMessage.m
//  KSWebRTC
//
//  Created by saeipi on 2020/7/10.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSMsg.h"
#import <MJExtension/MJExtension.h>
@implementation KSMsg

+ (KSMessageType)typeForMsg:(NSDictionary *)msg {
    NSString *janus = msg[@"janus"];
    if (!janus) {
        return KSMessageTypeUnknown;
    }
    if ([janus isEqualToString:@"create"]) {
        return KSMessageTypeCreate;
    }
    else if ([janus isEqualToString:@"success"]) {
        return KSMessageTypeSuccess;
    }
    else if ([janus isEqualToString:@"error"]) {
        return KSMessageTypeError;
    }
    else if ([janus isEqualToString:@"attach"]) {
        return KSMessageTypeAttach;
    }
    else if ([janus isEqualToString:@"message"]) {
        return KSMessageTypeMessage;
    }
    else if ([janus isEqualToString:@"ack"]) {
        return KSMessageTypeAck;
    }
    else if ([janus isEqualToString:@"event"]) {
        return KSMessageTypeEvent;
    }
    else if ([janus isEqualToString:@"trickle"]) {
        return KSMessageTypeTrickle;
    }
    else if ([janus isEqualToString:@"media"]) {
        return KSMessageTypeMedia;
    }
    else if ([janus isEqualToString:@"webrtcup"]) {
        return KSMessageTypeWebrtcup;
    }
    else if ([janus isEqualToString:@"keepalive"]) {
        return KSMessageTypeKeepalive;
    }
    else if ([janus isEqualToString:@"slowlink"]) {
        return KSMessageTypeSlowlink;
    }
    else if ([janus isEqualToString:@"hangup"]) {
        return KSMessageTypeHangup;
    }
    else if ([janus isEqualToString:@"detached"]) {
        return KSMessageTypeDetached;
    }
    return KSMessageTypeUnknown;
}

+ (KSMsg *)deserializeForMsg:(NSDictionary *)msg {
    KSMessageType type = [self typeForMsg:msg];
    KSMsg *obj = NULL;
    switch (type) {
        case KSMessageTypeSuccess:
        case KSMessageTypeError:
        case KSMessageTypeAck:
            obj = [KSSuccess mj_objectWithKeyValues:msg];
            obj.msgType = type;
            break;
        case KSMessageTypeEvent:
            obj = [KSEvent mj_objectWithKeyValues:msg];
            obj.msgType = type;
            break;
        case KSMessageTypeMedia:
            obj = [KSMedia mj_objectWithKeyValues:msg];
            obj.msgType = type;
            break;
        case KSMessageTypeWebrtcup:
            obj = [KSWebrtcup mj_objectWithKeyValues:msg];
            obj.msgType = type;
            break;
        default:
            break;
    }
    return obj;
    
    /*
     KSMsg *obj = NULL;
     NSString *janus = msg[@"janus"];
     if (!janus) {
     obj = [[KSMsg alloc] init];
     obj.msgType = KSMessageTypeUnknown;
     return obj;
     }
     
     if ([janus isEqualToString:@"create"]) {//Reuqest
     obj.msgType = KSMessageTypeCreate;
     }
     else if ([janus isEqualToString:@"success"]) {//ACK
     obj = [KSSuccess mj_objectWithKeyValues:msg];
     obj.msgType = KSMessageTypeSuccess;
     }
     else if ([janus isEqualToString:@"error"]) {//ACK
     obj = [KSSuccess mj_objectWithKeyValues:msg];
     obj.msgType = KSMessageTypeError;
     }
     else if ([janus isEqualToString:@"attach"]) {//Reuqest
     obj.msgType = KSMessageTypeAttach;
     }
     else if ([janus isEqualToString:@"message"]) {//Request
     obj.msgType = KSMessageTypeMessage;
     }
     else if ([janus isEqualToString:@"ack"]) {//ACK
     obj = [KSSuccess mj_objectWithKeyValues:msg];
     obj.msgType = KSMessageTypeAck;
     }
     else if ([janus isEqualToString:@"event"]) {//ACK
     obj = [KSEvent mj_objectWithKeyValues:msg];
     obj.msgType = KSMessageTypeEvent;
     }
     else if ([janus isEqualToString:@"trickle"]) {//Reuqest
     obj.msgType = KSMessageTypeTrickle;
     }
     else if ([janus isEqualToString:@"media"]) {//ACK
     obj = [KSMedia mj_objectWithKeyValues:msg];
     obj.msgType = KSMessageTypeMedia;
     }
     else if ([janus isEqualToString:@"webrtcup"]) {//ACK
     obj.msgType = KSMessageTypeWebrtcup;
     }
     else if ([janus isEqualToString:@"keepalive"]) {//Reuqest
     obj.msgType = KSMessageTypeKeepalive;
     }
     else if ([janus isEqualToString:@"slowlink"]) {
     obj.msgType = KSMessageTypeSlowlink;
     }
     else if ([janus isEqualToString:@"hangup"]) {
     obj.msgType = KSMessageTypeHangup;
     }
     else if ([janus isEqualToString:@"detached"]) {
     obj.msgType = KSMessageTypeDetached;
     }
     else{
     obj = [[KSMsg alloc] init];
     obj.msgType = KSMessageTypeUnknown;
     }
     return obj;
     */
}

@end

/*
 typedef NS_ENUM(NSInteger, KSMessageType) {
 create,//创建一个janus会话命令
 success,//一个命令的成功结果
 error,//一个命令的失败结果
 attach,//附加一个插件到janus会话命令
 message,//客户端发送的插件消息。message和event构成了应用协议
 ack,//一个命令的ack，因为不能直接返回结果，先回ack，后续的结果通过event返回
 event,//推送给客户端的异步事件，主要由插件发出，这些事件需要插件来自己定义
 trickle,//客户端发送的候选人，会传递给ICE句柄
 media,//音频、视频媒体的接收通知
 webrtcup,//ICE成功建立通道的通知
 keepalive,//客户端发送的心跳
 slowlink,//链路恶化通知
 hangup,//挂断通知
 detached,//插件从janus会话分离的通知
 unknown
 };
 */

@implementation KSMessageData
+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{@"ID":@"id",@"Description":@"description"};
}
+ (NSDictionary *)mj_objectClassInArray {
    return @{@"publishers" : @"KSPublishers"};
}
@end

@implementation KSSuccess
+ (NSDictionary *)mj_objectClassInArray {
    return @{@"data" : @"KSMessageData"};
}
@end

@implementation KSPlugindata
+ (NSDictionary *)mj_objectClassInArray {
    return @{@"data" : @"KSMessageData"};
}
@end
@implementation KSEvent
+ (NSDictionary *)mj_objectClassInArray {
    return @{@"plugindata" : @"KSPlugindata",@"jsep" : @"KSJsep"};
}
@end

@implementation KSTrickle
+ (NSDictionary *)mj_objectClassInArray {
    return @{@"candidate" : @"KSCandidate"};
}
@end

@implementation KSMedia
@end

@implementation KSWebrtcup
@end
