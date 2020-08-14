//
//  KSCallController.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/8.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSCallController.h"
#import <WebRTC/RTCAudioSession.h>
#import "KSMsg.h"
#import "UIButton+Category.h"
#import "KSCallView.h"
#import "KSProfileView.h"
#import "KSTopBarView.h"
#import "KSCallState.h"
#import "KSWebRTCManager.h"

#import "KSCallBarView.h"

@interface KSCallController ()<KSWebRTCManagerDelegate,KSCallViewDataSource>

@property (nonatomic, weak ) KSCallView   *callView;
@property (nonatomic, weak ) KSTopBarView *topBarView;
@property (nonatomic,assign) KSCallType   callType;
@property (nonatomic,strong) KSTileLayout *tileLayout;

@end

@implementation KSCallController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _callType = KSCallTypeManyVideo;//KSCallTypeSingleVideo;
    [self initMainKit];
    [self initWebRTC];
}

-(void)dealloc {
    [[KSWebRTCManager shared] close];
}

- (void)initMainKit {
    KSTileLayout *tileLayout = nil;
    CGFloat statusHeight              = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat navHeight                 = self.navigationController.navigationBar.bounds.size.height;
    switch (_callType) {
        case KSCallTypeSingleAudio:
            tileLayout                = [KSTileLayout singleAudioLayout];
            tileLayout.topPadding     = 0;
            break;
        case KSCallTypeManyAudio:
            tileLayout = [KSTileLayout manyAudioLayout];
            tileLayout.topPadding     = statusHeight + navHeight;
            break;
        case KSCallTypeSingleVideo:
            tileLayout                = [KSTileLayout singleVideoLayout];
            tileLayout.topPadding     = 0;
            break;
        case KSCallTypeManyVideo:
            tileLayout = [KSTileLayout manyVideoLayout];
            tileLayout.topPadding     = statusHeight + navHeight;
            break;
        default:
            break;
    }
    _tileLayout                       = tileLayout;
    KSCallView *callView              = [[KSCallView alloc] initWithFrame:self.view.bounds tileLayout:tileLayout callType:_callType];
    callView.dataSource               = self;
    _callView                         = callView;

    KSWeakSelf;
    KSEventCallback callback          = ^(KSEventType eventType, NSDictionary *info) {
        NSLog(@"|------| eventType: %d |------|",(int)eventType);
        [weakSelf triggerEvent:eventType];
    };
    [callView setEventCallback:callback];
    [self.view addSubview:callView];
    
    KSProfileConfigure *configure     = [[KSProfileConfigure alloc] init];
    configure.topPaddding             = 173;
    configure.title                   = @"Hamasaki Ayumi";
    configure.titleFont               = [UIFont ks_fontRegularOfSize:KS_Extern_30Font];
    configure.titleOffst              = KS_Extern_Point32;
    configure.desc                    = @"Invite you to a video call";
    configure.descFont                = [UIFont ks_fontRegularOfSize:KS_Extern_16Font];
    configure.descOffst               = KS_Extern_Point08;

    [_callView setProfileConfigure:configure];
    [_callView setAnswerState:KSAnswerStateAwait];

    UIButton *arrowBtn                = [UIButton ks_buttonWithNormalImg:@"icon_bar_double_arrow_white"];
    arrowBtn.frame                    = CGRectMake(0, 0, KS_Extern_Point24, KS_Extern_Point24);
    [arrowBtn addTarget:self action:@selector(onArrowClick) forControlEvents:UIControlEventTouchUpInside];
    self.superBar.backBarButtonItem   = arrowBtn;
    [self.superBar toFront];
}

- (void)initWebRTC {
    KSWeakSelf;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[KSWebRTCManager shared] initRTCWithCallType:weakSelf.callType];
        [KSWebRTCManager shared].delegate = self;
        if (weakSelf.callType == KSCallTypeSingleVideo) {
            [weakSelf createLocalView];
        }
        //测试放后面
        [KSWebRTCManager socketConnectServer:@"ws://10.0.115.144:8188"];
    });
}

- (void)createLocalView {
    
    switch (_callType) {
        case KSCallTypeSingleAudio:
        {
            [_callView createLocalViewWithLayout:_tileLayout resizingMode:KSResizingModeScreen callType:[KSWebRTCManager shared].callType];
            [_callView setLocalViewSession:[KSWebRTCManager shared].captureSession];
        }
            break;
        case KSCallTypeManyAudio:
            
            break;
        case KSCallTypeSingleVideo:
        {
            [_callView createLocalViewWithLayout:_tileLayout resizingMode:KSResizingModeScreen callType:[KSWebRTCManager shared].callType];
            [_callView setLocalViewSession:[KSWebRTCManager shared].captureSession];
        }
            break;
        case KSCallTypeManyVideo:
        {
            
        }
            break;
        default:
            break;
    }
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
            [self inConversationBluetoothOpen];
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
            [self meetingThemeBluetoothOpen];
            break;
        case KSEventTypeMeetingThemeBluetoothClose:
            [self meetingThemeBluetoothClose];
            break;
        case KSEventTypeStartMeeting:
            [self startMeeting];
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
    [KSWebRTCManager switchCamera];
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
    if ([KSWebRTCManager shared].isConnect == NO) {
        return;
    }
    
    [KSWebRTCManager socketCreateSession];
    [_callView displayCallBar];
}

