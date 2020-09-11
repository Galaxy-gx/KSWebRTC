//
//  KSMessageHandler.h
//  KSWebRTC
//
//  Created by saeipi on 2020/7/10.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>
#import "KSCallState.h"
#import "KSMediaConnection.h"
#import "KSWebSocket.h"
#import "KSAckMessage.h"
#import "KSMediaTrack.h"

@class KSMsg;
@class KSMessageHandler;
@class KSMediaCapturer;
@class KSDetached;

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

@protocol KSMessageHandlerDelegate <NSObject>
@required
- (KSMediaConnection *)peerConnectionOfMessageHandler:(KSMessageHandler *)messageHandler handleId:(NSNumber *)handleId sdp:(NSString *)sdp;
- (KSMediaConnection *)localPeerConnectionOfMessageHandler:(KSMessageHandler *)messageHandler;
@optional
- (void)messageHandler:(KSMessageHandler *)messageHandler didReceivedMessage:(KSMsg *)message;
- (void)messageHandler:(KSMessageHandler *)messageHandler socketDidOpen:(KSWebSocket *)socket;
- (void)messageHandler:(KSMessageHandler *)messageHandler socketDidFail:(KSWebSocket *)socket;
- (void)messageHandler:(KSMessageHandler *)messageHandler didReceiveOffer:(NSDictionary *)offer;
- (void)messageHandler:(KSMessageHandler *)messageHandler didReceiveAnswer:(NSDictionary *)answer;
- (void)messageHandler:(KSMessageHandler *)messageHandler addIceCandidate:(NSDictionary *)candidate;
- (void)messageHandler:(KSMessageHandler *)messageHandler requestError:(KSRequestError *)error;

@end

@interface KSMessageHandler : NSObject

@property (nonatomic, weak)id<KSMessageHandlerDelegate> delegate;
@property (nonatomic, copy) NSString *peerId;

- (void)connectServer:(NSString *)url;
- (void)analysisMsg:(id)message;
- (void)sendPayload:(NSDictionary *)payload;
- (void)trickleCandidate:(NSMutableDictionary *)candidate;


//创建会话
- (void)createSession;
- (void)sendOffer;

- (void)sendMessage:(NSMutableDictionary *)message type:(NSString *)type;
// 发送候选者
- (void)sendOfferPayload:(NSDictionary *)payload;
- (void)sendAnswerPayload:(NSDictionary *)payload;
///ice更新
- (void)sendCandidate:(NSDictionary *)candidate;

- (void)close;

///呼叫
- (void)callToPeerId:(int)peerId type:(KSCallType)type;

/// 响铃
- (void)ringed;
///接听
- (void)answoerOfCallType:(KSCallType)callType;
/////开始通话
- (void)start;

///加入聊天
- (void)joinWithOffer:(NSString *)offer;

///离开
- (void)leave;

- (void)didReceivedMessage:(NSDictionary *)message;

- (void)sendOffer:(NSDictionary *)offer;
- (void)sendAnswer:(NSDictionary *)answer;
- (void)handlerRemoteJsep:(NSDictionary *)jsep;

//测试
- (void)startFlag;
@end
