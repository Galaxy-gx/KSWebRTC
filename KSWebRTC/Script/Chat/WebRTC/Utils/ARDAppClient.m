//
//  ARDAppClient.m
//  KSWebRTC
//
//  Created by saeipi on 2020/7/21.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "ARDAppClient.h"
#import "ARDSignalingChannel.h"
#import "ARDRoomServerClient.h"
#import "ARDTURNClient.h"
#import "ARDSettingsModel.h"

#import <WebRTC/RTCFileLogger.h>
#import <WebRTC/RTCDefaultVideoDecoderFactory.h>
#import <WebRTC/RTCDefaultVideoEncoderFactory.h>
#import <WebRTC/RTCPeerConnectionFactory.h>
#import <WebRTC/RTCDefaultVideoEncoderFactory.h>

static NSString * const kARDIceServerRequestUrl = @"https://appr.tc/params";
static NSString * const kARDAppClientErrorDomain = @"ARDAppClient";
static NSInteger const kARDAppClientErrorUnknown = -1;
static NSInteger const kARDAppClientErrorRoomFull = -2;
static NSInteger const kARDAppClientErrorCreateSDP = -3;
static NSInteger const kARDAppClientErrorSetSDP = -4;
static NSInteger const kARDAppClientErrorInvalidClient = -5;
static NSInteger const kARDAppClientErrorInvalidRoom = -6;
static NSString * const kARDMediaStreamId = @"ARDAMS";
static NSString * const kARDAudioTrackId = @"ARDAMSa0";
static NSString * const kARDVideoTrackId = @"ARDAMSv0";
static NSString * const kARDVideoTrackKind = @"video";

static BOOL const kARDAppClientEnableTracing = NO;
static BOOL const kARDAppClientEnableRtcEventLog = YES;
static int64_t const kARDAppClientAecDumpMaxSizeInBytes = 5e6;  // 5 MB.
static int64_t const kARDAppClientRtcEventLogMaxSizeInBytes = 5e6;  // 5 MB.

static int const kKbpsMultiplier = 1000;


@interface ARDAppClient()

@property(nonatomic,strong)RTCFileLogger *fileLogger;

@property(nonatomic, strong) ARDRoomServerClient *roomServerClient;
@property(nonatomic, strong) ARDSignalingChannel *channel;
@property(nonatomic, strong) ARDSignalingChannel *loopbackChannel;
@property(nonatomic, strong) ARDTURNClient *turnClient;

@property(nonatomic, strong) RTCPeerConnection * peerConnection;
@property(nonatomic, strong) RTCPeerConnectionFactory * factory;
@property(nonatomic, strong) NSMutableArray *messageQueue;

@property(nonatomic, assign) BOOL isTurnComplete;
@property(nonatomic, assign) BOOL hasReceivedSdp;
@property(nonatomic, readonly) BOOL hasJoinedRoomServerRoom;

@property(nonatomic, strong) NSString *roomId;
@property(nonatomic, strong) NSString *clientId;
@property(nonatomic, assign) BOOL isInitiator;
@property(nonatomic, strong) NSMutableArray *iceServers;
@property(nonatomic, strong) NSURL *webSocketURL;
@property(nonatomic, strong) NSURL *webSocketRestURL;
@property(nonatomic, readonly) BOOL isLoopback;


@property(nonatomic, strong) ARDSettingsModel *settings;

@end
@implementation ARDAppClient

- (instancetype)initWithRoomServerClient:(ARDRoomServerClient *)rsClient
                        signalingChannel:(ARDSignalingChannel *)channel
                              turnClient:(ARDTURNClient *)turnClient
                                delegate:(id<ARDAppClientDelegate>)delegate {
  NSParameterAssert(rsClient);
  NSParameterAssert(channel);
  NSParameterAssert(turnClient);
  if (self = [super init]) {
    _roomServerClient = rsClient;
    _channel = channel;
    _turnClient = turnClient;
    _delegate = delegate;
    [self configure];
  }
  return self;
}

- (void)configure {
  _messageQueue = [NSMutableArray array];
  _iceServers = [NSMutableArray array];
  _fileLogger = [[RTCFileLogger alloc] init];
  [_fileLogger start];
}

- (void)dealloc {
  self.shouldGetStats = NO;
  [self disconnect];
}

- (void)disconnect {

}

- (void)connectToRoomWithId:(NSString *)roomId settings:(ARDSettingsModel *)settings isLoopback:(BOOL)isLoopback {
    NSParameterAssert(roomId.length);
    NSParameterAssert(_state == kARDAppClientStateDisconnected);
    _settings = settings;
    _isLoopback = isLoopback;
    self.state = kARDAppClientStateConnecting;
    
    RTCDefaultVideoDecoderFactory *decoderFactory = [[RTCDefaultVideoDecoderFactory alloc] init];
    RTCDefaultVideoEncoderFactory *encoderFactory = [[RTCDefaultVideoEncoderFactory alloc] init];
    encoderFactory.preferredCodec = [settings currentVideoCodecSettingFromStore];
    _factory = [[RTCPeerConnectionFactory alloc] initWithEncoderFactory:encoderFactory decoderFactory:decoderFactory];
    
}
@end
