//
//  KSVideoCallController.m
//  KSWebRTC
//
//  Created by saeipi on 2020/7/20.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSVideoCallController.h"
#import "KSVideoCallView.h"
#import <WebRTC/RTCAudioSession.h>
#import "KSMessageHandler.h"
#import "KSMediaCapture.h"
#import "KSMsg.h"
#import "UIButton+Category.h"
@interface KSVideoCallController ()<KSVideoCallViewDelegate,KSMessageHandlerDelegate>

@property(nonatomic, weak) KSVideoCallView *videoCallView;
@property (nonatomic, strong) KSMessageHandler *msgHandler;
@property (nonatomic, strong) KSMediaCapture *mediaCapture;
@property (nonatomic, assign) BOOL isConnect;
@end

@implementation KSVideoCallController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initKit];
    [self initProperty];
}

- (void)initProperty {
    _mediaCapture = [[KSMediaCapture alloc] init];
    [_mediaCapture createPeerConnectionFactory];
    AVCaptureSession *captureSession = [_mediaCapture captureLocalMedia];
    
    [_videoCallView setLocalViewSession:captureSession];
    
    _msgHandler = [[KSMessageHandler alloc] init];
    _msgHandler.delegate = self;
}

- (void)initKit {
    KSVideoCallView *videoCallView = [[KSVideoCallView alloc] initWithFrame:self.view.bounds];
    videoCallView.delegate = self;
    _videoCallView = videoCallView;
    [self.view addSubview:videoCallView];
    
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

- (void)onConnectClick {
    if (_isConnect) {
        return;
    }
    _isConnect = true;
    [_msgHandler connectServer:@"ws://192.168.9.96:8188"];
}

- (void)onLeaveClick {
    
}

//KSMessageHandlerDelegate
- (void)messageHandler:(KSMessageHandler *)messageHandler didReceivedMessage:(KSMsg *)message {
    
}

- (void)messageHandler:(KSMessageHandler *)messageHandler detached:(KSDetached *)detached {
    [_videoCallView leaveOfHandleId:detached.sender];
}

- (KSMediaCapture *)mediaCaptureOfSectionsInMessageHandler:(KSMessageHandler *)messageHandler {
    return _mediaCapture;
}

- (RTCEAGLVideoView *)remoteViewOfSectionsInMessageHandler:(KSMessageHandler *)messageHandler handleId:(NSNumber *)handleId {
    return [_videoCallView remoteViewOfHandleId:handleId];
}


//KSVideoCallViewDelegate
- (void)videoCallViewDidChangeRoute:(KSVideoCallView *)view {
    
}

- (void)videoCallViewDidEnableStats:(KSVideoCallView *)view {
    
}

- (void)videoCallViewDidHangup:(KSVideoCallView *)view {
    
}

- (void)videoCallViewDidSwitchCamera:(KSVideoCallView *)view {
    
}

//KSMessageHandlerDelegate
- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
    
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
    
}

- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    return CGSizeZero;
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
    return YES;
}

- (void)updateFocusIfNeeded {
    
}

@end
