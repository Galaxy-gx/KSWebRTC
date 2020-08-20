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
- (KSMediaConnection *)messageHandlerOfLocalConnection;

@optional
- (void)messageHandler:(KSMessageHandler *)messageHandler didReceivedMessage:(KSMsg *)message;
- (void)messageHandler:(KSMessageHandler *)messageHandler socketDidOpen:(KSWebSocket *)socket;
- (void)messageHandler:(KSMessageHandler *)messageHandler socketDidFail:(KSWebSocket *)socket;
- (void)messageHandler:(KSMessageHandler *)messageHandler didReceiveOffer:(NSDictionary *)offer;
- (void)messageHandler:(KSMessageHandler *)messageHandler didReceiveAnswer:(NSDictionary *)answer;
- (void)messageHandler:(KSMessageHandler *)messageHandler addIceCandidate:(NSDictionary *)candidate;

@end

@interface KSMessageHandler : NSObject

@property (nonatomic, weak)id<KSMessageHandlerDelegate> delegate;

- (void)connectServer:(NSString *)url;
- (void)analysisMsg:(id)message;

//创建会话
- (void)createSession;
- (void)sendOffer;

// 发送候选者
- (void)trickleCandidate:(NSMutableDictionary *)candidate;
- (void)sendPayload:(NSDictionary *)payload;
- (void)close;

@end
