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

@interface KSMessageHandler()<KSWebSocketDelegate,KSMediaConnectionDelegate>

@property(nonatomic,strong)KSWebSocket *socket;
@property(nonatomic,strong)NSNumber *sessionId;
@property (nonatomic, copy) NSString *opaqueId;
@property(nonatomic,strong)NSNumber *privateId;
@property(nonatomic,strong)NSNumber *feed;
@property(nonatomic,strong)NSNumber *roomMumber;
@property(nonatomic,strong)NSNumber *globalHandleId;
@property (nonatomic, strong) NSMutableDictionary *connections;
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
        self.opaqueId = [NSString stringWithFormat:@"videoroomtest-%@", [NSString randomForLength:KSRandomLength]];
        self.connections = [NSMutableDictionary dictionary];
        self.roomMumber = @1234;
        self.publishers = [NSMutableArray array];
    }
    return self;
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
        {
            KSSuccess *success = (KSSuccess *)msg;
            if (_nextMessage == KSNextMessageTypeAttach) {
                _sessionId = success.data.ID;
                self.socket.configure.sessionId = _sessionId;
                self.socket.configure.isSession = true;
                
                //WebRTC:02
                _nextMessage = KSNextMessageTypePublisher;
                [self publisherCreate];
            }
            else if (_nextMessage == KSNextMessageTypePublisher) {
                //WebRTC:03
                _nextMessage = KSNextMessageTypeEvent;
                _globalHandleId = success.data.ID;
                [self joinRoom:success.data.ID];
            }
            else if (_nextMessage == KSNextMessageTypeSubscriber) {
                //WebRTC:05
                _nextMessage = KSNextMessageTypeMessageConfigure;
                for (NSNumber *ID in _publishers) {
                    NSMutableDictionary *body =[NSMutableDictionary dictionary];
                    body[@"request"] = @"join";
                    body[@"room"] = _roomMumber;
                    body[@"ptype"] = @"subscriber";
                    body[@"feed"] = ID;
                    body[@"private_id"] = self.privateId;
                    [self sendMessage:body handleId:success.data.ID jsep:NULL];
                }
            }
        }
            break;
        case KSMessageTypeError:
        case KSMessageTypeAck:
            
            break;
        case KSMessageTypeEvent:
        {
            KSEvent *event = (KSEvent *)msg;
            if (_nextMessage == KSNextMessageTypeEvent) {
                if ([event.plugindata.data.videoroom isEqualToString:@"joined"]) {
                    if (event.plugindata.data.private_id) {
                        self.privateId = event.plugindata.data.private_id;
                    }
                    if (event.plugindata.data.publishers.count > 0) {
                        //WebRTC:04
                        _nextMessage = KSNextMessageTypeSubscriber;
                        [self publisherCreate];
                        [self.publishers removeAllObjects];
                        for (KSPublishers *publisher in event.plugindata.data.publishers) {
                            [self.publishers addObject:publisher.ID];
                        }
                    }
                }
            }
            else if (_nextMessage == KSNextMessageTypeMessageConfigure) {
                //WebRTC:06 audio/video
                [self offerPeerConnection:_globalHandleId];
                /*
                 "session_id" : 8591611836719692,
                 "handle_id" : 4701730182495820,
                 "candidate" : {
                   "sdpMLineIndex" : 0,
                   "candidate" : "candidate:1561373377 1 udp 2122260223 192.168.9.73 53990 typ host generation 0 ufrag 1V3q network-id 1 network-cost 10",
                   "sdpMid" : "audio"
                 },
                 "janus" : "trickle",
                 "transaction" : "oSIlgrhV8a2g"
                 */
            }
            
        }
            
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
//创建会话
-(void)createSession {
    NSString *transaction       = [NSString randomForLength:KSRandomLength];
    NSMutableDictionary *sendMessage =[NSMutableDictionary dictionary];
    sendMessage[@"janus"]       = @"create";
    sendMessage[@"transaction"] = transaction;
    [_socket sendMessage:sendMessage];
}

// 自身，即发送者，创建与服务器插件的连接
- (void)publisherCreate {
    NSString *transaction = [NSString randomForLength:KSRandomLength];
    NSMutableDictionary *message =[NSMutableDictionary dictionary];
    message[@"janus"]       = @"attach";
    message[@"transaction"] = transaction;
    message[@"session_id"]  = _sessionId;
    message[@"opaque_id"]   = _opaqueId;
    message[@"plugin"]      = @"janus.plugin.videoroom";
    
    [_socket sendMessage:message];
}

// 发布者加入房间成功后创建offer
- (void)onPublisherJoined:(NSNumber *)handleId {
    [self offerPeerConnection:handleId];
}

// 创建offer
- (void)offerPeerConnection:(NSNumber *)handleId {
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
        [weakSelf sendMessage:body handleId:handleId jsep:jsep];
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
        [weakSelf sendMessage:body handleId:handleId jsep:jsep];
        
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

// 加入房间
- (void)joinRoom:(NSNumber *)handleId {
    NSMutableDictionary *sendMessage =[NSMutableDictionary dictionary];
    sendMessage[@"request"] = @"join";
    sendMessage[@"room"]    = _roomMumber;
    sendMessage[@"ptype"]   = @"publisher";
    sendMessage[@"display"]   = @"木易";
    [self sendMessage:sendMessage handleId:handleId jsep:NULL];
}

// 发送消息通用方法
- (void)sendMessage:(NSDictionary *)body handleId:(NSNumber *)handleId jsep:(NSDictionary *)jsep {
    NSString *transaction       = [NSString randomForLength:KSRandomLength];
    NSMutableDictionary *sendMessage =[NSMutableDictionary dictionary];
    sendMessage[@"janus"]       = @"message";
    sendMessage[@"transaction"] = transaction;
    sendMessage[@"session_id"]  = _sessionId;
    sendMessage[@"body"]        = body;
    sendMessage[@"handle_id"]   = handleId;
    if (jsep != NULL) {
        sendMessage[@"jsep"] = jsep;
    }
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
