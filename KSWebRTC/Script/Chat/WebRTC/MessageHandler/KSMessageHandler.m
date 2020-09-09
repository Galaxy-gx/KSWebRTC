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

//测试属性
static int const KSRandomLength = 12;

@interface KSMessageHandler()<KSWebSocketDelegate>
@property (nonatomic,strong ) KSWebSocket         *socket;
@property (nonatomic,assign ) BOOL                isConnect;

//测试属性
@property (nonatomic,strong ) NSNumber            *sessionId;
@property (nonatomic, copy  ) NSString            *opaqueId;
@property (nonatomic,strong ) NSNumber            *roomMumber;
@property (nonatomic,strong ) NSNumber            *myHandleId;
@property (nonatomic,strong ) NSNumber            *userId;
@property (nonatomic, strong) NSMutableDictionary *msgs;
@property (nonatomic, strong) NSMutableDictionary *subscribers;

@end

@implementation KSMessageHandler
#pragma mark - Janus代码
- (instancetype)init {
    self = [super init];
    if (self) {
        self.socket          = [[KSWebSocket alloc] init];
        self.socket.delegate = self;
        self.opaqueId        = [NSString stringWithFormat:@"videoroom-%@", [NSString ks_randomForLength:KSRandomLength]];
        self.msgs            = [NSMutableDictionary dictionary];
        self.subscribers     = [NSMutableDictionary dictionary];
        self.roomMumber      = @1234;
        self.userId          = [self randomNumber];
    }
    return self;
}

- (NSNumber *)randomNumber {
    int random = (arc4random() % 10000) + 10000;
    return [NSNumber numberWithInt:random];
}

- (void)messageSuccess:(KSSuccess *)success {
    KSActionType actionType = [_msgs[success.transaction] intValue];
    switch (actionType) {
        case KSActionTypeCreateSession:
            _sessionId                  = success.data.ID;
            _socket.configure.sessionId = _sessionId;//房间会话ID
            _socket.configure.isSession = true;

            //WebRTC:02
            [self pluginBinding:KSActionTypePluginBinding transaction:[NSString ks_randomForLength:KSRandomLength]];
            break;
        case KSActionTypePluginBinding:
            _myHandleId = success.data.ID;
            //WebRTC:03
            [self joinRoom:success.data.ID];
            break;
        case KSActionTypeJoinRoom:
            //WebRTC:04
            //发送offer
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
            NSMutableDictionary *body =[NSMutableDictionary dictionary];
            body[@"request"] = @"join";
            body[@"room"]    = _roomMumber;
            body[@"ptype"]   = @"subscriber";
            body[@"feed"]    = member.ID;
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
        [self.delegate messageHandler:self joinedJsep:event.jsep];
        
        if ([event.jsep[@"type"] isEqualToString:@"offer"]) {
            //WebRTC:07
            [self subscriberHandlerRemoteJsep:event.sender dict:event.jsep];
        }
        else if ([event.jsep[@"type"] isEqualToString:@"answer"]) {
            //WebRTC:08
            [self onPublisherRemoteJsep:_myHandleId dict:event.jsep];
        }
    }
    else if ([event.plugindata.data.leaving integerValue] > 0) {//用户离开
        
    }
}

- (void)messageDetached:(KSDetached *)detached {
    /*
    if ([self.delegate respondsToSelector:@selector(messageHandler:leaveOfHandleId:)]) {
        [self.delegate messageHandler:self leaveOfHandleId:detached.sender];
    }
     */
}

