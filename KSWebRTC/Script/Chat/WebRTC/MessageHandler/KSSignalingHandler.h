//
//  KSSignalingHandler.h
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
@class KSSignalingHandler;
@class KSMediaCapturer;
@class KSDetached;

typedef NS_ENUM(NSInteger, KSActionType) {
    KSActionTypeUnknown,
    KSActionTypeCreateSession,
    KSActionTypePluginBinding,
    KSActionTypePluginBindingSubscriber,
    KSActionTypeCreateRoom,
    KSActionTypeJoinRoom,
    KSActionTypeConfigureRoom,
    KSActionTypeSubscriber,
    KSActionTypeStart,
};

@protocol KSSignalingHandlerDelegate<NSObject>
@required
- (KSMediaConnection *)localPeerConnectionOfSignalingHandler:(KSSignalingHandler *)signalingHandler handleId:(NSNumber *)handleId;
- (KSMediaConnection *)peerConnectionOfSignalingHandler:(KSSignalingHandler *)signalingHandler handleId:(NSNumber *)handleId;
- (KSCallType)callTypeOfSignalingHandler:(KSSignalingHandler *)signalingHandler;
- (void)signalingHandler:(KSSignalingHandler *)signalingHandler socketDidOpen:(KSWebSocket *)socket;
- (void)signalingHandler:(KSSignalingHandler *)signalingHandler socketDidFail:(KSWebSocket *)socket;
- (void)signalingHandler:(KSSignalingHandler *)signalingHandler requestError:(KSMsg *)message;
@end

@interface KSSignalingHandler : NSObject<KSWebSocketDelegate>

@property (nonatomic, weak)id<KSSignalingHandlerDelegate> delegate;
@property (nonatomic,strong ) KSWebSocket *socket;
@property (nonatomic,assign ) KSCallType  myType;

- (void)setRoomMumber:(int)room;
- (void)connectServer:(NSString *)url;

//创建会话
- (void)sendMessage:(NSMutableDictionary *)message type:(NSString *)type;
- (void)sendCandidate:(NSMutableDictionary *)candidate;
- (void)close;

@end
