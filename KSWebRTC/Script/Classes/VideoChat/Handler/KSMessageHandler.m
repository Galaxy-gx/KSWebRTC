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
#import "NSString+Category.h"
#import "KSMediaCapture.h"
#import "KSMediaConnection.h"

static int const KSRandomLength = 12;

@interface KSMessageHandler()<KSWebSocketDelegate,KSPeerConnectionDelegate>

@property(nonatomic,strong)KSWebSocket *socket;
@property(nonatomic,copy)NSString *sessionId;
@property (nonatomic, copy) NSString *opaqueId;
@end
@implementation KSMessageHandler

- (instancetype)init {
    self = [super init];
    if (self) {
        self.socket = [[KSWebSocket alloc] init];
        self.socket.delegate = self;
        self.opaqueId = [NSString stringWithFormat:@"videoroom-%@", [NSString randomForLength:KSRandomLength]];
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
    NSLog(@"------------------------------------------------------------");
    NSLog(@"%@",dict);
    KSMsg *msg = [KSMsg deserializeForMsg:dict];
    if (!msg) {
        return;
    }
    switch (msg.msgType) {
        case KSMessageTypeSuccess:
        case KSMessageTypeError:
        case KSMessageTypeAck:
            
            break;
        case KSMessageTypeEvent:
        {
            KSEvent *event = msg;
            if ([event.plugindata.data.videoroom isEqualToString:@"joined"]) {
                //1
                [self joinRoom:event.plugindata.data.ID];
                //2
                if (event.plugindata.data.publishers.count > 0) {
                    for (KSPublishers *item in event.plugindata.data.publishers) {
                        [self publisherCreateHandler:@"janus.plugin.videoroom"];
                    }
                }
            }
        }
            
            break;
        case KSMessageTypeMedia:
            
            break;
        case KSMessageTypeWebrtcup:
            
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
- (void)publisherCreateHandler:(NSString *)plugin {
    NSString *transaction       = [NSString randomForLength:KSRandomLength];
    NSMutableDictionary *sendMessage =[NSMutableDictionary dictionary];
    sendMessage[@"janus"]       = @"attach";
    sendMessage[@"transaction"] = transaction;
    sendMessage[@"session_id"]  = _sessionId;
    sendMessage[@"opaque_id"]   = _opaqueId;
    sendMessage[@"plugin"]      = plugin;

    [_socket sendMessage:sendMessage];
}

// 观察者收到远端offer后，发送anwser
- (void)subscriberHandlerRemoteJsep:(NSString *)handleId dict:(NSDictionary *)jsep {
    KSMediaConnection *mc = [self createMediaConnection];
}

// 发送候选者
//- (void)trickleCandidate:(NSNumber *)handleId candidate:(NSDictionary *)candidate {
//    NSString *transaction       = [NSString randomForLength:KSRandomLength];
//    NSMutableDictionary *sendMessage =[NSMutableDictionary dictionary];
//    sendMessage[@"janus"]       = @"trickle";
//    sendMessage[@"transaction"] = transaction;
//    sendMessage[@"session_id"]  = _sessionId;
//    sendMessage[@"candidate"]   = candidate;
//    sendMessage[@"handle_id"]   = handleId;
//
//    [_socket sendMessage:sendMessage];
//}

// 处理远端发送者的媒体信息
- (void)subscriberCreateHandle:(NSNumber *)feed display:(NSString *)display plugin:(NSString *)plugin {
    
}

// 加入房间
- (void)joinRoom:(NSString *)handleId {
    NSMutableDictionary *sendMessage =[NSMutableDictionary dictionary];
    sendMessage[@"request"] = @"join";
    sendMessage[@"room"]    = @1234;
    sendMessage[@"ptype"]   = @"publisher";
    sendMessage[@"display"]   = @"木易";
    [self sendMessage:sendMessage handleId:handleId jsep:NULL];
}

// 发送消息通用方法
- (void)sendMessage:(NSDictionary *)body handleId:(NSString *)handleId jsep:(NSDictionary *)jsep {
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
    return NULL;
}
//KSWebSocketDelegate
/**
 连接成功
 */
- (void)socketDidOpen:(KSWebSocket *)socket {
    
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
- (void)MediaConnection:(KSMediaConnection *)mediaConnection peerConnection:(RTCPeerConnection *)peerConnection didAddStream:(RTCMediaStream *)stream {
    
}

- (void)MediaConnection:(KSMediaConnection *)mediaConnection peerConnection:(RTCPeerConnection *)peerConnection didGenerateIceCandidate:(RTCIceCandidate *)candidate {
    
}

@end
