//
//  KSMessage.m
//  KSWebRTC
//
//  Created by saeipi on 2020/7/10.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSMsg.h"
#import "MJExtension.h"
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
            break;
        case KSMessageTypeEvent:
            obj = [KSEvent mj_objectWithKeyValues:msg];
            break;
        case KSMessageTypeMedia:
            obj = [KSMedia mj_objectWithKeyValues:msg];
            break;
        case KSMessageTypeWebrtcup:
            obj = [KSWebrtcup mj_objectWithKeyValues:msg];
            break;
        case KSMessageTypeDetached:
        case KSMessageTypeHangup:
            obj = [KSDetached mj_objectWithKeyValues:msg];
            break;
        default:
            return NULL;
            break;
    }
    obj.msgType = type;
    return obj;
}

@end

@implementation KSMessageData
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"ID":@"id",@"Description":@"description"};
}
+ (NSDictionary *)mj_objectClassInArray {
    return @{@"publishers" : @"KSPublishers"};
}
@end

@implementation KSPublishers
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"ID":@"id"};
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    KSPublishers *publisher = [[[self class] alloc] init];
    publisher.ID = self.ID;
    publisher.display = self.display;
    publisher.audio_codec = self.audio_codec;
    publisher.video_codec = self.video_codec;
    publisher.talking = self.talking;
    publisher.privateId = self.privateId;
    return publisher;
}

@end

@implementation KSSuccess
+ (NSDictionary *)mj_objectClassInArray {
    return @{@"data" : NSStringFromClass([KSMessageData class])};
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

@implementation KSDetached
@end

@implementation KSCall
@end

@implementation KSAnswer
@end
