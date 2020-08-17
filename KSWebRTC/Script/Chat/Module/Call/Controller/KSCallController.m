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
#import "UIFont+Category.h"
#import "KSSuperController+Category.h"
#import "KSKitManager.h"

@interface KSCallController ()<KSWebRTCManagerDelegate,KSCallViewDataSource>

@property (nonatomic, weak ) KSCallView         *callView;
@property (nonatomic, weak ) KSTopBarView       *topBarView;
@property (nonatomic,assign) KSCallType         callType;
@property (nonatomic,strong) KSTileLayout       *tileLayout;
@property (nonatomic,strong) KSProfileConfigure *profileInfo;

@end

@implementation KSCallController

- (void)viewDidLoad {
    [super viewDidLoad];
    //记录类型
    _callType = [KSWebRTCManager shared].callType;//KSCallTypeManyVideo;//KSCallTypeSingleVideo;
    
    //初始化布局
    [self initTileLayout];
    //初始化页面
    [self initKit];
    //页面逻辑
    [self kitLogic];
}

-(void)dealloc {
    [KSWebRTCManager close];
}

- (void)initTileLayout {
    KSTileLayout *tileLayout = [KSTileLayout layoutWithCallType:_callType];
    CGFloat statusHeight     = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat navHeight        = self.navigationController.navigationBar.bounds.size.height;
    tileLayout.topPadding    = statusHeight + navHeight;
    self.tileLayout          = tileLayout;
}

- (void)initKit {
    __weak typeof(self) weakSelf    = self;
    KSEventCallback callback        = ^(KSEventType eventType, NSDictionary *info) {
        NSLog(@"|------| eventType: %d |------|",(int)eventType);
        [weakSelf triggerEvent:eventType];
    };

    KSCallView *callView            = [[KSCallView alloc] initWithFrame:self.view.bounds tileLayout:_tileLayout];
    callView.dataSource             = self;
    self.callView                   = callView;
    [callView setEventCallback:callback];
    [self.view addSubview:callView];

    UIButton *arrowBtn              = [UIButton ks_buttonWithNormalImg:@"icon_bar_double_arrow_white"];
    arrowBtn.frame                  = CGRectMake(0, 0, KS_Extern_Point24, KS_Extern_Point24);
    [arrowBtn addTarget:self action:@selector(onArrowClick) forControlEvents:UIControlEventTouchUpInside];
    self.superBar.backBarButtonItem = arrowBtn;
    [self.superBar toFront];
}

//self.profileInfo
- (void)testProfileData01 {
    KSProfileConfigure *configure = [[KSProfileConfigure alloc] init];
    configure.topPaddding         = 173;
    configure.title               = @"Hamasaki Ayumi";
    configure.titleFont           = [UIFont ks_fontRegularOfSize:KS_Extern_30Font];
    configure.titleOffst          = KS_Extern_Point32;
    configure.desc                = @"Invite you to a video call";
    configure.descFont            = [UIFont ks_fontRegularOfSize:KS_Extern_16Font];
    configure.descOffst           = KS_Extern_Point08;
    _profileInfo                  = configure;
}

- (void)kitLogic {
    switch ([KSWebRTCManager shared].callState) {
        case KSCallStateNone://拨打界面（挂断）
        {
            [self testProfileData01];
            [self.callView setProfileConfigure:_profileInfo];
            [self.callView setAnswerState:KSAnswerStateAwait];
            
            [self initWebRTC];
        }
            break;
        case KSCallStateCalleeBeingCalled://被叫界面（挂断/接听）
        {
            [self testProfileData01];
            [self.callView setProfileConfigure:_profileInfo];
            [self.callView setAnswerState:KSAnswerStateJoin];
            
            [self initWebRTC];
        }
            break;
        case KSCallStateRecording://通话中
        {
            self.topBarView.hidden = NO;
            [self callLayout];
        }
            break;
        default:
            break;
    }
}

- (void)initWebRTC {
    if ([KSWebRTCManager shared].connectCount == 0) {
        KSConnectionSetting *connectionSetting = [[KSConnectionSetting alloc] init];
        connectionSetting.callType             = _callType;
        connectionSetting.iceServer            = [[KSIceServer alloc] init];

        KSCapturerSetting *capturerSetting     = [[KSCapturerSetting alloc] init];
        capturerSetting.isFront                = YES;
        capturerSetting.callType               = _callType;
        //capturerSetting.resolution             = CGSizeMake(540, 960);
        capturerSetting.videoScale             = _tileLayout.scale;

        KSMediaSetting *setting                = [[KSMediaSetting alloc] initWithConnectionSetting:connectionSetting capturerSetting:capturerSetting];
        [[KSWebRTCManager shared] initRTCWithMediaSetting:setting];
        [KSWebRTCManager socketConnectServer:@"ws://10.0.115.144:8188"];
    }

    [KSWebRTCManager shared].delegate = self;
    [self createLocalView];
}

