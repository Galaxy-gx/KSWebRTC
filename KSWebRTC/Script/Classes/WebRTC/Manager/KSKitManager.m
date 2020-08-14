//
//  KSKitManager.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/14.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSKitManager.h"
#import "KSWebRTCManager.h"
#import "UIFont+Category.h"
#import "UIButton+Category.h"

@interface KSKitManager()<KSWebRTCManagerDelegate,KSCallViewDataSource>

@property (nonatomic,assign) KSCallType           callType;
@property (nonatomic,strong) KSTileLayout         *tileLayout;
@property (nonatomic,strong) KSProfileConfigure   *profile;
@property (nonatomic,copy  ) KSEventCallback      callback;

@end

@implementation KSKitManager

- (instancetype)initWithFrame:(CGRect)frame callType:(KSCallType)callType tileLayout:(KSTileLayout *)tileLayout callback:(KSEventCallback)callback profile:(KSProfileConfigure *)profile {
    if (self = [super initWithFrame:frame]) {
        self.callType = callType;
        self.callback = callback;
        self.profile  = profile;
        
        [self initKit];
    }
    return self;
}

- (void)initKit {
    KSCallView *callView = [[KSCallView alloc] initWithFrame:self.bounds tileLayout:_tileLayout];
    callView.dataSource  = self;
    _callView            = callView;
    [callView setEventCallback:_callback];
    [self addSubview:callView];


    [_callView setProfileConfigure:_profile];
    [_callView setAnswerState:KSAnswerStateAwait];
}

- (void)initWebRTC {
    __weak typeof(self) weakSelf = self;
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
            _tileLayout.resizingMode = KSResizingModeScreen;
            [_callView createLocalViewWithTileLayout:_tileLayout];
            [_callView setLocalViewSession:[KSWebRTCManager shared].captureSession];
        }
            break;
        case KSCallTypeManyAudio:
            
            break;
        case KSCallTypeSingleVideo:
        {
            _tileLayout.resizingMode = KSResizingModeScreen;
            [_callView createLocalViewWithTileLayout:_tileLayout];
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

//KSWebRTCManagerDelegate
- (void)webRTCManagerHandlerEndOfSession:(KSWebRTCManager *)webRTCManager {
    //会话结束
    if (self.callType == KSCallTypeSingleVideo || self.callType == KSCallTypeSingleVideo) {
        //次方法省略？
        [_callView leaveLocal];
    }
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
    switch (_callType) {
        case KSCallTypeSingleAudio:

            break;
        case KSCallTypeManyAudio:
            
            break;
        case KSCallTypeSingleVideo:
            connection.mediaInfo.callType = _callType;
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

@end
