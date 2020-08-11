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

@class KSMsg;
@class KSMessageHandler;
@class KSMediaCapture;
@class KSDetached;

@protocol KSMessageHandlerDelegate <NSObject>
@required
//会话结束
- (void)messageHandlerEndOfSession:(KSMessageHandler *)messageHandler;

@optional
- (void)messageHandler:(KSMessageHandler *)messageHandler didReceivedMessage:(KSMsg *)message;
- (void)messageHandler:(KSMessageHandler *)messageHandler leaveOfHandleId:(NSNumber *)handleId;
- (KSMediaCapture *)mediaCaptureOfSectionsInMessageHandler:(KSMessageHandler *)messageHandler;
- (RTCEAGLVideoView *)remoteViewOfSectionsInMessageHandler:(KSMessageHandler *)messageHandler handleId:(NSNumber *)handleId;
@end

@interface KSMessageHandler : NSObject

@property (nonatomic, weak) id<KSMessageHandlerDelegate> delegate;
@property (nonatomic, assign) KSCallState callState;
@property (nonatomic, readonly) KSMediaConnection *localConnection;

- (void)connectServer:(NSString *)url;
- (void)analysisMsg:(id)message;

//创建会话
- (void)createSession;
//离开
- (void)requestHangup;

- (void)close;
@end