- (void)setProfileInfo:(KSProfileConfigure *)profileInfo {
    [self.callView setProfileConfigure:profileInfo];
}

- (void)setAnswerState:(KSAnswerState)state {
    [self.callView setAnswerState:state];
}

/// 创建并展示一对一本地视频
- (void)setLocalViewOfSession:(BOOL)isSession {
    _tileLayout.resizingMode = isSession ? KSResizingModeTile : KSResizingModeScreen;
    [self.callView createLocalViewWithTileLayout:_tileLayout];

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.callView setMediaConnection:[KSWebRTCManager shared].localConnection];
    });
}

/// 未开始会话的本地界面
- (void)createLocalView {
    switch (_callType) {
        case KSCallTypeSingleAudio:
        case KSCallTypeSingleVideo:
        {
            [self setLocalViewOfSession:NO];
        }
            break;
        case KSCallTypeManyAudio:
            
            break;
        case KSCallTypeManyVideo:
        {
            
        }
            break;
        default:
            break;
    }
}

/// 已经接通：从其他页面回到此页面
- (void)callLayout {
    switch (_callType) {
        case KSCallTypeSingleAudio:
        case KSCallTypeSingleVideo:
        {
            [self setLocalViewOfSession:YES];
            KSWebRTCManager *manager = [KSWebRTCManager shared];
            if (manager.connectCount == 2) {
                [self webRTCManager:manager didAddMediaConnection:manager.mediaConnections.lastObject];
            }
        }
            break;
        case KSCallTypeManyAudio:
        case KSCallTypeManyVideo:
        {
            //[self.callView reloadCollectionView];
            KSWebRTCManager *manager = [KSWebRTCManager shared];
            for (KSMediaConnection *mediaConnection in manager.mediaConnections) {
                [self webRTCManager:manager didAddMediaConnection:mediaConnection];
            }
        }
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
    //[KSWebRTCManager switchCamera];
    NSLog(@"%s",__FUNCTION__);
    [KSWebRTCManager clearAllRenderer];
    [KSWebRTCManager shared].callState = KSCallStateRecording;
    KSCallController *ctrl             = [[KSCallController alloc] init];
    ctrl.isSuperBar                    = YES;
    ctrl.displayFlag                   = KSDisplayFlagAnimatedFirst;
    UINavigationController *navCtrl    = [[UINavigationController alloc] initWithRootViewController:ctrl];
    navCtrl.modalPresentationStyle     = UIModalPresentationFullScreen;
    [self presentViewController:navCtrl animated:NO completion:nil];
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
    [self.callView setAnswerState:KSAnswerStateJoin];
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
    [self.callView displayCallBar];
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
    [KSWebRTCManager close];
    [self.callView setMediaConnection:nil];
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
- (void)webRTCManagerHandlerEnd:(KSWebRTCManager *)webRTCManager {
    //会话结束
    if (self.callType == KSCallTypeSingleVideo || self.callType == KSCallTypeSingleVideo) {
        //次方法省略？
        [self.callView leaveLocal];
    }
    [self dismiss];
}

- (void)webRTCManager:(KSWebRTCManager *)webRTCManager didReceivedMessage:(KSMsg *)message {
    
}

- (void)webRTCManager:(KSWebRTCManager *)webRTCManager leaveOfConnection:(KSMediaConnection *)connection {
    switch (_callType) {
        case KSCallTypeSingleAudio:

            break;
        case KSCallTypeManyAudio:
            
            break;
        case KSCallTypeSingleVideo:
            [self.callView leaveOfHandleId:connection.handleId];
            break;
        case KSCallTypeManyVideo:
            [self.callView deleteItemsAtIndex:connection.index];
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
    if (self.topBarView.isHidden) {
        self.topBarView.hidden = NO;
    }
    switch (_callType) {
        case KSCallTypeSingleAudio:
        case KSCallTypeSingleVideo:
        {
            if (connection.isLocal) {
                [self setLocalViewOfSession:YES];
            }
            else{
                [self.callView createRemoteViewOfConnection:connection];
            }
        }
            break;
        case KSCallTypeManyAudio:
        case KSCallTypeManyVideo:
        {
            [self.callView insertItemsAtIndex:_callView.mediaCount];
            //[self.callView insertItemsAtIndex:[KSWebRTCManager connectionCount] - 1];
        }
            break;
        default:
            break;
    }
}

//KSCallViewDataSource
- (NSInteger)callView:(KSCallView *)callView numberOfItemsInSection:(NSInteger)section {
    return [KSWebRTCManager shared].connectCount;
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
