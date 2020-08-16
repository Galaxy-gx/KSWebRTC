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

@protocol KSMessageHandlerDelegate <NSObject>

@required
- (KSMediaConnection *)messageHandler:(KSMessageHandler *)messageHandler connectionOfHandleId:(NSNumber *)handleId;
- (KSMediaConnection *)messageHandlerOfLocalConnection;
- (KSConnectionSetting *)messageHandlerOfConnectionSetting;
- (KSMediaCapturer *)mediaCaptureOfSectionsInMessageHandler:(KSMessageHandler *)messageHandler;

@optional
- (void)messageHandler:(KSMessageHandler *)messageHandler didReceivedMessage:(KSMsg *)message;
- (void)messageHandler:(KSMessageHandler *)messageHandler leaveOfHandleId:(NSNumber *)handleId;
- (void)messageHandler:(KSMessageHandler *)messageHandler socketDidOpen:(KSWebSocket *)socket;
- (void)messageHandler:(KSMessageHandler *)messageHandler socketDidFail:(KSWebSocket *)socket;
- (void)messageHandler:(KSMessageHandler *)messageHandler didAddMediaConnection:(KSMediaConnection *)connection;

@end

@interface KSMessageHandler : NSObject<KSMediaConnectionDelegate>

@property (nonatomic, weak)id<KSMessageHandlerDelegate> delegate;
@property (nonatomic, assign )KSCallState callState;
//@property (nonatomic, readonly) KSMediaConnection *localConnection;

- (void)connectServer:(NSString *)url;
- (void)analysisMsg:(id)message;

//创建会话
- (void)createSession;
//离开
- (void)requestHangup;

- (void)close;

@end
