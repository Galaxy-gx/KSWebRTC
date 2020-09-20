//
//  KSMessageHandler.m
//  KSWebRTC
//
//  Created by saeipi on 2020/7/10.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSMessageHandler.h"
#import "KSMsg.h"
#import "KSWebSocket.h"
#import "KSMediaConnection.h"
#import "NSString+Category.h"
#import "RTCSessionDescription+Category.h"
static int const KSRandomLength = 12;

@interface KSMessageHandler()<KSWebSocketDelegate>
@property (nonatomic, strong) NSNumber            *sessionId;
@property (nonatomic, copy  ) NSString            *opaqueId;
@property (nonatomic, assign) int                 roomMumber;
@property (nonatomic, strong) NSNumber            *myHandleId;
@property (nonatomic, strong) NSMutableDictionary *msgs;
@property (nonatomic, strong) NSMutableDictionary *subscribers;
@end
@implementation KSMessageHandler

- (instancetype)init {
    self = [super init];
    if (self) {
        self.socket          = [[KSWebSocket alloc] init];
        self.socket.delegate = self;
        self.opaqueId        = [NSString stringWithFormat:@"videoroom-%@", [NSString ks_randomForLength:KSRandomLength]];
        self.msgs            = [NSMutableDictionary dictionary];
        self.subscribers     = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - 消息处理
- (void)messageSuccess:(KSSuccess *)success {
    KSActionType actionType = [_msgs[success.transaction] intValue];
    switch (actionType) {
        case KSActionTypeCreateSession:
            //01 ACK 创建会话
            _sessionId                  = success.data.ID;
            _socket.configure.sessionId = _sessionId;
            _socket.configure.isSession = true;
            //WebRTC:02
            [self pluginBinding:KSActionTypePluginBinding transaction:[NSString ks_randomForLength:KSRandomLength]];
            break;
        case KSActionTypePluginBinding:
            //02 ACK 插件绑定(等待用户加入房间)
            _myHandleId = success.data.ID;
            break;
        case KSActionTypeJoinRoom:
            //WebRTC:04
            //创建本地PeerConnection
            [self configureRoom:_myHandleId];
            break;
        case KSActionTypeConfigureRoom:
            
            break;
        case KSActionTypePluginBindingSubscriber:
        {
            KSPublishers *member = _subscribers[success.transaction];
            if (!member) {
                return;
            }
            //WebRTC:06
            NSMutableDictionary *body = [NSMutableDictionary dictionary];
            body[@"request"]          = @"join";
            body[@"room"]             = @(_roomMumber);
            body[@"ptype"]            = @"subscriber";
            body[@"feed"]             = member.ID;
            if (member.privateId) {
                body[@"private_id"] = member.privateId;
            }
            [self sendMessage:body jsep:NULL handleId:success.data.ID actionType:KSActionTypeSubscriber];
        }
            break;
        case KSActionTypeSubscriber:
            
            break;
            
        default:
            break;
    }
}

- (void)messageEvent:(KSEvent *)event {
    if (event.plugindata.data.publishers.count > 0) {//videoroom = joined:已经加入的用户//event:有新的加入
        for (KSPublishers *item in event.plugindata.data.publishers) {
            if (event.plugindata.data.private_id) {
                item.privateId = event.plugindata.data.private_id;
            }
            NSString *transaction = [NSString ks_randomForLength:KSRandomLength];
            self.subscribers[transaction] = [item copy];
            
            //WebRTC:05
            [self pluginBinding:KSActionTypePluginBindingSubscriber transaction:transaction];
        }
    } else if (event.jsep) {
        if ([event.jsep[@"type"] isEqualToString:@"offer"]) {
            //WebRTC:07
            [self subscriberHandlerRemoteJsep:event.sender dict:event.jsep];
        }
        else if ([event.jsep[@"type"] isEqualToString:@"answer"]) {
            //WebRTC:08
            [self onPublisherRemoteJsep:_myHandleId dict:event.jsep];
        }
    }
}

- (void)messageDetached:(KSDetached *)detached {
    
}

- (void)analysisMsg:(id)message {
    NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&error];
    if (!dict) {
        return;
    }
    NSLog(@"Received: %@",message);
    KSMsg *msg = [KSMsg deserializeForMsg:dict];
    if (!msg) {
        return;
    }
    switch (msg.msgType) {
        case KSMessageTypeSuccess:
        case KSMessageTypeAck:
            [self messageSuccess:(KSSuccess *)msg];
            break;
        case KSMessageTypeError:
            break;
        case KSMessageTypeEvent:
            [self messageEvent:(KSEvent *)msg];
            break;
        case KSMessageTypeMedia:
            
            break;
        case KSMessageTypeWebrtcup:
            
            break;
        case KSMessageTypeDetached:
        case KSMessageTypeHangup:
            [self messageDetached:(KSDetached *)msg];
            break;
        default:
            break;
    }
}

#pragma mark - 消息发送
//创建连接
- (void)connectServer:(NSString *)url {
    [self.socket configureServer:url isAutoConnect:true];
    [self.socket startConnect];
}

//Send
//01 REQ 创建会话
-(void)createSession {
    NSString *transaction   = [NSString ks_randomForLength:KSRandomLength];
    NSMutableDictionary *message =[NSMutableDictionary dictionary];
    message[@"janus"]       = @"create";
    message[@"transaction"] = transaction;
    _msgs[transaction]      = [NSNumber numberWithInteger:KSActionTypeCreateSession];
    [_socket sendMessage:message];
}

//02 REQ 插件绑定
- (void)pluginBinding:(KSActionType)type transaction:(NSString *)transaction {
    NSMutableDictionary *message =[NSMutableDictionary dictionary];
    message[@"janus"]       = @"attach";
    message[@"transaction"] = transaction;
    message[@"session_id"]  = _sessionId;
    message[@"opaque_id"]   = _opaqueId;
    message[@"plugin"]      = @"janus.plugin.videoroom";
    _msgs[transaction]      = [NSNumber numberWithInteger:type];
    [_socket sendMessage:message];
}

//03 REQ  加入房间
- (void)joinRoom:(int)room {
    _roomMumber         = room;
    NSMutableDictionary *message =[NSMutableDictionary dictionary];
    message[@"request"] = @"join";
    message[@"room"]    = @(_roomMumber);
    message[@"ptype"]   = @"publisher";
    message[@"display"] = @"Ayumi";
    [self sendMessage:message jsep:NULL handleId:_myHandleId actionType:KSActionTypeJoinRoom];
}

// 配置房间(发布者加入房间成功后创建offer)
- (void)configureRoom:(NSNumber *)handleId {
    KSMediaConnection *mc             = [self.delegate localPeerConnectionOfMessageHandler:self handleId:handleId];
    mc.handleId                       = [handleId longLongValue];
    __weak KSMessageHandler *weakSelf = self;
    [mc createOfferWithCompletionHandler:^(RTCSessionDescription *sdp, NSError *error) {
        NSMutableDictionary *body =[NSMutableDictionary dictionary];
        body[@"request"] = @"configure";
        body[@"audio"]   = @YES;
        body[@"video"]   = @YES;

        NSString *type   = [RTCSessionDescription stringForType:sdp.type];
        NSMutableDictionary *jsep =[NSMutableDictionary dictionary];
        jsep[@"type"]    = type;
        jsep[@"sdp"]     = [sdp sdp];
        [weakSelf sendMessage:body jsep:jsep handleId:handleId actionType:KSActionTypeConfigureRoom];
    }];
}

// 观察者收到远端offer后，发送anwser
- (void)subscriberHandlerRemoteJsep:(NSNumber *)handleId dict:(NSDictionary *)jsep {
    KSMediaConnection *mc             = [self.delegate peerConnectionOfMessageHandler:self handleId:handleId];
    [mc setRemoteDescriptionWithJsep:jsep];

    __weak KSMessageHandler *weakSelf = self;
    [mc createAnswerWithCompletionHandler:^(RTCSessionDescription *sdp, NSError *error) {
        NSMutableDictionary *body =[NSMutableDictionary dictionary];
        body[@"request"] = @"start";
        body[@"room"]    = @(weakSelf.roomMumber);
        //body[@"video"]   = @YES;
        
        NSString *type   = [RTCSessionDescription stringForType:sdp.type];
        NSMutableDictionary *jsep =[NSMutableDictionary dictionary];
        jsep[@"type"]    = type;
        jsep[@"sdp"]     = [sdp sdp];
        [weakSelf sendMessage:body jsep:jsep handleId:handleId actionType:KSActionTypeStart];
    }];
}

// 发布者收到远端媒体信息后的回调 answer
- (void)onPublisherRemoteJsep:(NSNumber *)handleId dict:(NSDictionary *)jsep {
    KSMediaConnection *mc = [self.delegate peerConnectionOfMessageHandler:self handleId:handleId];
    [mc setRemoteDescriptionWithJsep:jsep];
}

// 发送候选者
- (void)sendCandidate:(NSMutableDictionary *)candidate {
    NSString *transaction        = [NSString ks_randomForLength:KSRandomLength];
    NSMutableDictionary *message = [NSMutableDictionary dictionary];
    message[@"janus"]            = @"trickle";
    message[@"transaction"]      = transaction;
    message[@"session_id"]       = _sessionId;
    message[@"candidate"]        = candidate;
    message[@"handle_id"]        = _myHandleId;
    [_socket sendMessage:message];
}

// 发送消息通用方法
- (void)sendMessage:(NSDictionary *)body jsep:(NSDictionary *)jsep handleId:(NSNumber *)handleId actionType:(KSActionType)actionType {
    NSString *transaction        = [NSString ks_randomForLength:KSRandomLength];
    NSMutableDictionary *message = [NSMutableDictionary dictionary];
    message[@"janus"]            = @"message";
    message[@"transaction"]      = transaction;
    message[@"session_id"]       = _sessionId;
    message[@"body"]             = body;
    message[@"handle_id"]        = handleId;
    if (jsep != NULL) {
        message[@"jsep"] = jsep;
    }
    _msgs[transaction] = [NSNumber numberWithInteger:actionType];
    [_socket sendMessage:message];
}

- (void)sendMessage:(NSMutableDictionary *)message type:(NSString *)type {
    
}

//KSWebSocketDelegate
/**
 连接成功
 */
- (void)socketDidOpen:(KSWebSocket *)socket {
    NSLog(@"连接socket服务器成功");
    [self.delegate messageHandler:self socketDidOpen:_socket];
    [self createSession];
}

/**
 出现错误/连接失败时调用[如果设置自动重连，则不会调用]
 */
- (void)socketDidFail:(KSWebSocket *)socket {
    NSLog(@"socket发生错误");
    [self.delegate messageHandler:self socketDidFail:_socket];
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

@end
