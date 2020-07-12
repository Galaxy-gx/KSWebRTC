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
typedef NS_ENUM(NSInteger, KSNextMessageType) {
    KSNextMessageTypeUnknown,
    KSNextMessageTypeAttach,
    KSNextMessageTypePublisher,
    KSNextMessageTypeEvent,
    KSNextMessageTypeSubscriber,
    KSNextMessageTypeMessageConfigure,
};

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
@property(nonatomic,strong)NSNumber *feed;
@property(nonatomic,strong)NSNumber *roomMumber;
@property(nonatomic,strong)NSNumber *globalHandleId;
@property(nonatomic,strong)NSNumber *myPrivateId;
@property (nonatomic, strong) NSMutableDictionary *connections;
@property (nonatomic, strong) NSMutableDictionary *msgs;
@property (nonatomic, strong) RTCPeerConnection *publisherPeerConnection;
@property (nonatomic, assign) KSNextMessageType nextMessage;
@property(nonatomic,strong)NSMutableArray *publishers;

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
        self.roomMumber = @1234;
        self.publishers = [NSMutableArray array];
    }
    return self;
}

- (void)messageSuccess:(KSSuccess *)success {
    KSActionType actionType = [_msgs[success.transaction] intValue];
    switch (actionType) {
        case KSActionTypeCreateSession:
            _sessionId = success.data.ID;
            //002
            [self pluginBinding:KSActionTypePluginBinding];
            break;
        case KSActionTypePluginBinding:
            _globalHandleId = success.data.ID;
            //003
            [self joinRoom];
            break;
        case KSActionTypeJoinRoom:
            //005
            [self configureRoom:_globalHandleId];
            break;
        case KSActionTypeConfigureRoom:
            
            break;
        case KSActionTypeSubscriber:
            
            break;
        case KSActionTypePluginBindingSubscriber:
            _globalHandleId = success.data.ID;
            //006
            for (NSNumber *ID in _publishers) {
                NSMutableDictionary *body =[NSMutableDictionary dictionary];
                body[@"request"] = @"join";
                body[@"room"] = _roomMumber;
                body[@"ptype"] = @"subscriber";
                body[@"feed"] = ID;
                body[@"private_id"] = _myPrivateId;
                [self sendMessage:body jsep:NULL actionType:KSActionTypeSubscriber];
            }
            break;
        default:
            break;
    }
}

- (void)messageEvent:(KSEvent *)event {
    if ([event.plugindata.data.videoroom isEqualToString:@"joined"]) {
        if (event.plugindata.data.private_id) {
            _myPrivateId = event.plugindata.data.private_id;
            [self.publishers removeAllObjects];
            for (KSPublishers *item in event.plugindata.data.publishers) {
                [self.publishers addObject:item.ID];
            }
            //004
            [self pluginBinding:KSActionTypePluginBindingSubscriber];
        }
    }
    else if (event.jsep) {
        NSDictionary *jsep = @{@"type" : event.jsep.type,@"sdp" : event.jsep.sdp};
        [self subscriberHandlerRemoteJsep:_globalHandleId dict:jsep];
        //[self onPublisherRemoteJsep: _globalHandleId dict:jsep];
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
    NSLog(@"Received: %@",dict);
    KSMsg *msg = [KSMsg deserializeForMsg:dict];
    if (!msg) {
        return;
    }
    switch (msg.msgType) {
        case KSMessageTypeSuccess:
            [self messageSuccess:(KSSuccess *)msg];
            break;
        case KSMessageTypeError:
        case KSMessageTypeAck:
            
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
//001创建会话
-(void)createSession {
    NSString *transaction       = [NSString randomForLength:KSRandomLength];
    NSMutableDictionary *sendMessage =[NSMutableDictionary dictionary];
    sendMessage[@"janus"]       = @"create";
    sendMessage[@"transaction"] = transaction;
    _msgs[transaction] = [NSNumber numberWithInteger:KSActionTypeCreateSession];
    [_socket sendMessage:sendMessage];
}

//002插件绑定
- (void)pluginBinding:(KSActionType)type {
    NSString *transaction = [NSString randomForLength:KSRandomLength];
    NSMutableDictionary *message =[NSMutableDictionary dictionary];
    message[@"janus"]       = @"attach";
    message[@"transaction"] = transaction;
    message[@"session_id"]  = _sessionId;
    message[@"opaque_id"]   = _opaqueId;
    message[@"plugin"]      = @"janus.plugin.videoroom";
    _msgs[transaction] = [NSNumber numberWithInteger:type];
    [_socket sendMessage:message];
}

// 003加入房间
- (void)joinRoom {
    NSMutableDictionary *sendMessage =[NSMutableDictionary dictionary];
    sendMessage[@"request"] = @"join";
    sendMessage[@"room"]    = _roomMumber;
    sendMessage[@"ptype"]   = @"publisher";
    sendMessage[@"display"]   = @"Ayumi";
    [self sendMessage:sendMessage jsep:NULL actionType:KSActionTypeJoinRoom];
}

// 004配置房间
- (void)configureRoom:(NSNumber *)handleId {
    KSMediaConnection *mc = [self createMediaConnection];
    mc.handleId = handleId;
    
    _publisherPeerConnection = mc.connection;
    _connections[handleId] = mc;
    
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
        [weakSelf sendMessage:body jsep:jsep actionType:KSActionTypeConfigureRoom];
    }];
}

// 发布者收到远端媒体信息后的回调
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
        body[@"video"] = @YES;
        
        NSString *type = [RTCSessionDescription stringForType:sdp.type];
        NSMutableDictionary *jsep =[NSMutableDictionary dictionary];
        jsep[@"type"] = type;
        jsep[@"sdp"] = [sdp sdp];
        [weakSelf sendMessage:body jsep:jsep actionType:KSActionTypeStart];
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

// 处理远端发送者的媒体信息
- (void)subscriberCreateHandle:(NSNumber *)feed display:(NSString *)display plugin:(NSString *)plugin {
    
}

// 发送消息通用方法
- (void)sendMessage:(NSDictionary *)body jsep:(NSDictionary *)jsep actionType:(KSActionType)actionType {
    NSString *transaction = [NSString randomForLength:KSRandomLength];
    NSMutableDictionary *sendMessage = [NSMutableDictionary dictionary];
    sendMessage[@"janus"] = @"message";
    sendMessage[@"transaction"] = transaction;
    sendMessage[@"session_id"] = _sessionId;
    sendMessage[@"body"] = body;
    sendMessage[@"handle_id"] = _globalHandleId;
    if (jsep != NULL) {
        sendMessage[@"jsep"] = jsep;
    }
    _msgs[transaction] = [NSNumber numberWithInteger:KSActionTypeJoinRoom];
    [_socket sendMessage:sendMessage];
}


//
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
    self.nextMessage = KSNextMessageTypeAttach;
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
