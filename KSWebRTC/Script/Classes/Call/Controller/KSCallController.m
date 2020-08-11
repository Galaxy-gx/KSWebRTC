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
#import "KSTopBarView.h"
#import "KSCallState.h"

@interface KSCallController ()<KSMessageHandlerDelegate>

@property (nonatomic, weak            ) KSCallView        *callView;
@property (nonatomic, weak            ) KSTopBarView      *topBarView;
@property (nonatomic, strong          ) KSMessageHandler  *msgHandler;
@property (nonatomic, strong          ) KSMediaCapture    *mediaCapture;
@property (nonatomic, assign          ) BOOL              isConnect;
@property (nonatomic, assign, readonly) KSCallState       callState;
@property (nonatomic, weak, readonly  ) KSMediaConnection *localConnection;

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
    [_mediaCapture captureLocalMedia];
    
    [_callView setLocalViewSession:_mediaCapture.capturer.captureSession];
    
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
    
    CGFloat statusHeight            = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat navHeight               = self.navigationController.navigationBar.bounds.size.height;
    
    KSCallView *callView            = [[KSCallView alloc] initWithFrame:self.view.bounds layout:layout callType:KSCallTypeSingleVideo];
    callView.topPadding             = statusHeight + navHeight;
    _callView                       = callView;
    
    KSWeakSelf;
    KSEventCallback callback        = ^(KSEventType eventType, NSDictionary *info) {
        NSLog(@"|------| eventType: %d |------|",(int)eventType);
        [weakSelf triggerEvent:eventType];
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
    
    UIButton *arrowBtn              = [UIButton ks_buttonWithNormalImg:@"icon_bar_double_arrow_white"];
    arrowBtn.frame                  = CGRectMake(0, 0, KS_Extern_Point24, KS_Extern_Point24);
    [arrowBtn addTarget:self action:@selector(onArrowClick) forControlEvents:UIControlEventTouchUpInside];
    self.superBar.backBarButtonItem = arrowBtn;
    [self.superBar toFront];
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
        case KSEventTypeInConversationMicrophoneOpen:
            [self inConversationMicrophoneOpen];
            break;
        case KSEventTypeInConversationMicrophoneClose:
            [self inConversationMicrophoneClose];
            break;
        case KSEventTypeInConversationVolumeOpen:
            [self inConversationVolumeOpen];
            break;
        case KSEventTypeInConversationVolumeClose:
            [self inConversationVolumeClose];
            break;
        case KSEventTypeInConversationCameraOpen:
            [self inConversationCameraOpen];
            break;
        case KSEventTypeInConversationCameraClose:
            [self inConversationCameraClose];
            break;
        case KSEventTypeInConversationBluetoothOpen:
            [self inConversationVolumeOpen];
            break;
        case KSEventTypeInConversationBluetoothClose:
            [self inConversationBluetoothClose];
            break;
        case KSEventTypeInConversationHangup:
            [self inConversationHangup];
            break;
        case KSEventTypeMeetingThemeMicrophoneOpen:
            [self meetingThemeMicrophoneOpen];
            break;
        case KSEventTypeMeetingThemeMicrophoneClose:
            [self meetingThemeMicrophoneClose];
            break;
        case KSEventTypeMeetingThemeVolumeOpen:
            [self meetingThemeVolumeOpen];
            break;
        case KSEventTypeMeetingThemeVolumeClose:
            [self meetingThemeVolumeClose];
            break;
        case KSEventTypeMeetingThemeCameraOpen:
            [self meetingThemeCameraOpen];
            break;
        case KSEventTypeMeetingThemeCameraClose:
            [self meetingThemeCameraClose];
            break;
        case KSEventTypeMeetingThemeBluetoothOpen:
            [self meetingThemeVolumeOpen];
            break;
        case KSEventTypeMeetingThemeBluetoothClose:
            [self meetingThemeBluetoothClose];
            break;
        case KSEventTypeStartMeeting:
            break;
        default:
            break;
    }
}

// 按钮操作
- (void)onArrowClick {
    NSLog(@"%s",__FUNCTION__);
    [self dismiss];
}

- (void)onSwitchCameraClick {
    [_mediaCapture switchCamera];
    NSLog(@"%s",__FUNCTION__);
}

- (void)onAddMemberClick {
    NSLog(@"%s",__FUNCTION__);
}

- (void)onScaleDownClick {
    NSLog(@"%s",__FUNCTION__);
    [self dismiss];
}