- (void)analysisMsg:(id)message {
    NSData *jsonData   = [message dataUsingEncoding:NSUTF8StringEncoding];
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

- (void)connectServer:(NSString *)url {
    [self.socket configureServer:url isAutoConnect:true];
    [self.socket startConnect];
}

//Send
// 创建会话
- (void)createSession {
    NSString *transaction       = [NSString ks_randomForLength:KSRandomLength];
    NSMutableDictionary *sendMessage =[NSMutableDictionary dictionary];
    sendMessage[@"janus"]       = @"create";
    sendMessage[@"transaction"] = transaction;
    sendMessage[@"user_id"]     = self.userId;
    _msgs[transaction]          = [NSNumber numberWithInteger:KSActionTypeCreateSession];
    [_socket sendMessage:sendMessage];
}

- (void)requestHangup {
    NSString *transaction       = [NSString ks_randomForLength:KSRandomLength];
    NSMutableDictionary *sendMessage =[NSMutableDictionary dictionary];
    sendMessage[@"request"]     = @"hangup";
    sendMessage[@"transaction"] = transaction;
    sendMessage[@"user_id"]     = self.userId;
    [_socket sendMessage:sendMessage];
}

// 插件绑定
- (void)pluginBinding:(KSActionType)type transaction:(NSString *)transaction {
    NSMutableDictionary *message =[NSMutableDictionary dictionary];
    message[@"janus"]       = @"attach";
    message[@"transaction"] = transaction;
    message[@"session_id"]  = _sessionId;
    message[@"opaque_id"]   = _opaqueId;
    message[@"plugin"]      = @"janus.plugin.videoroom";
    message[@"user_id"]     = self.userId;
    _msgs[transaction]      = [NSNumber numberWithInteger:type];
    [_socket sendMessage:message];
}

// 加入房间
- (void)joinRoom:(NSNumber *)handleId{
    NSMutableDictionary *sendMessage =[NSMutableDictionary dictionary];
    sendMessage[@"request"] = @"join";
    sendMessage[@"room"]    = _roomMumber;
    sendMessage[@"ptype"]   = @"publisher";
    sendMessage[@"display"] = @"Ayumi";
    [self sendMessage:sendMessage jsep:NULL handleId:handleId actionType:KSActionTypeJoinRoom];
}

/*
 https://webrtc.org.cn/webrtc-tutorial-2-signaling-stun-turn/
 WebRTC 媒体协商的过种。
 
 Amy:remote Bob:Local
 
 第一步，Amy 调用 createOffer 方法创建 offer 消息。offer 消息中的内容是 Amy 的 SDP 信息。
 第二步，Amy 调用 setLocalDescription 方法，将本端的 SDP 信息保存起来。
 第三步，Amy 将 offer 消息通过信令服务器传给 Bob。
 
 第四步，Bob 收到 offer 消息后，调用 setRemoteDescription 方法将其存储起来。
 第五步，Bob 调用 createAnswer 方法创建 answer 消息， 同样，answer 消息中的内容是 Bob 的 SDP 信息。
 第六步，Bob 调用 setLocalDescription 方法，将本端的 SDP 信息保存起来。
 第七步，Bob 将 anwser 消息通过信令服务器传给 Amy。
 第八步，Amy 收到 anwser 消息后，调用 setRemoteDescription 方法，将其保存起来。
 
 通过以上步骤就完成了通信双方媒体能力的交换。
 */
// 配置房间(发布者加入房间成功后创建offer)
- (void)configureRoom:(NSNumber *)handleId {
    KSMediaConnection *mc             = [self.delegate messageHandlerOfLocalConnection];
    __weak KSMessageHandler *weakSelf = self;
    [mc createOfferWithCompletionHandler:^(RTCSessionDescription *sdp, NSError *error) {
        NSMutableDictionary *body =[NSMutableDictionary dictionary];
        body[@"request"] = @"configure";
        body[@"audio"]   = @(YES);
        body[@"video"]   = @(YES);

        NSString *type   = [RTCSessionDescription stringForType:sdp.type];
        NSMutableDictionary *jsep =[NSMutableDictionary dictionary];
        jsep[@"type"]    = type;
        jsep[@"sdp"]     = [sdp sdp];
        [weakSelf sendMessage:body jsep:jsep handleId:handleId actionType:KSActionTypeConfigureRoom];
    }];
}

// 观察者收到远端offer后，发送anwser
- (void)subscriberHandlerRemoteJsep:(NSNumber *)handleId dict:(NSDictionary *)jsep {
    KSMediaConnection *mc             = [self.delegate messageHandlerOfLocalConnection];
    [mc setRemoteDescriptionWithJsep:jsep];
    
    __weak KSMessageHandler *weakSelf = self;
    [mc createAnswerWithCompletionHandler:^(RTCSessionDescription *sdp, NSError *error) {
        NSMutableDictionary *body =[NSMutableDictionary dictionary];
        body[@"request"] = @"start";
        body[@"room"] = weakSelf.roomMumber;
        body[@"video"] = @YES;
        
        NSString *type = [RTCSessionDescription stringForType:sdp.type];
        NSMutableDictionary *jsep =[NSMutableDictionary dictionary];
        jsep[@"type"] = type;
        jsep[@"sdp"] = [sdp sdp];
        [weakSelf sendMessage:body jsep:jsep handleId:handleId actionType:KSActionTypeStart];
    }];
}

// 发布者收到远端媒体信息后的回调 answer
- (void)onPublisherRemoteJsep:(NSNumber *)handleId dict:(NSDictionary *)jsep {
    KSMediaConnection *mc             = [self.delegate messageHandlerOfLocalConnection];
    [mc setRemoteDescriptionWithJsep:jsep];
}

// 发送候选者
- (void)trickleCandidate:(NSNumber *)handleId candidate:(NSMutableDictionary *)candidate {
    NSString *transaction            = [NSString ks_randomForLength:KSRandomLength];
    NSMutableDictionary *sendMessage = [NSMutableDictionary dictionary];
    sendMessage[@"janus"]            = @"trickle";
    sendMessage[@"transaction"]      = transaction;
    sendMessage[@"session_id"]       = _sessionId;
    sendMessage[@"candidate"]        = candidate;
    sendMessage[@"handle_id"]        = handleId;
    sendMessage[@"user_id"]          = self.userId;
    [_socket sendMessage:sendMessage];
}

// 发送消息通用方法
- (void)sendMessage:(NSDictionary *)body jsep:(NSDictionary *)jsep handleId:(NSNumber *)handleId actionType:(KSActionType)actionType {
    NSString *transaction            = [NSString ks_randomForLength:KSRandomLength];
    NSMutableDictionary *sendMessage = [NSMutableDictionary dictionary];
    sendMessage[@"janus"]            = @"message";
    sendMessage[@"transaction"]      = transaction;
    sendMessage[@"session_id"]       = _sessionId;
    sendMessage[@"body"]             = body;
    sendMessage[@"handle_id"]        = handleId;
    sendMessage[@"user_id"]          = self.userId;
    if (jsep != NULL) {
        sendMessage[@"jsep"] = jsep;
    }
    _msgs[transaction] = [NSNumber numberWithInteger:actionType];
    [_socket sendMessage:sendMessage];
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
    //WebRTC:01
    [self createSession];
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

#pragma mark - 实际业务
- (void)callToPeerId:(int)peerId type:(KSCallType)type {
    
}

- (void)trickleCandidate:(NSMutableDictionary *)candidate {
    candidate[@"candidate"] = candidate[@"sdp"];//兼容作用
    [self trickleCandidate:_myHandleId candidate:candidate];
}

- (void)leave {
    
}

@end
