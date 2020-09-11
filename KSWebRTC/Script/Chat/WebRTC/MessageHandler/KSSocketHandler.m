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
};

static NSString *const KMsgTypeIceCandidate       = @"IceCandidate";
static NSString *const KMsgTypeSessionDescription = @"SessionDescription";
static NSString *const KMsgTypeSessionAttachReq   = @"KMsgTypeSessionAttachReq";
static NSString *const KMsgTypeSessionAttachAck   = @"KMsgTypeSessionAttachAck";
static NSString *const KMsgTypeSessionStart       = @"KMsgTypeSessionStart";

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
    
    if ([dict[@"type"] isEqualToString:KMsgTypeIceCandidate]) {//本地
        KSMediaConnection *mc           = [self.delegate localPeerConnectionOfMessageHandler:self];
        [mc addIceCandidate:dict[@"body"]];
    }
    else if ([dict[@"type"] isEqualToString:KMsgTypeSessionDescription]) {
        if ([dict[@"body"][@"type"] isEqualToString:@"offer"]) {//远程
            KSMediaConnection *mc = [self.delegate remotePeerConnectionOfMessageHandler:self handleId:[NSNumber numberWithInt:[dict[@"user_id"] intValue]] sdp:dict[@"body"][@"sdp"]];
            [mc setRemoteDescriptionWithJsep:dict[@"body"]];
            __weak typeof(self) weakSelf = self;
            [mc createAnswerWithCompletionHandler:^(RTCSessionDescription *sdp, NSError *error) {
                NSString *type = [RTCSessionDescription stringForType:sdp.type];
                NSMutableDictionary *jseps =[NSMutableDictionary dictionary];
                jseps[@"type"] = type;
                jseps[@"sdp"]  = [sdp sdp];
                [weakSelf sendMessage:jseps type:KMsgTypeSessionDescription relay:KSRelayTypeAssigner target:dict[@"id"]];
            }];
        }
        else if ([dict[@"body"][@"type"] isEqualToString:@"answer"]) {//本地
            KSMediaConnection *mc = [self.delegate localPeerConnectionOfMessageHandler:self];
            [mc setRemoteDescriptionWithJsep:dict[@"body"]];
            //[self sendMessage:nil type:KMsgTypeSessionAttachReq relay:KSRelayTypeAssigner target:dict[@"id"]];
        }
    }
    else if ([dict[@"type"] isEqualToString:KMsgTypeSessionAttachReq]){
        //KSMediaConnection *mc = [self.delegate localPeerConnectionOfMessageHandler:self];
        //[self sendMessage:[mc localDescription] type:KMsgTypeSessionAttachAck relay:KSRelayTypeAssigner target:dict[@"id"]];
    }
    else if ([dict[@"type"] isEqualToString:KMsgTypeSessionAttachAck]){
        //KSMediaConnection *mc = [self.delegate localPeerConnectionOfMessageHandler:self];
        //[mc setLocalDescriptionWithJsep:dict[@"body"]];
        //[mc setRemoteDescriptionWithJsep:dict[@"body"]];
        //KSMediaConnection *mc = [self.delegate remotePeerConnectionOfMessageHandler:self handleId:[NSNumber numberWithInt:[dict[@"user_id"] intValue]] sdp:dict[@"body"][@"sdp"]];
        //[mc setRemoteDescriptionWithJsep:dict[@"body"]];
    }
}

- (void)trickleCandidate:(NSMutableDictionary *)candidate {
    [self sendMessage:candidate type:KMsgTypeIceCandidate relay:KSRelayTypeAll target:nil];
}

//KSWebSocketDelegate
/**
 连接成功
 */
- (void)socketDidOpen:(KSWebSocket *)socket {
    self.isConnect = YES;
    KSMediaConnection *mc             = [self.delegate localPeerConnectionOfMessageHandler:self];
    __weak typeof(self) weakSelf      = self;
    [mc createOfferWithCompletionHandler:^(RTCSessionDescription *sdp, NSError *error) {
        NSString *type = [RTCSessionDescription stringForType:sdp.type];
        NSMutableDictionary *jsep =[NSMutableDictionary dictionary];
        jsep[@"type"]      = type;
        jsep[@"sdp"]       = [sdp sdp];
        [weakSelf sendMessage:jsep type:KMsgTypeSessionDescription relay:KSRelayTypeAll target:nil];
    }];
}

-(void)sendMessage:(NSMutableDictionary *)message type:(NSString *)type relay:(KSRelayType)relay target:(NSString *)target {
    NSMutableDictionary *msg = [NSMutableDictionary dictionary];
    msg[@"type"]             = type;
    msg[@"relay"]            = @(relay);
    msg[@"user_id"]          = @([KSUserInfo myID]);
    if (message) {
        msg[@"body"]         = message;
    }
    if (target) {
        msg[@"target"]       = target;
    }
    [self.socket sendMessage:msg];
}

@end

