//
//  KSMessage.h
//  KSWebRTC
//
//  Created by saeipi on 2020/7/10.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, KSMessageType) {
    KSMessageTypeCreate,//创建一个janus会话命令
    KSMessageTypeSuccess,//一个命令的成功结果
    KSMessageTypeError,//一个命令的失败结果
    KSMessageTypeAttach,//附加一个插件到janus会话命令
    KSMessageTypeMessage,//客户端发送的插件消息。message和event构成了应用协议
    KSMessageTypeAck,//一个命令的ack，因为不能直接返回结果，先回ack，后续的结果通过event返回
    KSMessageTypeEvent,//推送给客户端的异步事件，主要由插件发出，这些事件需要插件来自己定义
    KSMessageTypeTrickle,//客户端发送的候选人，会传递给ICE句柄
    KSMessageTypeMedia,//音频、视频媒体的接收通知
    KSMessageTypeWebrtcup,//ICE成功建立通道的通知
    KSMessageTypeKeepalive,//客户端发送的心跳
    KSMessageTypeSlowlink,//链路恶化通知
    KSMessageTypeHangup,//挂断通知
    KSMessageTypeDetached,//插件从janus会话分离的通知
    KSMessageTypeUnknown
};

//ACK
@interface KSMsg : NSObject
// ack/keepalive/webrtcup/
@property(nonatomic,assign)KSMessageType msgType;
@property(nonatomic,copy)NSString *transaction;
@property(nonatomic,copy)NSString *session_id;
@property(nonatomic,copy)NSString *handle_id;
@property(nonatomic,copy)NSString *janus;

+ (KSMessageType)typeForMsg:(NSDictionary *)msg;
+ (KSMsg *)deserializeForMsg:(NSDictionary *)msg;

@end
//ACK
@interface KSPublishers : NSObject
@property(nonatomic,copy)NSString *ID;//!
@property(nonatomic,copy)NSString *display;
@property(nonatomic,copy)NSString *audio_codec;
@property(nonatomic,copy)NSString *video_codec;
@property(nonatomic,assign)BOOL talking;
@end
//ACK
@interface KSMessageData : NSObject
@property(nonatomic,copy)NSString *videoroom;
@property(nonatomic,copy)NSString *room;
@property(nonatomic,copy)NSString *Description;
@property(nonatomic,copy)NSString *ID;//!
@property(nonatomic,copy)NSString *private_id;
//@property(nonatomic,copy)NSString *display;
@property(nonatomic,strong)NSArray *publishers;
@property(nonatomic,assign)BOOL started;
@end

//ACK
@interface KSSuccess : KSMsg
@property(nonatomic,copy)KSMessageData *data;
@end

//Request
@interface KSAttach : KSMsg
@property(nonatomic,copy)NSString *opaque_id;
@property(nonatomic,copy)NSString *plugin;//插件
@end

//ACK
@interface KSPlugindata : NSObject
@property(nonatomic,copy)NSString *plugin;
@property(nonatomic,strong)KSMessageData *data;
@end

//ACK
@interface KSJsep : NSObject
@property(nonatomic,copy)NSString *type;
@property(nonatomic,copy)NSString *sdp;

@end
//ACK
@interface KSEvent : KSMsg
@property(nonatomic,copy)NSString *sender;
@property(nonatomic,strong)KSPlugindata *plugindata;
@property(nonatomic,strong)KSJsep *jsep;
@end

//Request
@interface KSBody : NSObject
@property(nonatomic,copy)NSString *ptype;//publisher
@property(nonatomic,copy)NSString *display;
@property(nonatomic,assign)int feed;
@property(nonatomic,copy)NSString *room;
@property(nonatomic,copy)NSString *request;//join
@property(nonatomic,copy)NSString *private_id;
@property(nonatomic,assign)BOOL audio;
@property(nonatomic,assign)BOOL video;
@end

//Request
@interface KSMessage : KSMsg
@property(nonatomic,strong)KSBody *body;
@end

//ACK
@interface KSWebrtcup : KSMsg
@property(nonatomic,copy)NSString *sender;
@end

@interface KSCandidate : NSObject
@property(nonatomic,assign)int sdpMLineIndex;
@property(nonatomic,copy)NSString *candidate;
@property(nonatomic,copy)NSString *sdpMid;
@end

@interface KSTrickle : KSMsg
@property(nonatomic,strong)KSCandidate *candidate;
@end

//ACK
@interface KSMedia : KSMsg
@property(nonatomic,copy)NSString *sender;
@property(nonatomic,assign)BOOL receiving;
@end
