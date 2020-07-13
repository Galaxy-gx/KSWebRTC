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
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) RTCCameraPreviewView *localView;
@property (nonatomic, strong) KSMessageHandler *msgHandler;
@property (nonatomic, strong) KSMediaCapture *mediaCapture;
@property (nonatomic, strong) NSMutableDictionary *remoteKits;

@property (nonatomic, assign) int kitWidth;
@property (nonatomic, assign) int kitHeight;
@property (nonatomic, assign) int padding;
@property (nonatomic, assign) int topOffset;
@property (nonatomic, assign) BOOL isConnect;
@end

@implementation KSVideoChatController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeKit];
    [self initializeHandler];
}

- (void)initializeHandler {
    _mediaCapture = [[KSMediaCapture alloc] init];
    [_mediaCapture createPeerConnectionFactory];
    [_mediaCapture captureLocalMedia:_localView];
    //[_mediaCapture.videoTrack.source  adaptOutputFormatToWidth:_kitWidth height:_kitHeight fps:25];
    
    _msgHandler = [[KSMessageHandler alloc] init];
    _msgHandler.delegate = self;
}

- (void)initializeKit {
    self.view.backgroundColor = [UIColor whiteColor];
    _remoteKits = [NSMutableDictionary dictionary];
    _padding = 0;
    _topOffset = 24;
    _kitWidth  = self.view.bounds.size.width / 2;
    _kitHeight = self.view.bounds.size.height / 3;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView];
    _scrollView = scrollView;
    
    RTCCameraPreviewView *localView = [[RTCCameraPreviewView alloc] initWithFrame:CGRectMake(0, _topOffset, _kitWidth, _kitHeight)];
    [scrollView addSubview:localView];
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
    if (index == 1) {
        x = _kitWidth + _padding;
        y = _topOffset;
    }
    else {
        if ((index % 2) != 0) {
            x = _kitWidth + _padding;
        }
        y = _topOffset + (index / 2) * _kitHeight + _padding * (index / 2);
    }
    RTCEAGLVideoView *remoteView = [[RTCEAGLVideoView alloc] initWithFrame:CGRectMake(x, y, _kitWidth, _kitHeight)];
    remoteView.delegate = self;
    
    if (y + _kitHeight > self.view.bounds.size.height) {
        _scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, y + _kitHeight);
    }
    [_scrollView addSubview:remoteView];
    return remoteView;
}

- (void)onLeaving:(NSString *)handleId {
    
}

- (void)onConnectClick {
    if (_isConnect) {
        return;
    }
    _isConnect = true;
    [_msgHandler connectServer:@"ws://192.168.9.97:8188"];
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

- (RTCEAGLVideoView *)remoteViewOfSectionsInMessageHandler:(KSMessageHandler *)messageHandler handleId:(NSNumber *)handleId {
    RTCEAGLVideoView *remoteView = NULL;
    if (_remoteKits[handleId] == nil) {
        remoteView = [self createRemoteView];
        _remoteKits[handleId] = remoteView;
    }
    return _remoteKits[handleId];
}

@end

