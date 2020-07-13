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
#import "KSMediaCapture.h"
#import "KSMediaConnection.h"

#import "NSString+Category.h"
#import "RTCSessionDescription+Category.h"

static int const KSRandomLength = 12;
typedef NS_ENUM(NSInteger, KSActionType) {
    KSActionTypeUnknown,
    KSActionTypeCreateSession,
    KSActionTypePluginBinding,
    KSActionTypePluginBindingSubscriber,
    KSActionTypeJoinRoom,
    KSActionTypeConfigureRoom,
    KSActionTypeSubscriber,
    KSActionTypeStart,
};

@interface KSMessageHandler()<KSWebSocketDelegate,KSMediaConnectionDelegate>

@property(nonatomic,strong)KSWebSocket *socket;
@property(nonatomic,strong)NSNumber *sessionId;
@property (nonatomic, copy) NSString *opaqueId;
@property(nonatomic,strong)NSNumber *roomMumber;
@property(nonatomic,strong)NSNumber *myHandleId;
@property (nonatomic, strong) NSMutableDictionary *connections;
@property (nonatomic, strong) NSMutableDictionary *msgs;
@property (nonatomic, strong) NSMutableDictionary *subscribers;
@property (nonatomic, strong) RTCPeerConnection *publisherPeerConnection;

@end
@implementation KSMessageHandler

- (instancetype)init {
    self = [super init];
    if (self) {
        self.socket = [[KSWebSocket alloc] init];
        self.socket.delegate = self;
        self.opaqueId = [NSString stringWithFormat:@"videoroom-%@", [NSString randomForLength:KSRandomLength]];
        self.connections = [NSMutableDictionary dictionary];
        self.msgs = [NSMutableDictionary dictionary];
        self.subscribers = [NSMutableDictionary dictionary];
        self.roomMumber = @1234;
    }
    return self;
}