- (void)onIdentifierClick {
    NSLog(@"%s",__FUNCTION__);
}

- (void)callerHangup {
    NSLog(@"%s",__FUNCTION__);
    [_callView setAnswerState:KSAnswerStateJoin];
}

-(void)calleeHangup {
    NSLog(@"%s",__FUNCTION__);
}

-(void)calleeAnswer {
    NSLog(@"%s",__FUNCTION__);
    if (_isConnect) {
        return;
    }
    _isConnect = true;
    [_msgHandler connectServer:@"ws://10.0.115.144:8188"];
    
    [_callView displayCallBar];
}

//会话中开启麦克风
- (void)inConversationMicrophoneOpen {
    [self.localConnection unmuteAudio];
}

//会话中关闭麦克风
- (void)inConversationMicrophoneClose {
    [self.localConnection muteAudio];
}

//会话中开启声音
- (void)inConversationVolumeOpen {
    [_mediaCapture speakerOn];
}

//会话中静音
- (void)inConversationVolumeClose {
    [_mediaCapture speakerOff];
}

//会话中开启摄像机
- (void)inConversationCameraOpen {
    [_mediaCapture startCapture];
}

//会话中关闭摄像机
- (void)inConversationCameraClose {
    [_mediaCapture stopCapture];
}


//会话中开启蓝牙
- (void)inConversationBluetoothOpen {
    
}

//会话中关闭蓝牙
- (void)inConversationBluetoothClose {
    
}

//会话中挂断
- (void)inConversationHangup {
    [_msgHandler close];
    [_msgHandler requestHangup];
    [_mediaCapture close];
    _mediaCapture = nil;
    [_callView setLocalViewSession:nil];
}

//会议主题面板中开启麦克风
- (void)meetingThemeMicrophoneOpen {
    [self.localConnection unmuteAudio];
}

//会议主题面板中关闭麦克风
- (void)meetingThemeMicrophoneClose {
    [self.localConnection muteAudio];
}

//会议主题面板中开启声音
- (void)meetingThemeVolumeOpen {
    [_mediaCapture speakerOn];
}

//会议主题面板中静音
- (void)meetingThemeVolumeClose {
    [_mediaCapture speakerOff];
}

//会议主题面板中开启摄像机
- (void)meetingThemeCameraOpen {
    [_mediaCapture startCapture];
}

//会议主题面板中关闭摄像机
- (void)meetingThemeCameraClose {
    [_mediaCapture stopCapture];
}


//会议主题面板中开启蓝牙
- (void)meetingThemeBluetoothOpen {
    
}

//会议主题面板中关闭蓝牙
- (void)meetingThemeBluetoothClose {
    
}

//KSMessageHandlerDelegate
- (void)messageHandlerEndOfSession:(KSMessageHandler *)messageHandler {
    
}

- (void)messageHandler:(KSMessageHandler *)messageHandler didReceivedMessage:(KSMsg *)message {
    
}

- (void)messageHandler:(KSMessageHandler *)messageHandler leaveOfHandleId:(NSNumber *)handleId {
    [_callView leaveOfHandleId:handleId];
}

- (KSMediaCapture *)mediaCaptureOfSectionsInMessageHandler:(KSMessageHandler *)messageHandler {
    return _mediaCapture;
}

- (RTCEAGLVideoView *)remoteViewOfSectionsInMessageHandler:(KSMessageHandler *)messageHandler handleId:(NSNumber *)handleId {
    self.topBarView.hidden = NO;
    return [_callView remoteViewOfHandleId:handleId];
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

-(KSTopBarView *)topBarView {
    if (_topBarView == nil) {
        KSTopBarView *topBarView = [[KSTopBarView alloc] initWithFrame:self.superBar.bounds];
        [self.superBar addSubview:topBarView];
        _topBarView              = topBarView;
        [topBarView.switchBtn addTarget:self action:@selector(onSwitchCameraClick) forControlEvents:UIControlEventTouchUpInside];
        [topBarView.addBtn addTarget:self action:@selector(onAddMemberClick) forControlEvents:UIControlEventTouchUpInside];
        [topBarView.scaleDownBtn addTarget:self action:@selector(onScaleDownClick) forControlEvents:UIControlEventTouchUpInside];
        [topBarView.identifierBtn addTarget:self action:@selector(onIdentifierClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _topBarView;
}

//Get
-(KSCallState)callState {
    return _msgHandler.callState;
}

-(KSMediaConnection *)localConnection {
    return _msgHandler.localConnection;
}

@end
