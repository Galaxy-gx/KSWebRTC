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

@property (nonatomic,strong ) KSWebSocket         *socket;
@property (nonatomic,strong ) NSNumber            *sessionId;
@property (nonatomic, copy  ) NSString            *opaqueId;
@property (nonatomic,strong ) NSNumber            *roomMumber;
@property (nonatomic,strong ) NSNumber            *myHandleId;
@property (nonatomic, strong) NSMutableDictionary *connections;
@property (nonatomic, strong) NSMutableDictionary *msgs;
@property (nonatomic, strong) NSMutableDictionary *subscribers;
@property (nonatomic, weak) RTCPeerConnection     *publisherPeerConnection;

@end

@implementation KSMessageHandler

- (instancetype)init {
    self = [super init];
    if (self) {
        self.socket          = [[KSWebSocket alloc] init];
        self.socket.delegate = self;
        self.opaqueId        = [NSString stringWithFormat:@"videoroom-%@", [NSString ks_randomForLength:KSRandomLength]];
        self.connections     = [NSMutableDictionary dictionary];
        self.msgs            = [NSMutableDictionary dictionary];
        self.subscribers     = [NSMutableDictionary dictionary];
        self.roomMumber      = @1234;
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
            [self pluginBinding:KSActionTypePluginBinding transaction:[NSString ks_randomForLength:KSRandomLength]];
            break;
        case KSActionTypePluginBinding:
            _myHandleId = success.data.ID;
            //WebRTC:03
            [self joinRoom:success.data.ID];
            break;
        case KSActionTypeJoinRoom:
            //WebRTC:04
            //这里应该创建PeerConnection
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
    else if ([event.plugindata.data.leaving integerValue] > 0) {//用户离开
        
    }
}

- (void)messageDetached:(KSDetached *)detached {
    [self.delegate messageHandler:self leaveOfHandleId:detached.sender];
    [self onLeaving:detached.sender];
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

- (void)connectServer:(NSString *)url {
    [self.socket configureServer:url isAutoConnect:true];
    [self.socket startConnect];
}

//Send
// 创建会话
-(void)createSession {
    NSString *transaction       = [NSString ks_randomForLength:KSRandomLength];
    NSMutableDictionary *sendMessage =[NSMutableDictionary dictionary];
    sendMessage[@"janus"]       = @"create";
    sendMessage[@"transaction"] = transaction;
    _msgs[transaction] = [NSNumber numberWithInteger:KSActionTypeCreateSession];
    [_socket sendMessage:sendMessage];
}

-(void)requestHangup {
    NSString *transaction       = [NSString ks_randomForLength:KSRandomLength];
    NSMutableDictionary *sendMessage =[NSMutableDictionary dictionary];
    sendMessage[@"request"]     = @"hangup";
    sendMessage[@"transaction"] = transaction;
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
    KSMediaConnection *mc             = [self createMediaConnection];
    _publisherPeerConnection          = mc.connection;
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
    if (_connections.count == 0) {//测试
        mc.isLocal = YES;
    }
    _connections[handleId] = mc;
}

// 观察者收到远端offer后，发送anwser
- (void)subscriberHandlerRemoteJsep:(NSNumber *)handleId dict:(NSDictionary *)jsep {
    KSMediaConnection *mc  = [self createMediaConnection];
    mc.handleId            = handleId;
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

// 发布者收到远端媒体信息后的回调 answer
- (void)onPublisherRemoteJsep:(NSNumber *)handleId dict:(NSDictionary *)jsep {
    KSMediaConnection *mc = _connections[handleId];
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

    [_socket sendMessage:sendMessage];
}

// 发送消息通用方法
- (void)sendMessage:(NSDictionary *)body jsep:(NSDictionary *)jsep handleId:(NSNumber *)handleId actionType:(KSActionType)actionType {
    NSString *transaction = [NSString ks_randomForLength:KSRandomLength];
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
    KSMediaConnection *mc        = [[KSMediaConnection alloc] init];
    [mc createPeerConnectionOfKSMediaCapture:mediaCapture];
    mc.delegate                  = self;
    return mc;
}

- (void)onLeaving:(NSNumber *)handleId {
    KSMediaConnection *mc = _connections[handleId];
    if (mc == nil) {
        return;
    }
    [mc close];
    
    [_connections removeObjectForKey:handleId];
    
    if (_connections.count == 1) {
        [self.delegate messageHandlerEndOfSession:self];
    }
}

- (void)closeAllMediaConnection {
    for (KSMediaConnection *mc in _connections.allValues) {
        if (mc) {
            [mc close];
            [_connections removeObjectForKey:mc.handleId];
            [self.delegate messageHandler:self leaveOfHandleId:mc.handleId];
        }
    }
    [self.delegate messageHandlerEndOfSession:self];
}

- (void)close {
    [_socket activeClose];
    [self closeAllMediaConnection];
    [_publisherPeerConnection close];
    
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
/*
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
*/

- (void)mediaConnection:(KSMediaConnection *)mediaConnection peerConnection:(RTCPeerConnection *)peerConnection didAddReceiver:(RTCRtpReceiver *)rtpReceiver streams:(NSArray<RTCMediaStream *> *)mediaStreams {
    RTCMediaStreamTrack *track = rtpReceiver.track;
    if([track.kind isEqualToString:kRTCMediaStreamTrackKindVideo]) {
        RTCVideoTrack *remoteVideoTrack = (RTCVideoTrack*)track;
        dispatch_async(dispatch_get_main_queue(), ^{
            RTCEAGLVideoView *remoteView     = [self.delegate remoteViewOfSectionsInMessageHandler:self handleId:mediaConnection.handleId];
            mediaConnection.remoteVideoView  = remoteView;
            [remoteVideoTrack addRenderer:remoteView];
            mediaConnection.remoteVideoTrack = remoteVideoTrack;
        });
    }
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

//Get
-(KSMediaConnection *)localConnection {
    for (KSMediaConnection *item in _connections.allValues) {
        if (item.isLocal) {
            return item;
        }
    }
    return nil;
}

@end

/*
 下面我们就来看一下，对于两人通讯的情况，信令该如何设计。在我们这个例子中，可以将信令分成两大类。第一类为客户端命令；第二类为服务端命令；

 客户端命令有：
    join: 用户加入房间
    leave: 用户离开房间
    message: 端到端命令（offer、answer、candidate）
 
 服务端命令:
    joined: 用户已加入
    leaved: 用户已离开
    other_joined:其它用户已加入
    bye: 其它用户已离开
    full: 房间已满
 通过以上几条信令就可以实现一对一实时互动的要求，是不是非常的简单？
 
 */


/*
 信令状态机
 在 iOS 端的信令与我们之前介绍的 js端 和 Android 端一样，会通过一个信令状态机来管理。在不同的状态下，需要发不同的信令。同样的，当收到服务端，或对端的信令后，状态会随之发生改变。下面我们来看一下这个状态的变化图吧：

 在初始时，客户端处于 init/leaved 状态。

    在 init/leaved 状态下，用户只能发送 join 消息。服务端收到 join 消息后，会返回 joined 消息。此时，客户端会更新为 joined 状态。
    在 joined 状态下，客户端有多种选择，收到不同的消息会切到不同的状态:
        如果用户离开房间，那客户端又回到了初始状态，即 init/leaved 状态。
        如果客户端收到 second user join 消息，则切换到 join_conn 状态。在这种状态下，两个用户就可以进行通话了。
        如果客户端收到 second user leave 消息，则切换到 join_unbind 状态。其实 join_unbind状态与 joined 状态基本是一致的。
        如果客户端处于 join_conn 状态，当它收到 second user leave 消息时，也会转成 joined_unbind 状态。
        如果客户端是 joined_unbind 状态，当它收到 second user join 消息时，会切到 join_conn 状态。
    通过上面的状态图，我们就非常清楚的知道了在什么状态下应该发什么信令；或者说，发什么样的信令，状态会发生怎样的变化了。
 */

/*
 信令服务器用于交换三种类型的信息：

    会话控制消息：初始化/关闭，各种业务逻辑消息以及错误报告。
    网络相关：外部可以识别的IP地址和端口。
    媒体能力：客户端能控制的编解码器、分辩率，以及它想与谁通讯。
 
 会话控制消息
 会话控制消息比较简单，像房间的创建与销毁、加入房间、离开房间、开启音频/关闭音频、开启视频/关闭视频等等这些都是会话控制消息。
 对于一个真正商业的WebRTC信令服务器，还有许多的会话控制消息。像获取房间人数、静音/取消静音、切换主讲人、视频轮询、白板中的画笔、各种图型等等。但相对来说都是一引起比较简单的消息。
 
 网络信息消息
 网络信息消息用于两个客户端之间交换网络信息。在WebRTC中使用 ICE 机制建立网络连接。
 
 交换媒体能力消息
 在WebRTC中，媒体能力最终通过 SDP 呈现。在传输媒体数据之前，首先要进行媒体能力协商，看双方都支持那些编码方式，支持哪些分辨率等。协商的方法是通过信令服务器交换媒体能力信息。
 */

/*
 媒体协商
 A 与 B 进行通话，通话的发起方，首先要创建 Offer 类型的 SDP 内容。之后调用 RTCPeerConnection 对象的 setLocalDescription 方法，将 Offer 保存到本地。

 紧接着，将 Offer 发送给服务器。然后，通过信令服务器中转到被呼叫方。被呼叫方收到 Offer 后，调用它的 RTCPeerConnection 对象的 setRemoteDescription 方法，将远端的 Offer 保存起来。

 之后，被呼到方创建 Answer 类型的 SDP 内容，并调用 RTCPeerConnection 对象的 setLocalDescription 方法将它存储到本地。

 同样的，它也要将 Answer 发送给服务器。服务器收到该消息后，不做任何处理，直接中转给呼叫方。呼叫方收到 Answer 后，调用 setRemoteDescription 将其保存起来。

 通过上面的步骤，整个媒体协商部分就完成了。
 */
