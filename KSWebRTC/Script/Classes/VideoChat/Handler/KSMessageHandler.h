//
//  KSMessageHandler.h
//  KSWebRTC
//
//  Created by saeipi on 2020/7/10.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>
@class KSMsg;
@class KSMessageHandler;
@class KSMediaCapture;
@class KSDetached;

@protocol KSMessageHandlerDelegate <NSObject>
- (void)messageHandler:(KSMessageHandler *)messageHandler didReceivedMessage:(KSMsg *)message;
- (void)messageHandler:(KSMessageHandler *)messageHandler detached:(KSDetached *)detached;
- (KSMediaCapture *)mediaCaptureOfSectionsInMessageHandler:(KSMessageHandler *)messageHandler;
- (RTCEAGLVideoView *)remoteViewOfSectionsInMessageHandler:(KSMessageHandler *)messageHandler handleId:(NSNumber *)handleId;
@end

@interface KSMessageHandler : NSObject

@property (nonatomic, weak) id<KSMessageHandlerDelegate> delegate;

- (void)connectServer:(NSString *)url;
- (void)analysisMsg:(id)message;

//创建会话
-(void)createSession;

@end
