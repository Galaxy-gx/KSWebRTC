//
//  ARDAppClient.h
//  KSWebRTC
//
//  Created by saeipi on 2020/7/21.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebRTC/RTCPeerConnection.h>
#import <WebRTC/RTCVideoTrack.h>

@class ARDAppClient;
@class ARDSettingsModel;
@class ARDExternalSampleCapturer;
@class RTCMediaConstraints;
@class RTCCameraVideoCapturer;
@class RTCFileVideoCapturer;

typedef NS_ENUM(NSInteger, ARDAppClientState) {
  // Disconnected from servers.
  kARDAppClientStateDisconnected,
  // Connecting to servers.
  kARDAppClientStateConnecting,
  // Connected to servers.
  kARDAppClientStateConnected,
};

@protocol ARDAppClientDelegate <NSObject>

- (void)appClient:(ARDAppClient *)client didChangeState:(ARDAppClientState)state;

- (void)appClient:(ARDAppClient *)client didChangeConnectionState:(RTCIceConnectionState)state;

- (void)appClient:(ARDAppClient *)client didCreateLocalCapturer:(RTCCameraVideoCapturer *)localCapturer;

- (void)appClient:(ARDAppClient *)client didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack;

- (void)appClient:(ARDAppClient *)client didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack;

- (void)appClient:(ARDAppClient *)client didError:(NSError *)error;

- (void)appClient:(ARDAppClient *)client didGetStats:(NSArray *)stats;

@optional
- (void)appClient:(ARDAppClient *)client
    didCreateLocalFileCapturer:(RTCFileVideoCapturer *)fileCapturer;

- (void)appClient:(ARDAppClient *)client
    didCreateLocalExternalSampleCapturer:(ARDExternalSampleCapturer *)externalSampleCapturer;

@end

@interface ARDAppClient : NSObject

// If |shouldGetStats| is true, stats will be reported in 1s intervals through
// the delegate.
@property(nonatomic, assign) BOOL shouldGetStats;
@property(nonatomic, assign) ARDAppClientState state;
@property(nonatomic, weak) id<ARDAppClientDelegate> delegate;
@property(nonatomic, assign, getter=isBroadcast) BOOL broadcast;

// Convenience constructor since all expected use cases will need a delegate
// in order to receive remote tracks.
- (instancetype)initWithDelegate:(id<ARDAppClientDelegate>)delegate;

// Establishes a connection with the AppRTC servers for the given room id.
// |settings| is an object containing settings such as video codec for the call.
// If |isLoopback| is true, the call will connect to itself.
- (void)connectToRoomWithId:(NSString *)roomId settings:(ARDSettingsModel *)settings isLoopback:(BOOL)isLoopback;

// Disconnects from the AppRTC servers and any connected clients.
- (void)disconnect;

@end
