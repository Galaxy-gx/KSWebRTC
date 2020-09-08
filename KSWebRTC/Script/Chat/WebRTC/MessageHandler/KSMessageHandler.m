//
//  KSMessageHandler.m
//  KSWebRTC
//
//  Created by saeipi on 2020/7/10.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSMessageHandler.h"
#import "KSWebRTCManager.h"
#import "NSDictionary+Category.h"
#import "NSString+Category.h"

static NSString *const KMsgTypeIceCandidate       = @"IceCandidate";
static NSString *const KMsgTypeSessionDescription = @"SessionDescription";
static NSString *const KMsgTypeSessionStart       = @"KMsgTypeSessionStart";

@interface KSMessageHandler()<KSWebSocketDelegate>
@property (nonatomic,strong ) KSWebSocket    *socket;
@property (nonatomic,assign ) BOOL           isConnect;
@end

@implementation KSMessageHandler

-(instancetype)init {
    if(self = [super init]) {
        [self initSocket];
    }
    return self;
}

- (void)initSocket {
    self.socket          = [[KSWebSocket alloc] init];
    self.socket.delegate = self;
}

- (void)connectServer:(NSString *)url {
    if (_isConnect) {
        return;
    }
    [self.socket configureServer:url isAutoConnect:true];
    [self.socket startConnect];
}

- (void)startFlag {
    if (!_isConnect) {
        return;
    }
    NSMutableDictionary *sendMessage = [NSMutableDictionary dictionary];
    sendMessage[@"type"] = KMsgTypeSessionStart;
    [_socket sendMessage:sendMessage];
}

// 发送候选者
- (void)trickleCandidate:(NSMutableDictionary *)candidate {
    if (!_isConnect) {
        return;
    }
    NSMutableDictionary *sendMessage = [NSMutableDictionary dictionary];
    sendMessage[@"type"]             = KMsgTypeIceCandidate;
    sendMessage[@"payload"]          = candidate;
    [_socket sendMessage:sendMessage];
}

// 发送消息通用方法
- (void)sendPayload:(NSDictionary *)payload {
    if (!_isConnect) {
        return;
    }
    NSMutableDictionary *sendMessage = [NSMutableDictionary dictionary];
    sendMessage[@"type"] = KMsgTypeSessionDescription;
    if (payload != NULL) {
        sendMessage[@"payload"] = payload;
    }
    [_socket sendMessage:sendMessage];
}

- (void)analysisMsg:(id)message {
    NSData *msg = [NSData data];
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:msg
                                                         options:NSJSONReadingMutableContainers
                                                           error:&error];
    if (!dict) {
        return;
    }
    NSLog(@"|============|\nReceived: %@\n|============|",dict);
    if ([dict[@"type"] isEqualToString:KMsgTypeIceCandidate]) {
        [self.delegate messageHandler:self addIceCandidate:dict[@"payload"]];
    }
    else if ([dict[@"type"] isEqualToString:KMsgTypeSessionDescription]) {
        if ([dict[@"payload"][@"type"] isEqualToString:@"offer"]) {
            [self.delegate messageHandler:self didReceiveOffer:dict[@"payload"]];
        }
        else if ([dict[@"payload"][@"type"] isEqualToString:@"answer"]) {
            [self.delegate messageHandler:self didReceiveAnswer:dict[@"payload"]];
        }
    }
    else if ([dict[@"type"] isEqualToString:KMsgTypeSessionStart]) {
        [KSWebRTCManager shared].isRemote = YES;
        [[KSWebRTCManager shared] sendOffer];
    }
}

- (void)socketDidOpen:(KSWebSocket *)socket {
    NSLog(@"测试socket连接成功");
    _isConnect = YES;
    //[self startFlag];
    if ([self.delegate respondsToSelector:@selector(messageHandler:socketDidOpen:)]) {
        [self.delegate messageHandler:self socketDidOpen:socket];
    }
}

- (void)socketDidFail:(KSWebSocket *)socket {
    _isConnect = NO;
    if ([self.delegate respondsToSelector:@selector(messageHandler:socketDidFail:)]) {
        [self.delegate messageHandler:self socketDidFail:socket];
    }
}

- (void)socket:(KSWebSocket *)socket didReceivedMessage:(id)message {
    [self analysisMsg:message];
}

#pragma mark - Telegraph

///01呼叫
- (void)callToPeerId:(int)peerId type:(KSCallType)type {
    _peerId                  = [NSString stringWithFormat:@"%d",peerId];
    [self newCallWithOffer:@"" callType:type];
}

- (void)requestWithType:(KSRequestType)type respond:(id)respond rpcError:(id)rpcError isRespond:(BOOL)isRespond {
    if (rpcError) {
        KSRequestError *er = [[KSRequestError alloc] init];
        er.type            = type;
        er.isRespond       = NO;
        er.errorInfo       = [NSString stringWithFormat:@"%@",rpcError];
        [self requestError:er];
        return;
    }
}

- (void)newCallWithOffer:(NSString *)offer callType:(KSCallType)callType {

}

///ice更新 KSWebRTCManager调用
- (void)sendCandidate:(NSDictionary *)candidate {
    NSLog(@"|-----------| sendCandidate: %@ |-----------|",candidate);
}

///接听
- (void)answoerOfCallType:(KSCallType)callType {

}

/// 响铃
- (void)ringed {

}

///开始通话
- (void)start {

}

- (void)sendMessage:(NSMutableDictionary *)message type:(NSString *)type {

}

- (void)sendSafetyMessage:(NSMutableDictionary *)message type:(NSString *)type {

}

- (void)sendOfferPayload:(NSDictionary *)payload {
    [self sendOffer:payload];
}

///发送Offser
- (void)sendOffer:(NSDictionary *)offer {

}

- (void)sendAnswerPayload:(NSDictionary *)payload {
    [self sendAnswer:payload];
}
- (void)sendAnswer:(NSDictionary *)answer {

}

///离开
- (void)leave {

}

///获取丢失的 消息
- (void)getRTCInfo {

}

///加入聊天
- (void)joinWithOffer:(NSString *)offer {
}

-(void)requestError:(KSRequestError *)error {
    if ([self.delegate respondsToSelector:@selector(messageHandler:requestError:)]) {
        [self.delegate messageHandler:self requestError:error];
    }
}

@end
