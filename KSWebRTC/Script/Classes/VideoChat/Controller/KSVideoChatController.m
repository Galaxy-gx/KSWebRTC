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

@interface KSVideoChatController ()<RTCVideoViewDelegate,KSMessageHandlerDelegate>

@property (nonatomic, weak) RTCCameraPreviewView *localView;
@property (nonatomic, strong) KSMessageHandler *msgHandler;
@property (nonatomic, strong) KSMediaCapture *mediaCapture;
@property (nonatomic, strong) NSMutableDictionary *remoteKits;

@property (nonatomic, assign) int kitWidth;
@property (nonatomic, assign) int kitHeight;
@property (nonatomic, assign) BOOL isConnect;
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
    _msgHandler.delegate = self;
}

- (void)initializeKit {
    self.view.backgroundColor = [UIColor whiteColor];
    _remoteKits = [NSMutableDictionary dictionary];
    _kitWidth  = (self.view.bounds.size.width - 30)/2;
    _kitHeight = _kitWidth * (16.0 / 9.0);
    int padding = 10;
    CGFloat topOffset = 64;
    RTCCameraPreviewView *localView = [[RTCCameraPreviewView alloc] initWithFrame:CGRectMake(padding, topOffset, _kitHeight, _kitHeight)];
    [self.view addSubview:localView];
    _localView = localView;
    
    UIColor *btnColor = [UIColor colorWithRed:100/255.0 green:149/255.0 blue:237/255.0 alpha:1];
    UIButton *connectBtn = [UIButton initWithTitle:@"连接"
                                        titleColor:[UIColor whiteColor]
                                              font:[UIFont systemFontOfSize:14]
                                   backgroundColor:btnColor
                                       borderColor:btnColor
                                       borderWidth:2];
    connectBtn.frame = CGRectMake(50, self.view.bounds.size.height - 60, 100, 44);
    
    UIButton *leaveBtn = [UIButton initWithTitle:@"离开"
                                      titleColor:[UIColor whiteColor]
                                            font:[UIFont systemFontOfSize:14]
                                 backgroundColor:btnColor
                                     borderColor:btnColor
                                     borderWidth:2];
    leaveBtn.frame = CGRectMake(self.view.bounds.size.width - 150, connectBtn.frame.origin.y, 100, 44);
    
    [self.view addSubview:connectBtn];
    [self.view addSubview:leaveBtn];
    
    [connectBtn addTarget:self action:@selector(onConnectClick) forControlEvents:UIControlEventTouchUpInside];
    [leaveBtn addTarget:self action:@selector(onLeaveClick) forControlEvents:UIControlEventTouchUpInside];
}

- (RTCEAGLVideoView *)createRemoteView {
    int index = (int)_remoteKits.count + 1;
    int x = 0;
    int y = 0;
    if (index < 2) {
        x = _kitWidth * index;
    } else if (index < 4) {
        x = _kitWidth * (index - 2);
        y = _kitHeight;
    } else {
        x = _kitWidth * (index - 3);
        y = _kitHeight * 2;
    }

    RTCEAGLVideoView *remoteView = [[RTCEAGLVideoView alloc] initWithFrame:CGRectMake(x, y, _kitWidth, _kitHeight)];
    remoteView.delegate = self;
    [self.view addSubview:remoteView];
    return remoteView;
}

- (void)onLeaving:(NSString *)handleId {
    
}

- (void)onConnectClick {
    if (_isConnect) {
        return;
    }
    _isConnect = true;
    [_msgHandler connectServer:@"ws://192.168.9.18:8188"];
}

- (void)onLeaveClick {
    
}

//RTCVideoViewDelegate
- (void)videoView:(nonnull id<RTCVideoRenderer>)videoView didChangeVideoSize:(CGSize)size {
    
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
    
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
    
}

- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    return CGSizeMake(_kitWidth, _kitHeight);
}

- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
    
}

- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
    
}

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
    
}

- (void)setNeedsFocusUpdate {
    
}

- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
    return true;
}

- (void)updateFocusIfNeeded {
    
}

//KSMessageHandlerDelegate
- (KSMediaCapture *)mediaCaptureOfSectionsInMessageHandler:(KSMessageHandler *)messageHandler {
    return _mediaCapture;
}

- (void)messageHandler:(KSMessageHandler *)messageHandler didReceivedMessage:(KSMsg *)message {
    
}

- (RTCEAGLVideoView *)remoteViewOfSectionsInMessageHandler:(KSMessageHandler *)messageHandler handleId:(NSString *)handleId {
    RTCEAGLVideoView *remoteView = NULL;
    if (_remoteKits[handleId] == nil) {
        remoteView = [self createRemoteView];
        _remoteKits[handleId] = remoteView;
    }
    return _remoteKits[handleId];
}

@end

