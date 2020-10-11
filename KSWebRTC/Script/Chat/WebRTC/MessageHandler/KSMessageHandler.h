//
//  KSMessageHandler.h
//  KSWebRTC
//
//  Created by saeipi on 2020/9/26.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSWebSocket.h"
#import "KSLogicMsg.h"
#import "KSUserInfo.h"
@class KSMessageHandler;
@protocol KSMessageHandlerDelegate<NSObject>
- (KSCallType)callTypeOfMessageHandler:(KSMessageHandler *)messageHandler;
@optional
- (void)messageHandler:(KSMessageHandler *)messageHandler didReceivedMessage:(KSLogicMsg *)message;

@end

@interface KSMessageHandler : NSObject
@property (nonatomic, weak)id<KSMessageHandlerDelegate> delegate;
@property (nonatomic,strong ) KSWebSocket *socket;
@property (nonatomic,assign ) KSCallType  myType;
@property (nonatomic,strong ) KSUserInfo  *user;

- (void)connectServer:(NSString *)url;
- (void)callToUserId:(long long)userId room:(int)room;
- (void)answerOfTime:(int)time;
- (void)leave;
@end
