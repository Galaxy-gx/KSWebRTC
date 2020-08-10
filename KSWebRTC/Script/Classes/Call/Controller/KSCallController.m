//
//  KSCallController.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/8.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSCallController.h"
#import "KSCallView.h"
#import <WebRTC/RTCAudioSession.h>
#import "KSMessageHandler.h"
#import "KSMediaCapture.h"
#import "KSMsg.h"
#import "UIButton+Category.h"

#import "KSProfileView.h"

@interface KSCallController ()<KSVideoCallViewDelegate,KSMessageHandlerDelegate>

@property(nonatomic, weak) KSCallView *callView;
@property (nonatomic, strong) KSMessageHandler *msgHandler;
@property (nonatomic, strong) KSMediaCapture *mediaCapture;
@property (nonatomic, assign) BOOL isConnect;

@end

@implementation KSCallController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initKit];
    [self initProperty];
}

- (void)initProperty {
    _mediaCapture                    = [[KSMediaCapture alloc] init];
    [_mediaCapture createPeerConnectionFactory];
    AVCaptureSession *captureSession = [_mediaCapture captureLocalMedia];

    [_callView setLocalViewSession:captureSession];

    _msgHandler                      = [[KSMessageHandler alloc] init];
    _msgHandler.delegate             = self;
}

- (void)initKit {
    KSTileLayout *layout            = [[KSTileLayout alloc] init];
    layout.scale                    = KSScaleMake(9, 16);
    layout.mode                     = KSContentModeScaleAspectFit;
    int width                       = 96;
    int height                      = width / layout.scale.width * layout.scale.height;
    layout.layout                   = KSLayoutMake(width, height, 10, 10);

    KSCallView *callView            = [[KSCallView alloc] initWithFrame:self.view.bounds layout:layout callType:KSCallTypeManyVideo];
    callView.delegate               = self;
    _callView                       = callView;
    
    KSEventCallback callback = ^(KSEventType eventType, NSDictionary *info) {
        NSLog(@"|------| %d |------|",(int)eventType);
        [self triggerEvent:eventType];
    };
    [callView setEventCallback:callback];
    [callView createLocalViewWithLayout:layout resizingMode:KSResizingModeScreen callType:KSCallTypeSingleVideo];
    [self.view addSubview:callView];

    KSProfileConfigure *configure   = [[KSProfileConfigure alloc] init];
    configure.topPaddding           = 173;
    configure.title                 = @"Hamasaki Ayumi";
    configure.titleFont             = [UIFont ks_fontRegularOfSize:KS_Extern_30Font];
    configure.titleOffst            = KS_Extern_Point32;
    configure.desc                  = @"Invite you to a video call";
    configure.descFont              = [UIFont ks_fontRegularOfSize:KS_Extern_16Font];
    configure.descOffst             = KS_Extern_Point08;

    [_callView setProfileConfigure:configure];
    [_callView setAnswerState:KSAnswerStateAwait];
    //KSProfileView *profileView = [[KSProfileView alloc] initWithFrame:CGRectMake(0, 173, self.view.bounds.size.width, 204) configure:configure];
    //[self.view addSubview:profileView];

    UIButton *arrowBtn              = [UIButton ks_buttonWithNormalImg:@"icon_bar_double_arrow_white"];
    arrowBtn.frame                  = CGRectMake(0, 0, KS_Extern_Point24, KS_Extern_Point24);
    [arrowBtn addTarget:self action:@selector(onArrowClick) forControlEvents:UIControlEventTouchUpInside];
    self.superBar.backBarButtonItem = arrowBtn;
    [self.superBar toFront];
}

- (void)onArrowClick {
    [self dismiss];
}

- (void)triggerEvent:(KSEventType)eventType {
    switch (eventType) {
        case KSEventTypeCallerHangup://呼叫时，呼叫方挂断
            [self callerHangup];
            break;
        case KSEventTypeCalleeHangup://被叫方挂断
            break;
        case KSEventTypeCalleeAnswer://被叫方接听
            [self calleeAnswer];
            break;
        default:
            break;
    }
}

- (void)callerHangup {
    [_callView setAnswerState:KSAnswerStateJoin];
}

-(void)calleeHangup {
    
}

-(void)calleeAnswer {
    [_callView displayCallBar];
}

//KSMessageHandlerDelegate
- (void)messageHandler:(KSMessageHandler *)messageHandler didReceivedMessage:(KSMsg *)message {
    
}

- (void)messageHandler:(KSMessageHandler *)messageHandler detached:(KSDetached *)detached {
    [_callView leaveOfHandleId:detached.sender];
}

- (KSMediaCapture *)mediaCaptureOfSectionsInMessageHandler:(KSMessageHandler *)messageHandler {
    return _mediaCapture;
}

- (RTCEAGLVideoView *)remoteViewOfSectionsInMessageHandler:(KSMessageHandler *)messageHandler handleId:(NSNumber *)handleId {
    return [_callView remoteViewOfHandleId:handleId];
}


//KSVideoCallViewDelegate
- (void)videoCallViewDidChangeRoute:(KSCallView *)view {
    
}

- (void)videoCallViewDidEnableStats:(KSCallView *)view {
    
}

- (void)videoCallViewDidHangup:(KSCallView *)view {
    
}

- (void)videoCallViewDidSwitchCamera:(KSCallView *)view {
    
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
