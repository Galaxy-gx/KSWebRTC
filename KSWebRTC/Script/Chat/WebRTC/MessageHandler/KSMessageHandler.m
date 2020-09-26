//
//  KSMessageHandler.m
//  KSWebRTC
//
//  Created by saeipi on 2020/9/26.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSMessageHandler.h"
typedef NS_ENUM(NSInteger, KSRelayType) {
    KSRelayBroadcast    = 1,//广播（自己除外）
    KSRelayTypeAssigner = 2,//指定
    KSRelayAll          = 3,//全部
    KSRelayTypeNone     = 4,//给服务器的消息
};

@interface KSMessageHandler()<KSWebSocketDelegate>
@end
@implementation KSMessageHandler

- (instancetype)init {
    self = [super init];
    if (self) {
        self.socket          = [[KSWebSocket alloc] init];
        self.socket.delegate = self;
    }
    return self;
}

- (void)analysisMsg:(id)message {
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:message options:NSJSONReadingMutableContainers error:&error];
    if (!dict) {
        return;
    }
    NSLog(@"|============|\nReceived:\n%@\n|============|",dict);
    KSLogicMsg *msg = [KSLogicMsg deserializeForMsg:dict];
    if (msg == nil) {
        return;
    }
    [self responseCallbackOfMessage:msg];
}

- (void)responseCallbackOfMessage:(KSLogicMsg *)message {
    if ([self.delegate respondsToSelector:@selector(messageHandler:didReceivedMessage:)]) {
        [self.delegate messageHandler:self didReceivedMessage:message];
    }
}
- (void)connectServer:(NSString *)url {
    [self.socket configureServer:url isAutoConnect:true];
    [self.socket startConnect];
}
//KSWebSocketDelegate
/**
 连接成功
 */
- (void)socketDidOpen:(KSWebSocket *)socket {
    NSLog(@"连接socket服务器成功");
    _socket.configure.isSession = true;
    [self registert];
}

/**
 出现错误/连接失败时调用[如果设置自动重连，则不会调用]
 */
- (void)socketDidFail:(KSWebSocket *)socket {
    NSLog(@"socket发生错误");
}

/**
 收到消息
 */
- (void)socket:(KSWebSocket *)socket didReceivedMessage:(id)message {
    [self analysisMsg:message];
}
/**
 异常断开,且重连失败
 */
- (void)socketReconnectionFailure:(KSWebSocket *)socket {
    
}
/**
 服务端断开
 */
- (void)socketDidClose:(KSWebSocket *)socket {
    
}
/**
 网络变化回调
 */
-(void)socket:(KSWebSocket *)socket isReachable:(BOOL)isReachable {
    
}

- (void)close {
    
}

#pragma mark - 消息发送
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

- (void)registert {
    NSMutableDictionary *msg = [NSMutableDictionary dictionary];
    msg[@"type"]             = @(KSMsgTypeRegistert);
    msg[@"relay"]            = @(KSRelayAll);
    msg[@"user_id"]          = @(self.user.ID);
    msg[@"user_name"]        = self.user.name;
    msg[@"register"]         = @"register";
    [self.socket sendMessage:msg];
}

- (void)callToUserId:(long long)userId room:(int)room {
    NSMutableDictionary *message = [NSMutableDictionary dictionary];
    message[@"room"]             = @(room);
    KSRelayType relayType        = KSRelayTypeAssigner;
    [self sendMessage:message type:KSMsgTypeCall relay:relayType target:userId];
}

- (void)answerToUserId:(long long)userId {
    NSMutableDictionary *message = [NSMutableDictionary dictionary];
    KSRelayType relayType        = KSRelayTypeAssigner;
    [self sendMessage:message type:KSMsgTypeCall relay:relayType target:userId];
}

#pragma mark - Get
-(KSCallType)myType {
    return [self.delegate callTypeOfMessageHandler:self];
}

@end
