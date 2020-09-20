//
//  KSMediaCallController.m
//  KSWebRTC
//
//  Created by saeipi on 2020/9/15.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSMediaCallController.h"
#import <WebRTC/RTCAudioSession.h>
#import "KSMsg.h"
#import "UIButton+Category.h"
#import "KSCallView.h"
#import "KSProfileView.h"
#import "KSTopBarView.h"
#import "KSCallState.h"
#import "KSCallBarView.h"
#import "UIFont+Category.h"
#import "KSSuperController+Category.h"
#import "KSMessageHandler.h"
#import "UILabel+Category.h"
#import "SVProgressHUD.h"
#import "NSString+Category.h"
#import "KSBtnInfo.h"
#import "KSCoolTile.h"
#import "KSAlertController.h"
#import "KSRTCManager.h"

@interface KSMediaCallController ()<KSRTCManagerDelegate,KSCallViewDataSource,KSTopBarViewDataSource,KSTopBarViewDelegate>
@property (nonatomic, weak  ) KSCallView    *callView;
@property (nonatomic, weak  ) KSTopBarView  *topBarView;
@property (nonatomic, strong) KSTileLayout  *tileLayout;
@property (nonatomic, strong) KSProfileInfo *profileInfo;

@property (nonatomic, assign, readonly) KSCallType myType;
@property (nonatomic, assign, readonly ) long long peerId;//对方ID
@property (nonatomic, assign, readonly ) BOOL      isCalled;//是否是被叫
@end

@implementation KSMediaCallController

-(void)dealloc {
    [KSRTCManager close];
}

- (void)closeCtrl {
    [self dismissViewControllerAnimated:NO completion:nil];
}

