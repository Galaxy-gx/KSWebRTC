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
#import "KSEAGLVideoView.h"
#import "KSLocalView.h"
#import "KSMsg.h"

@interface KSVideoChatController ()<RTCVideoViewDelegate,KSMessageHandlerDelegate>
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) KSLocalView *localView;
@property (nonatomic, strong) NSMutableArray *remoteKits;
@property (nonatomic, strong) KSMessageHandler *msgHandler;
@property (nonatomic, strong) KSMediaCapture *mediaCapture;

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
    //创建本地流
    AVCaptureSession *captureSession = [_mediaCapture captureLocalMedia];
    [_localView setLocalViewSession:captureSession];
    _msgHandler = [[KSMessageHandler alloc] init];
    _msgHandler.delegate = self;
}

- (void)initializeKit {
    self.view.backgroundColor = [UIColor whiteColor];
    _remoteKits = [NSMutableArray array];
    _padding = 0;
    _topOffset = 24;
    _kitWidth  = 160;//self.view.bounds.size.width / 2;
    _kitHeight = 213;//self.view.bounds.size.height / 3;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView];
    _scrollView = scrollView;
    
    KSLocalView *localView = [[KSLocalView alloc] initWithFrame:CGRectMake(0, _topOffset, _kitWidth, _kitHeight) resizingMode:KSResizingModeTile];
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

- (RTCEAGLVideoView *)createRemoteViewOfHandleId:(NSNumber *)handleId {
    CGPoint point= [self remotePointOfIndex:(int)_remoteKits.count + 1];
    KSEAGLVideoView *remoteView = [[KSEAGLVideoView alloc] initWithFrame:CGRectMake(point.x, point.y, _kitWidth, _kitHeight)];
    remoteView.delegate = self;
    remoteView.handleId = handleId;
    if (point.y + _kitHeight > self.view.bounds.size.height) {
        _scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, point.y + _kitHeight);
    }
    [_scrollView addSubview:remoteView];
    [_remoteKits addObject:remoteView];
    return remoteView;
}

-(void)layoutRemoteViews {
    for (int index = 1; index <= _remoteKits.count; index++) {
        CGPoint point= [self remotePointOfIndex:(int)_remoteKits.count + 1];
        KSEAGLVideoView *remoteView = _remoteKits[index];
        remoteView.frame = CGRectMake(point.x, point.y, _kitWidth, _kitHeight);
    }
    if (_remoteKits.lastObject) {
        KSEAGLVideoView *remoteView = _remoteKits.lastObject;
        if (remoteView.frame.origin.y + _kitHeight > self.view.bounds.size.height) {
            _scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, remoteView.frame.origin.y + _kitHeight);
        }
    }
}

-(CGPoint)remotePointOfIndex:(int)index {
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
    return CGPointMake(x, y);
}

- (void)onConnectClick {
    if (_isConnect) {
        return;
    }
    _isConnect = true;
    [_msgHandler connectServer:@"ws://10.0.115.144:8188"];
}

- (void)onLeaveClick {
    [_mediaCapture switchTalkMode];
}

//RTCVideoViewDelegate
- (void)videoView:(nonnull id<RTCVideoRenderer>)videoView didChangeVideoSize:(CGSize)size {
    /*
     if (size.width > 0 && size.height > 0) {
     RTCEAGLVideoView *remoteView = (RTCEAGLVideoView *)videoView;
     CGRect bounds = remoteView.bounds;
     CGRect videoFrame = AVMakeRectWithAspectRatioInsideRect(size, remoteView.bounds);
     CGFloat scale = 1;
     if (videoFrame.size.width > videoFrame.size.height) {
     scale = bounds.size.height / videoFrame.size.height;
     }
     else{
     scale = bounds.size.width / videoFrame.size.width;
     }
     videoFrame.size.height *= scale;
     videoFrame.size.width *= scale;
     [remoteView setBounds:CGRectMake(0, 0, videoFrame.size.width, videoFrame.size.height)];
     [remoteView setCenter:CGPointMake(remoteView.center.x + (videoFrame.size.width - bounds.size.width)*0.5,
     remoteView.center.y + (videoFrame.size.height - bounds.size.height) * 0.5)];
     }*/
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
- (void)messageHandler:(KSMessageHandler *)messageHandler didReceivedMessage:(KSMsg *)message {
    
}

- (void)messageHandler:(KSMessageHandler *)messageHandler detached:(KSDetached *)detached {
    for (KSEAGLVideoView *videoView in _remoteKits) {
        if (videoView.handleId == detached.sender) {
            [_remoteKits removeObject:videoView];
            break;
        }
    }
    [self layoutRemoteViews];
}

- (KSMediaCapture *)mediaCaptureOfSectionsInMessageHandler:(KSMessageHandler *)messageHandler {
    return _mediaCapture;
}

- (RTCEAGLVideoView *)remoteViewOfSectionsInMessageHandler:(KSMessageHandler *)messageHandler handleId:(NSNumber *)handleId {
    for (KSEAGLVideoView *videoView in _remoteKits) {
        if (videoView.handleId == handleId) {
            return videoView;
        }
    }
    return [self createRemoteViewOfHandleId:handleId];
}

@end