//会话中开启麦克风
- (void)inConversationMicrophoneOpen {
    [KSWebRTCManager unmuteAudio];
}

//会话中关闭麦克风
- (void)inConversationMicrophoneClose {
    [KSWebRTCManager muteAudio];
}

//会话中开启声音
- (void)inConversationVolumeOpen {
    [KSWebRTCManager speakerOn];
}

//会话中静音
- (void)inConversationVolumeClose {
    [KSWebRTCManager speakerOff];
}

//会话中开启摄像机
- (void)inConversationCameraOpen {
    [KSWebRTCManager startCapture];
}

//会话中关闭摄像机
- (void)inConversationCameraClose {
    [KSWebRTCManager stopCapture];
}

//会话中开启蓝牙
- (void)inConversationBluetoothOpen {
    
}

//会话中关闭蓝牙
- (void)inConversationBluetoothClose {
    
}

//会话中挂断
- (void)inConversationHangup {
    [KSWebRTCManager socketSendHangup];
    [KSWebRTCManager socketClose];
    [KSWebRTCManager closeMediaCapture];
    [_callView setLocalViewSession:nil];
}

//会议主题面板中开启麦克风
- (void)meetingThemeMicrophoneOpen {
    [KSWebRTCManager unmuteAudio];
}

//会议主题面板中关闭麦克风
- (void)meetingThemeMicrophoneClose {
    [KSWebRTCManager muteAudio];
}

//会议主题面板中开启声音
- (void)meetingThemeVolumeOpen {
    [KSWebRTCManager speakerOn];
}

//会议主题面板中静音
- (void)meetingThemeVolumeClose {
    [KSWebRTCManager speakerOff];
}

//会议主题面板中开启摄像机
- (void)meetingThemeCameraOpen {
    [KSWebRTCManager startCapture];
}

//会议主题面板中关闭摄像机
- (void)meetingThemeCameraClose {
    [KSWebRTCManager stopCapture];
}

//会议主题面板中开启蓝牙
- (void)meetingThemeBluetoothOpen {
    
}

//会议主题面板中关闭蓝牙
- (void)meetingThemeBluetoothClose {
    
}

//开始会议
- (void)startMeeting {
    
}

//KSWebRTCManagerDelegate
- (void)webRTCManagerHandlerEndOfSession:(KSWebRTCManager *)webRTCManager {
    //会话结束
    [_callView leaveLocal];
    [self dismiss];
}

- (void)webRTCManager:(KSWebRTCManager *)webRTCManager didReceivedMessage:(KSMsg *)message {
    
}

- (void)webRTCManager:(KSWebRTCManager *)webRTCManager leaveOfConnection:(KSMediaConnection *)connection {
    switch ([KSWebRTCManager shared].callType) {
        case KSCallTypeSingleAudio:

            break;
        case KSCallTypeManyAudio:
            
            break;
        case KSCallTypeSingleVideo:
            [_callView leaveOfHandleId:connection.handleId];
            break;
        case KSCallTypeManyVideo:
            [_callView deleteItemsAtIndex:connection.index];
            break;
        default:
            break;
    }
}

- (void)webRTCManagerSocketDidOpen:(KSWebRTCManager *)webRTCManager {
    
}

- (void)webRTCManagerSocketDidFail:(KSWebRTCManager *)webRTCManager {
    
}

- (void)webRTCManager:(KSWebRTCManager *)webRTCManager didAddMediaConnection:(KSMediaConnection *)connection {
    if (connection.mediaInfo.isLocal && [KSWebRTCManager shared].callType == KSCallTypeSingleVideo) {
        return;
    }
    if (self.topBarView.isHidden) {
        self.topBarView.hidden = NO;
    }
    
    switch ([KSWebRTCManager shared].callType) {
        case KSCallTypeSingleAudio:

            break;
        case KSCallTypeManyAudio:
            
            break;
        case KSCallTypeSingleVideo:
            [_callView createRemoteViewOfConnection:connection];
            break;
        case KSCallTypeManyVideo:
            [_callView insertItemsAtIndex:[KSWebRTCManager connectionCount] - 1];
            break;
        default:
            break;
    }
}

//KSCallViewDataSource
- (NSInteger)callView:(KSCallView *)callView numberOfItemsInSection:(NSInteger)section {
    return [KSWebRTCManager connectionCount];
}

- (KSMediaConnection *)callView:(KSCallView *)callView itemAtIndexPath:(NSIndexPath *)indexPath {
    return [KSWebRTCManager connectionOfIndex:indexPath.item];
}

//懒加载
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

@end