+ (void)callWithType:(KSCallType)type callState:(KSCallStateMaintenance)callState isCaller:(BOOL)isCaller peerId:(long long)peerId target:(UIViewController *)target {
    [KSRTCManager shared].callState = callState;
    [KSRTCManager shared].callType  = type;
    
    if (isCaller) {//主叫
        [KSRTCManager callToUserid:peerId];
    }

    KSMediaCallController *ctrl     = [[KSMediaCallController alloc] init];
    ctrl.isSuperBar                 = YES;
    ctrl.displayFlag                = KSDisplayFlagAnimatedFirst;
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
    navCtrl.modalPresentationStyle  = UIModalPresentationFullScreen;
    [target presentViewController:navCtrl animated:NO completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化布局
    [self initTileLayout];
    //初始化页面
    [self initKit];
    //更新代理
    [KSRTCManager shared].delegate = self;
    //页面逻辑
    [self kitLogic];
}

- (void)initTileLayout {
    KSTileLayout *tileLayout   = [KSTileLayout layoutWithCallType:self.myType];
    CGFloat statusHeight       = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat navHeight          = self.navigationController.navigationBar.bounds.size.height;
    /*
    if (self.myType == KSCallTypeSingleVideo) {
    tileLayout.topPadding      = statusHeight + KS_Extern_Point10;
    }
    else if (self.myType == KSCallTypeManyVideo) {
    tileLayout.topPadding      = statusHeight + navHeight + KS_Extern_Point10;
    }*/
    tileLayout.isCalled        = self.isCalled;
    tileLayout.topPadding      = statusHeight + navHeight + KS_Extern_Point10;
    //tileLayout.layout          = KSLayoutMake(90, 160, KS_Extern_Point10, KS_Extern_Point10);
    self.tileLayout            = tileLayout;
}

- (void)initKit {
    __weak typeof(self) weakSelf    = self;
    KSEventCallback callback        = ^(KSEventType eventType, id info) {
        NSLog(@"|------| eventType: %d |------|",(int)eventType);
        [weakSelf triggerEvent:eventType info:info];
    };
    
    KSCallView *callView            = [[KSCallView alloc] initWithFrame:self.view.bounds tileLayout:_tileLayout deviceSwitch:[KSRTCManager shared].deviceSwitch];
    callView.dataSource             = self;
    [callView initKits];//设置数据源后调用
    self.callView                   = callView;
    [callView setEventCallback:callback];
    [self.view addSubview:callView];
    
    UIButton *arrowBtn              = [UIButton ks_buttonWithNormalImg:@"icon_bar_double_arrow_white"];
    arrowBtn.frame                  = CGRectMake(0, 0, KS_Extern_Point24, KS_Extern_Point24);
    //[arrowBtn addTarget:self action:@selector(onArrowClick) forControlEvents:UIControlEventTouchUpInside];
    self.superBar.backBarButtonItem = arrowBtn;
    
    [self.superBar toFront];
}

- (void)kitLogic {
    KSUserInfo *userInfo = [KSUserInfo userWithId:self.peerId];
    _profileInfo         = [self profileWithTitle:userInfo.name];
    [self updateProfileInfo:_profileInfo];
    
    KSCallStateMaintenance callState = [KSRTCManager shared].callState;
    switch (callState) {
        case KSCallStateMaintenanceCaller://拨打界面（挂断）
        {
            [self setAnswerState:KSAnswerStateAwait];
            [self initWebRTC];
        }
            break;
        case KSCallStateMaintenanceRinger://被叫界面（挂断/接听）
        case KSCallStateMaintenanceRinged:
        {
            if (self.isCalled) {//被叫
                [self setAnswerState:KSAnswerStateJoin];
                if (callState == KSCallStateMaintenanceRinger) {
                    //[KSRTCManager ringed];
                }
            }
            else{//主叫
                [self setAnswerState:KSAnswerStateAwait];
            }
            
            [self initWebRTC];
        }
            break;
        case KSCallStateMaintenanceAnswoer:
        case KSCallStateMaintenanceRecording://通话中
        {
            [self updateCalleeAnswerKit];
            [self callLayout];
        }
            break;
        default:
            break;
    }
}

- (void)updateCalleeAnswerKit {
    switch (self.myType) {
        case KSCallTypeSingleAudio:
            [self setAnswerState:KSAnswerStateSession];
            //[self.callView displayCallBar];
            break;
        case KSCallTypeSingleVideo:
            //[self.callView displayCallBar];
        break;
        default:
            break;
    }
    [self.topBarView showKitOfStartingTime:[KSRTCManager shared].startingTime];
    [self.callView displayCallBar];
}

- (void)callLayout {
    switch (self.myType) {
        case KSCallTypeSingleAudio:
        case KSCallTypeSingleVideo:
        {
            KSRTCManager *manager = [KSRTCManager shared];
            for (int i = 0; i < manager.mediaTrackCount; i++) {
                KSMediaTrack *mt = [KSRTCManager mediaTrackOfIndex:i];
                if (mt.isLocal == NO) {
                    [self rtcManager:manager didAddMediaTrack:mt];
                    break;
                }
            }
        }
            break;
        case KSCallTypeManyAudio:
        case KSCallTypeManyVideo:
        {
            [self.callView reloadCollectionView];
            
            /*
            KSRTCManager *manager = [KSRTCManager shared];
            for (KSMediaConnection *mediaConnection in manager.mediaConnections) {
                [self webRTCManager:manager didAddMediaConnection:mediaConnection];
            }*/
        }
        default:
            break;
    }
}

#pragma mark - RTC初始化
- (void)initWebRTC {
    if ([KSRTCManager shared].localMediaTrack == nil) {
        KSConnectionSetting *connectionSetting = [[KSConnectionSetting alloc] init];
        connectionSetting.iceServer            = [[KSIceServer alloc] init];
        
        __weak typeof(self) weakSelf = self;
        KSAuthorizationCallback authCallback   = ^(KSDeviceType deviceType, AVAuthorizationStatus authStatus) {
            NSLog(@"|============| deviceType:%d, authStatus:%d |============|",(int)deviceType,(int)authStatus);
            [weakSelf deviceAuthorization:authStatus deviceType:deviceType];
        };
        
        KSCapturerSetting *capturerSetting     = [[KSCapturerSetting alloc] init];
        capturerSetting.isFront                = YES;
        capturerSetting.authCallback           = authCallback;
        //capturerSetting.resolution           = CGSizeMake(540, 960);
  
        KSMediaSetting *setting                = [[KSMediaSetting alloc] initWithConnectionSetting:connectionSetting capturerSetting:capturerSetting callType:self.myType];
        [KSRTCManager initRTCWithMediaSetting:setting];
    }
    [self createLocalView];
}

- (void)deviceAuthorization:(AVAuthorizationStatus)authStatus deviceType:(KSDeviceType)deviceType {
    if (authStatus == AVAuthorizationStatusDenied) {
        NSString *message = nil;
        switch (deviceType) {
            case KSDeviceTypeMicrophone:
                message = @"ks_app_global_text_auth_microphone";
                break;
            case KSDeviceTypeCamera:
                message = @"ks_app_global_text_auth_camera";
                break;
            default:
                break;
        }
        KSAlertInfo *alertInfo = [[KSAlertInfo alloc] initWithType:KSAlertTypeConfirml
                                                             title:nil
                                                           message:message
                                                            cancel:nil
                                                          confirml:@"ks_app_global_text_confirml"
                                                            target:self];
        [KSAlertController showInfo:alertInfo callback:^(KSAlertType actionType) {
        }];
    }
}

- (void)createLocalView {
    switch (self.myType) {
        case KSCallTypeSingleAudio:
        case KSCallTypeSingleVideo:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                //[self.callView setScreenMediaTrack:[KSRTCManager shared].localMediaTrack];
                [self.callView setScreenMediaTrack:[KSRTCManager shared].screenMediaTrack];
            });
        }
            break;
        case KSCallTypeManyAudio:
            
            break;
        case KSCallTypeManyVideo:
        {
            [self.callView reloadCollectionView];
        }
            break;
        default:
            break;
    }
}