- (void)messageSuccess:(KSSuccess *)success {
    KSActionType actionType = [_msgs[success.transaction] intValue];
    switch (actionType) {
        case KSActionTypeCreateSession:
            _sessionId = success.data.ID;
            _socket.configure.sessionId = _sessionId;
            _socket.configure.isSession = true;
            
            //WebRTC:02
            [self pluginBinding:KSActionTypePluginBinding transaction:[NSString randomForLength:KSRandomLength]];
            break;
        case KSActionTypePluginBinding:
            _myHandleId = success.data.ID;
            //WebRTC:03
            [self joinRoom:success.data.ID];
            break;
        case KSActionTypeJoinRoom:
            //WebRTC:04
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
            body[@"room"] = _roomMumber;
            body[@"ptype"] = @"subscriber";
            body[@"feed"] = member.ID;
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
            NSString *transaction = [NSString randomForLength:KSRandomLength];
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
    else if ([event.plugindata.data.leaving integerValue] > 0) {//用户离开
        
    }
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
            [self onLeaving:@""];
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
-(void)createSession {
    NSString *transaction       = [NSString randomForLength:KSRandomLength];
    NSMutableDictionary *sendMessage =[NSMutableDictionary dictionary];
    sendMessage[@"janus"]       = @"create";
    sendMessage[@"transaction"] = transaction;
    _msgs[transaction] = [NSNumber numberWithInteger:KSActionTypeCreateSession];
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
    _msgs[transaction] = [NSNumber numberWithInteger:type];
    [_socket sendMessage:message];
}

// 加入房间
- (void)joinRoom:(NSNumber *)handleId{
    NSMutableDictionary *sendMessage =[NSMutableDictionary dictionary];
    sendMessage[@"request"] = @"join";
    sendMessage[@"room"]    = _roomMumber;
    sendMessage[@"ptype"]   = @"publisher";
    sendMessage[@"display"]   = @"Ayumi";
    [self sendMessage:sendMessage jsep:NULL handleId:handleId actionType:KSActionTypeJoinRoom];
}

// 配置房间(发布者加入房间成功后创建offer)
- (void)configureRoom:(NSNumber *)handleId {
    KSMediaConnection *mc = [self createMediaConnection];
    _publisherPeerConnection = mc.connection;
    __weak KSMessageHandler *weakSelf = self;
    [mc createOfferWithCompletionHandler:^(RTCSessionDescription *sdp, NSError *error) {
        NSMutableDictionary *body =[NSMutableDictionary dictionary];
        body[@"request"] = @"configure";
        body[@"audio"] = @YES;
        body[@"video"] = @YES;
        
        NSString *type = [RTCSessionDescription stringForType:sdp.type];
        NSMutableDictionary *jsep =[NSMutableDictionary dictionary];
        jsep[@"type"] = type;
        jsep[@"sdp"] = [sdp sdp];
        [weakSelf sendMessage:body jsep:jsep handleId:handleId actionType:KSActionTypeConfigureRoom];
    }];
    mc.handleId = handleId;
    _connections[handleId] = mc;
}

// 发布者收到远端媒体信息后的回调 answer
- (void)onPublisherRemoteJsep:(NSNumber *)handleId dict:(NSDictionary *)jsep {
    KSMediaConnection *mc = _connections[handleId];
    [mc setRemoteDescriptionWithJsep:jsep];
}

// 观察者收到远端offer后，发送anwser
- (void)subscriberHandlerRemoteJsep:(NSNumber *)handleId dict:(NSDictionary *)jsep {
    KSMediaConnection *mc = [self createMediaConnection];
    mc.handleId = handleId;
    _connections[handleId] = mc;
    
    [mc setRemoteDescriptionWithJsep:jsep];
    
    __weak KSMessageHandler *weakSelf = self;
    [mc createAnswerWithCompletionHandler:^(RTCSessionDescription *sdp, NSError *error) {
        NSMutableDictionary *body =[NSMutableDictionary dictionary];
        body[@"request"] = @"start";
        body[@"room"] = weakSelf.roomMumber;
        //body[@"video"] = @YES;
        
        NSString *type = [RTCSessionDescription stringForType:sdp.type];
        NSMutableDictionary *jsep =[NSMutableDictionary dictionary];
        jsep[@"type"] = type;
        jsep[@"sdp"] = [sdp sdp];
        [weakSelf sendMessage:body jsep:jsep handleId:handleId actionType:KSActionTypeStart];
    }];
}

// 发送候选者
- (void)trickleCandidate:(NSNumber *)handleId candidate:(NSMutableDictionary *)candidate {
    NSString *transaction       = [NSString randomForLength:KSRandomLength];
    NSMutableDictionary *sendMessage =[NSMutableDictionary dictionary];
    sendMessage[@"janus"]       = @"trickle";
    sendMessage[@"transaction"] = transaction;
    sendMessage[@"session_id"]  = _sessionId;
    sendMessage[@"candidate"]   = candidate;
    sendMessage[@"handle_id"]   = handleId;
    
    [_socket sendMessage:sendMessage];
}

// 发送消息通用方法
- (void)sendMessage:(NSDictionary *)body jsep:(NSDictionary *)jsep handleId:(NSNumber *)handleId actionType:(KSActionType)actionType {
    NSString *transaction = [NSString randomForLength:KSRandomLength];
    NSMutableDictionary *sendMessage = [NSMutableDictionary dictionary];
    sendMessage[@"janus"] = @"message";
    sendMessage[@"transaction"] = transaction;
    sendMessage[@"session_id"] = _sessionId;
    sendMessage[@"body"] = body;
    sendMessage[@"handle_id"] = handleId;
    if (jsep != NULL) {
        sendMessage[@"jsep"] = jsep;
    }
    _msgs[transaction] = [NSNumber numberWithInteger:actionType];
    [_socket sendMessage:sendMessage];
}

// 创建一个媒体连接
-(KSMediaConnection *)createMediaConnection {
    KSMediaCapture *mediaCapture = [self.delegate mediaCaptureOfSectionsInMessageHandler:self];
    KSMediaConnection *mc = [[KSMediaConnection alloc] init];
    [mc createPeerConnection:mediaCapture.factory audioTrack:mediaCapture.audioTrack videoTrack:mediaCapture.videoTrack];
    mc.delegate = self;
    return mc;
}

- (void)onLeaving:(NSString *)handleId {
    KSMediaConnection *mc = _connections[handleId];
    [mc close];
    [_connections removeObjectForKey:handleId];
}

//KSWebSocketDelegate
/**
 连接成功
 */
- (void)socketDidOpen:(KSWebSocket *)socket {
    //WebRTC:01
    [self createSession];
}

/**
 出现错误/连接失败时调用[如果设置自动重连，则不会调用]
 */
- (void)socketDidFail:(KSWebSocket *)socket {
    
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

//KSPeerConnectionDelegate
- (void)mediaConnection:(KSMediaConnection *)mediaConnection peerConnection:(RTCPeerConnection *)peerConnection didAddStream:(RTCMediaStream *)stream {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (stream.videoTracks.count > 0) {
            RTCVideoTrack *remoteVideoTrack = stream.videoTracks[0];
            RTCEAGLVideoView *remoteView = [self.delegate remoteViewOfSectionsInMessageHandler:self handleId:mediaConnection.handleId];
            [remoteVideoTrack addRenderer:remoteView];
            mediaConnection.videoTrack = remoteVideoTrack;
        }
    });
}

- (void)mediaConnection:(KSMediaConnection *)mediaConnection peerConnection:(RTCPeerConnection *)peerConnection didGenerateIceCandidate:(RTCIceCandidate *)candidate {
    NSMutableDictionary *body =[NSMutableDictionary dictionary];
    if (candidate) {
        body[@"candidate"] = candidate.sdp;
        body[@"sdpMid"] = candidate.sdpMid;
        body[@"sdpMLineIndex"]  = @(candidate.sdpMLineIndex);
        [self trickleCandidate:mediaConnection.handleId candidate:body];
    }
    else{
        body[@"completed"] = @YES;
        [self trickleCandidate:mediaConnection.handleId candidate:body];
    }
}

@end
