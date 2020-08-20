//
//  KSMessageHandler.m
//  KSWebRTC
//
//  Created by saeipi on 2020/7/10.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSMessageHandler.h"

@interface KSMessageHandler()<KSWebSocketDelegate>

@property (nonatomic,strong) KSWebSocket*socket;

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
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:message
                                                         options:NSJSONReadingMutableContainers
                                                           error:&error];
    if (!dict) {
        return;
    }
    NSLog(@"|============|\nReceived: %@\n|============|",dict);
    if ([dict[@"type"] isEqualToString:@"IceCandidate"]) {
        [[self localConnection] addIceCandidate:dict[@"payload"]];
    }
    else if ([dict[@"type"] isEqualToString:@"SessionDescription"]) {
        if ([dict[@"payload"][@"type"] isEqualToString:@"offer"]) {
            [self subscriberHandlerRemoteJsep:dict[@"payload"]];
        }
        else if ([dict[@"payload"][@"type"] isEqualToString:@"answer"]) {
            [self onPublisherRemoteJsep:dict[@"payload"]];
        }
    }
}

- (void)connectServer:(NSString *)url {
    [self.socket configureServer:url isAutoConnect:true];
    [self.socket startConnect];
}

//Send
// 创建会话
- (void)createSession {
}

- (void)sendOffer {
    [self configureRoom];
}

- (void)requestHangup {
}

- (void)configureRoom {
    KSMediaConnection *mc             = [self localConnection];
    __weak KSMessageHandler *weakSelf = self;
    [mc createOfferWithCompletionHandler:^(RTCSessionDescription *sdp, NSError *error) {
        NSString *type = [RTCSessionDescription stringForType:sdp.type];
        NSMutableDictionary *jsep =[NSMutableDictionary dictionary];
        jsep[@"type"]  = type;
        jsep[@"sdp"]   = [sdp sdp];
        [weakSelf sendPayload:jsep];
    }];
}

// 观察者收到远端offer后，发送anwser
- (void)subscriberHandlerRemoteJsep:(NSDictionary *)jsep {
    KSMediaConnection *mc = [self localConnection];
    [mc setRemoteDescriptionWithJsep:jsep];
    
    __weak KSMessageHandler *weakSelf = self;
    [mc createAnswerWithCompletionHandler:^(RTCSessionDescription *sdp, NSError *error) {
        NSString *type = [RTCSessionDescription stringForType:sdp.type];
        NSMutableDictionary *jsep =[NSMutableDictionary dictionary];
        jsep[@"type"]  = type;
        jsep[@"sdp"]   = [sdp sdp];
        [weakSelf sendPayload:jsep];
    }];
}

// 发布者收到远端媒体信息后的回调 answer
- (void)onPublisherRemoteJsep:(NSDictionary *)jsep {
    KSMediaConnection *mc = [self localConnection];
    if (mc) {
        [mc setRemoteDescriptionWithJsep:jsep];
    }
}

// 发送候选者
- (void)trickleCandidate:(NSNumber *)handleId candidate:(NSMutableDictionary *)candidate {
    NSMutableDictionary *sendMessage = [NSMutableDictionary dictionary];
    sendMessage[@"type"]             = @"IceCandidate";
    sendMessage[@"payload"]          = candidate;
    [_socket sendMessage:sendMessage];
}

// 发送消息通用方法
- (void)sendPayload:(NSDictionary *)payload {
    NSMutableDictionary *sendMessage = [NSMutableDictionary dictionary];
    sendMessage[@"type"] = @"SessionDescription";
    if (payload != NULL) {
        sendMessage[@"payload"] = payload;
    }
    [_socket sendMessage:sendMessage];
}

// 媒体连接
-(KSMediaConnection *)localConnection {
    KSMediaConnection *mc = nil;
    if ([self.delegate respondsToSelector:@selector(messageHandlerOfLocalConnection)]) {
        mc = [self.delegate messageHandlerOfLocalConnection];
    }
    return mc;
}

- (void)close {
    [_socket activeClose];
    _socket = nil;
}

//KSWebSocketDelegate
/**
 连接成功
 */
- (void)socketDidOpen:(KSWebSocket *)socket {
    if ([self.delegate respondsToSelector:@selector(messageHandler:socketDidOpen:)]) {
        [self.delegate messageHandler:self socketDidOpen:socket];
    }
}

/**
 出现错误/连接失败时调用[如果设置自动重连，则不会调用]
 */
- (void)socketDidFail:(KSWebSocket *)socket {
    if ([self.delegate respondsToSelector:@selector(messageHandler:socketDidFail:)]) {
        [self.delegate messageHandler:self socketDidFail:socket];
    }
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

@end
