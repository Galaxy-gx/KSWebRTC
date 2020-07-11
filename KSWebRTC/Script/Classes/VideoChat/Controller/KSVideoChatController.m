//
//  KSVideoChatController.m
//  KSWebRTC
//
//  Created by saeipi on 2020/7/10.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSVideoChatController.h"
#import <WebRTC/WebRTC.h>
#import "UIButton+Category.h"
#import "KSMessageHandler.h"
#import "KSMediaCapture.h"

@interface KSVideoChatController ()

@property (nonatomic, weak) RTCCameraPreviewView *localView;
@property (nonatomic, weak) RTCEAGLVideoView *remoteView;
@property (nonatomic, strong) KSMessageHandler *msgHandler;
@property (nonatomic, strong) KSMediaCapture *mediaCapture;
@end

@implementation KSVideoChatController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeKit];
    [self initializeHandler];
    
    // Do any additional setup after loading the view.
}

- (void)initializeHandler {
    _mediaCapture = [[KSMediaCapture alloc] init];
    [_mediaCapture createPeerConnectionFactory];
    [_mediaCapture captureLocalMedia:_localView];
    
    _msgHandler = [[KSMessageHandler alloc] init];
    [_msgHandler connectServer:@"wss://127.0.0.1:8188"];
}

- (void)initializeKit {
    CGFloat layerWidth              = 180;
    CGFloat layerHeight             = 320;
    CGFloat layerX                  = self.view.bounds.size.width - layerWidth - 10;
    CGFloat layerY                  = 64;
    RTCCameraPreviewView *localView = [[RTCCameraPreviewView alloc] initWithFrame:CGRectMake(layerX, layerY, layerWidth, layerHeight)];
    RTCEAGLVideoView *remoteView    = [[RTCEAGLVideoView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:remoteView];
    [self.view addSubview:localView];
    _localView                      = localView;
    _remoteView                     = remoteView;
    
    UIButton *connectBtn = [UIButton initWithTitle:@"连接"
                                        titleColor:[UIColor whiteColor]
                                              font:[UIFont systemFontOfSize:14]
                                   backgroundColor:[UIColor blueColor]
                                       borderColor:[UIColor blueColor]
                                       borderWidth:2];
    
    UIButton *leaveBtn = [UIButton initWithTitle:@"连接"
                                      titleColor:[UIColor whiteColor]
                                            font:[UIFont systemFontOfSize:14]
                                 backgroundColor:[UIColor blueColor]
                                     borderColor:[UIColor blueColor]
                                     borderWidth:2];
    
    [self.view addSubview:connectBtn];
    [self.view addSubview:leaveBtn];
    
    [connectBtn addTarget:self action:@selector(onConnectClick) forControlEvents:UIControlEventTouchUpInside];
    [leaveBtn addTarget:self action:@selector(onLeaveClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)onConnectClick {
    
}

- (void)onLeaveClick {
    
}

@end
