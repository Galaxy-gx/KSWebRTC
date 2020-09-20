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
#import "KSMediaTrack.h"
#import "KSUserInfo.h"
#import "KSMsg.h"

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

@protocol KSMessageHandlerDelegate<NSObject>
@required
- (KSMediaConnection *)peerConnectionOfMessageHandler:(KSMessageHandler *)messageHandler handleId:(NSNumber *)handleId;
- (KSCallType)callTypeOfMessageHandler:(KSMessageHandler *)messageHandler;
- (void)messageHandler:(KSMessageHandler *)messageHandler socketDidOpen:(KSWebSocket *)socket;
- (void)messageHandler:(KSMessageHandler *)messageHandler socketDidFail:(KSWebSocket *)socket;
@end

@interface KSMessageHandler : NSObject<KSWebSocketDelegate>

@property (nonatomic, weak)id<KSMessageHandlerDelegate> delegate;
@property (nonatomic,strong ) KSWebSocket *socket;
@property (nonatomic,assign ) KSCallType  myType;

- (void)connectServer:(NSString *)url;

//创建会话
- (void)createSession;
- (void)createRoom:(int)room;
- (void)joinRoom:(int)room;
- (void)leave;
- (void)sendMessage:(NSMutableDictionary *)message type:(NSString *)type;
- (void)sendCandidate:(NSDictionary *)candidate;
- (void)close;

@end
