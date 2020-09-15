//
//  KSSocketHandler.m
//  KSWebRTC
//
//  Created by saeipi on 2020/9/11.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSSocketHandler.h"
#import "KSWebRTCManager.h"
#import "NSDictionary+Category.h"
#import "NSString+Category.h"

typedef NS_ENUM(NSInteger, KSRelayType) {
    KSRelayTypeAll      = 1,
    KSRelayTypeAssigner = 2,
    KSRelayTypeNone     = 3,
};

typedef NS_ENUM(NSInteger, KSMsgType) {
    KSMsgTypeCall         = 1,
    KSMsgTypeAnswer       = 2,
    KSMsgTypeIceCandidate = 3,
    KSMsgTypeOfferJsep    = 4,
    KSMsgTypeAnswerJsep   = 5,
};

@interface KSSocketHandler()
@end

@implementation KSSocketHandler

- (void)analysisMsg:(id)message {
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:message options:NSJSONReadingMutableContainers error:&error];
    if (!dict) {
        return;
    }
    
    NSLog(@"|============|\nReceived:\n%@\n|============|",dict);
    KSMsgType msgType = [dict[@"type"] intValue];
    switch (msgType) {
        case KSMsgTypeCall:
        {
            if ([self.delegate respondsToSelector:@selector(messageHandler:call:)]) {
                KSCall *call  = [[KSCall alloc] init];
                call.ID       = [dict[@"user_id"] longLongValue];
                call.name     = dict[@"user_name"];
                call.callType = [dict[@"call_type"] intValue];
                [self.delegate messageHandler:self call:call];
            }
        }
            break;
        case KSMsgTypeAnswer:
        {
            if ([self.delegate respondsToSelector:@selector(messageHandler:answer:)]) {
                KSAnswer *answer = [[KSAnswer alloc] init];
                answer.ID        = [dict[@"user_id"] longLongValue];
                answer.name      = dict[@"user_name"];
                answer.callType  = [dict[@"call_type"] intValue];
                [self.delegate messageHandler:self answer:answer];
            }
        }
            break;
        case KSMsgTypeIceCandidate:
        {
            KSMediaConnection *mc = [self.delegate localPeerConnectionOfMessageHandler:self];
            [mc addIceCandidate:dict[@"body"]];
        }
            break;
        case KSMsgTypeOfferJsep://远程
        {
            KSMediaConnection *mc = [self.delegate remotePeerConnectionOfMessageHandler:self handleId:[NSNumber numberWithInt:[dict[@"user_id"] intValue]] sdp:dict[@"body"][@"sdp"]];
            [mc setRemoteDescriptionWithJsep:dict[@"body"]];
            
            __weak typeof(self) weakSelf = self;
            [mc createAnswerWithCompletionHandler:^(RTCSessionDescription *sdp, NSError *error) {
                NSString *type = [RTCSessionDescription stringForType:sdp.type];
                NSMutableDictionary *jseps =[NSMutableDictionary dictionary];
                jseps[@"type"] = type;
                jseps[@"sdp"]  = [sdp sdp];
                [weakSelf sendMessage:jseps type:KSMsgTypeAnswerJsep relay:KSRelayTypeAssigner target:[dict[@"user_id"] longLongValue]];
            }];
        }
            break;
        case KSMsgTypeAnswerJsep://本地
        {
            KSMediaConnection *mc = [self.delegate localPeerConnectionOfMessageHandler:self];
            [mc setRemoteDescriptionWithJsep:dict[@"body"]];
        }
            break;
        default:
            break;
    }
}

- (void)socketDidOpen:(KSWebSocket *)socket {
    NSMutableDictionary *msg = [NSMutableDictionary dictionary];
    msg[@"user_id"]          = @(self.user.ID);
    msg[@"register"]         = @"register";
    msg[@"relay"]            = @(KSRelayTypeNone);
    [self.socket sendMessage:msg];
}

-(void)sendMessage:(NSMutableDictionary *)message type:(KSMsgType)type relay:(KSRelayType)relay target:(long long)target {
    NSMutableDictionary *msg = [NSMutableDictionary dictionary];
    msg[@"type"]             = @(type);
    msg[@"relay"]            = @(relay);
    msg[@"user_id"]          = @(self.user.ID);
    msg[@"user_name"]        = self.user.name;
    msg[@"call_type"]        = @(self.myType);
    if (message) {
        msg[@"body"]         = message;
    }
    if (target != 0) {
        msg[@"target"]       = @(target);
    }
    [self.socket sendMessage:msg];
}

- (void)trickleCandidate:(NSMutableDictionary *)candidate {
    [self sendMessage:candidate type:KSMsgTypeIceCandidate relay:KSRelayTypeAll target:-1];
}

//新的逻辑
- (void)callToUserid:(long long)userid {
    NSMutableDictionary *message = [NSMutableDictionary dictionary];
    KSRelayType relayType        = KSRelayTypeAll;
    if (userid != 0) {
        relayType                =  KSRelayTypeAssigner;
    }
    [self sendMessage:message type:KSMsgTypeCall relay:relayType target:userid];
}

- (void)answerToUserid:(long long)userid {
    KSMediaConnection *mc        = [self.delegate localPeerConnectionOfMessageHandler:self];
    __weak typeof(self) weakSelf = self;
    [mc createOfferWithCompletionHandler:^(RTCSessionDescription *sdp, NSError *error) {
        NSString *type = [RTCSessionDescription stringForType:sdp.type];
        NSMutableDictionary *jsep =[NSMutableDictionary dictionary];
        jsep[@"type"]  = type;
        jsep[@"sdp"]   = [sdp sdp];
        [weakSelf sendMessage:jsep type:KSMsgTypeOfferJsep relay:KSRelayTypeAssigner target:userid];
    }];
}

@end

