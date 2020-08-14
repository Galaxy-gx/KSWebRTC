//
//  KSKitsController.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/7.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSKitsController.h"
#import "KSCallBarView.h"
#import "KSTopBarView.h"
#import "KSAnswerBarView.h"
#import "KSProfileView.h"
#import "KSMeetingThemeView.h"
#import "KSRemoteView.h"
#import "KSWaitingAnswersGroupView.h"
#import "KSLayoutButton.h"
#import "KSCoolHUB.h"
#import "KSCallController.h"
#import "KSSuperController+Category.h"
#import "UIButton+Category.h"
#import "UIColor+Category.h"
#import "UIFont+Category.h"

@interface KSKitsController ()

@property(nonatomic,weak)KSCoolHUB *coolHUB;

@end

@implementation KSKitsController

- (void)viewDidLoad {
    [super viewDidLoad];
//    int self_w = self.view.frame.size.width;
//    int padding = 20;
// 
//    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
//    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height *2.5);
//    scrollView.backgroundColor = [UIColor ks_colorWithHexString:@"#15161A"];
//    self.view = scrollView;
//    
//    KSTopBarView *topBarView = [[KSTopBarView alloc] initWithFrame:CGRectMake(0, 0, self_w, 86)];
//    [self.view addSubview:topBarView];
//    
//    KSCallBarView *callBarView = [[KSCallBarView alloc] initWithFrame:CGRectMake(KS_Extern_12Font, CGRectGetMaxY(topBarView.frame) + padding, self_w - KS_Extern_Point12 * 2, KS_Extern_Point48)];
//    [self.view addSubview:callBarView];
//    
//    KSAnswerBarView *answerBarView = [[KSAnswerBarView alloc] initWithFrame:CGRectMake(56, CGRectGetMaxY(callBarView.frame) + padding, self_w - 56 * 2, 90)];
//    answerBarView.answerState = KSAnswerStateJoin;
//    [self.view addSubview:answerBarView];
//    
//    
//    KSProfileConfigure *configure = [[KSProfileConfigure alloc] init];
//    configure.title = @"Hamasaki Ayumi";
//    configure.titleFont = [UIFont ks_fontRegularOfSize:KS_Extern_30Font];
//    configure.titleOffst = KS_Extern_Point32;
//    configure.desc = @"Invite you to a video call";
//    configure.descFont = [UIFont ks_fontRegularOfSize:KS_Extern_16Font];
//    configure.descOffst = KS_Extern_Point08;
//    
//    KSProfileView *profileView = [[KSProfileView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(answerBarView.frame) + padding, self_w, 204) configure:configure];
//    [self.view addSubview:profileView];
//    
//    KSMeetingThemeView *meetingThemeView = [[KSMeetingThemeView alloc] initWithFrame:CGRectMake((self_w - 252)/2, CGRectGetMaxY(profileView.frame) + padding, 252, 257)];
//    [self.view addSubview:meetingThemeView];
//    
//    KSRemoteView *remoteView = [[KSRemoteView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(meetingThemeView.frame) + padding, (self_w-4)/2, (self_w-4)/2) scale:KSScaleMake(1, 1) mode:KSContentModeScaleAspectFit callType:KSCallTypeManyAudio];
//    [self.view addSubview:remoteView];
//    
//    KSRemoteView *remoteView1 = [[KSRemoteView alloc] initWithFrame:CGRectMake((self_w-4)/2 + 2, CGRectGetMaxY(meetingThemeView.frame) + padding, (self_w-4)/2, (self_w-4)/2) scale:KSScaleMake(1, 1) mode:KSContentModeScaleAspectFit callType:KSCallTypeManyAudio];
//    [self.view addSubview:remoteView1];
//    
//    
//    KSWaitingAnswersGroupView *waitingAnswersGroupView = [[KSWaitingAnswersGroupView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(remoteView.frame) + padding, self_w, KS_Extern_Point150)];
//    [self.view addSubview:waitingAnswersGroupView];
    
    
    KSLayoutButton *voiceAnsweringBtn = [[KSLayoutButton alloc] initWithFrame:CGRectMake(0, 100, KS_Extern_Point100, 46)
                                                                   layoutType:KSButtonLayoutTypeTitleBottom
                                                                        title:@"ks_meeting_btn_voice_answering"
                                                                         font:[UIFont ks_fontRegularOfSize:KS_Extern_13Font]
                                                                    textColor:[UIColor ks_white]
                                                                    normalImg:@"icon_bar_rings_small_white"
                                                                    selectImg:@"icon_bar_rings_small_white"
                                                                        space:KS_Extern_Point08
                                                                   imageWidth:KS_Extern_Point20
                                                                  imageHeight:KS_Extern_Point20];
    [self.view addSubview:voiceAnsweringBtn];
    [voiceAnsweringBtn ks_addTarget:self action:@selector(onVoiceAnsweringClick)];
    
    // Do any additional setup after loading the view.
}

- (void)onVoiceAnsweringClick {
    [self.coolHUB showMessage:@"您已打开摄像头"];

    //self.modalPresentationStyle     = UIModalPresentationFullScreen;
    KSCallController *ctrl          = [[KSCallController alloc] init];
    ctrl.isSuperBar                 = YES;
    ctrl.displayFlag = KSDisplayFlagAnimatedFirst;
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
    navCtrl.modalPresentationStyle     = UIModalPresentationFullScreen;
    
    [self presentViewController:navCtrl animated:NO completion:nil];
}

-(KSCoolHUB *)coolHUB {
    if (_coolHUB == NULL) {
        KSCoolHUB *coolHUB = [[KSCoolHUB alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:coolHUB];
        _coolHUB = coolHUB;
    }
    return _coolHUB;
}

@end