- (void)setAnswerState:(KSAnswerState)state {
    [self.callView setAnswerState:state];
    if (self.myType != KSCallTypeSingleAudio) {
        
    }
}

#pragma mark - 事件枚举switch
- (void)triggerEvent:(KSEventType)eventType info:(id)info {}

#pragma mark - 页面ViewModel
- (KSProfileInfo *)profileWithTitle:(NSString *)title {
    KSProfileInfo *profileInfo = [KSProfileInfo profileWithCallType:self.myType isCalled:self.isCalled title:title];
    return profileInfo;
}

- (void)updateProfileInfo:(KSProfileInfo *)profileInfo {
    [self.callView setProfileInfo:profileInfo];
}

#pragma mark - KSCallViewDataSource
- (NSInteger)callView:(KSCallView *)callView numberOfItemsInSection:(NSInteger)section {
    return [KSRTCManager shared].mediaTrackCount;
}

- (KSMediaTrack *)callView:(KSCallView *)callView itemAtIndexPath:(NSIndexPath *)indexPath {
    return [KSRTCManager mediaTrackOfIndex:indexPath.item];
}

- (KSCallType)callTypeOfCallView:(KSCallView *)callView {
    return self.myType;
}

//懒加载
-(KSTopBarView *)topBarView {
    if (_topBarView == nil) {
        KSTopBarView *topBarView = [[KSTopBarView alloc] initWithFrame:self.superBar.bounds];
        topBarView.dataSource    = self;
        topBarView.delegate      = self;
        [self.superBar addSubview:topBarView];
        _topBarView              = topBarView;
        //[topBarView.identifierBtn addTarget:self action:@selector(onIdentifierClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _topBarView;
}

#pragma mark - Get
-(KSCallType)myType {
    return [KSRTCManager shared].callType;
}

-(long long)peerId {
    return [KSRTCManager shared].peerId;
}
-(void)setPeerId:(int)inId {
}

-(BOOL)isCalled {
    return [KSRTCManager shared].isCalled;
}
-(void)setIsCalled:(BOOL)isInCalled {
}

#pragma mark - KSTopBarViewDataSource
- (NSMutableArray *)menuDatasOfTopBarView:(KSTopBarView *)topBarView {
    if (self.myType == KSCallTypeSingleAudio) {
        return [KSBtnInfo topAudioBarBtns];
    }
    if (self.myType == KSCallTypeSingleVideo) {
        return [KSBtnInfo topVideoBarBtns];
    }
    return [NSMutableArray array];
}

- (NSString *)sessionIDOfTopBarView:(KSTopBarView *)topBarView {
    return [[KSRTCManager shared].session.room uppercaseString];
}

#pragma mark - KSTopBarViewDelegate
- (void)topBarView:(KSTopBarView *)topBarView btnInfo:(KSBtnInfo *)btnInfo {
    switch (btnInfo.btnType) {
        case KSCallBarBtnTypeSwitchCamera:
            [KSRTCManager switchCamera];
            break;
        case KSCallBarBtnTypeAddMember:
            [self showMessage:@"ks_app_global_text_look_forward_to"];
            break;
        case KSCallBarBtnTypeZoomOut:
            [self tileWindow];
            break;
        default:
            break;
    }
}

#pragma mark - 小窗
- (void)tileWindow {
    [_callView clearRender];
    [_topBarView hiddenKit];

    [KSRTCManager displayTile];

    [self closeCtrl];
}

#pragma mark - KSRTCManagerDelegate
- (void)rtcManager:(KSRTCManager *)rtcManager didAddMediaTrack:(KSMediaTrack *)mediaTrack {
    switch (self.myType) {
        case KSCallTypeSingleAudio:
        case KSCallTypeSingleVideo:
        {
            if (mediaTrack.isLocal) {
                
            }
            else{
                [self.callView setScreenMediaTrack:[KSRTCManager shared].screenMediaTrack];
                [self.callView setTileMediaTrack:[KSRTCManager shared].tileMediaTrack];
            }
        }
            break;
        case KSCallTypeManyAudio:
        case KSCallTypeManyVideo:
        {
            [self.callView reloadCollectionView];
        }
            break;
        default:
            break;
    }
}

- (void)rtcManager:(KSRTCManager *)rtcManager answer:(KSAnswer *)answer {
    
}

#pragma mark - Message
- (void)showMessage:(NSString *)message {
    [SVProgressHUD showSuccessWithStatus:message.localizde];
}

@end
