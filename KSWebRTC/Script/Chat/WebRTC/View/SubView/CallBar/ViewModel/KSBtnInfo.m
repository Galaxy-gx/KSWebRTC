//
//  KSBtnInfo.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSBtnInfo.h"
#import "NSString+Category.h"
@implementation KSBtnInfo

-(instancetype)initWithTitle:(NSString *)title defaultIcon:(NSString *)defaultIcon selectedIcon:(NSString *)selectedIcon isSelected:(BOOL)isSelected btnType:(KSCallBarBtnType)btnType {
    if (self = [super init]){
        _title        = title.localizde;
        _defaultIcon  = defaultIcon;
        _selectedIcon = selectedIcon;
        _isSelected   = isSelected;
        _btnType      = btnType;
        _isTouch      = YES;
    }
    return self;
}

-(NSString *)icon {
    if (_isSelected) {
        return _selectedIcon;
    }
    return _defaultIcon;
}

+(NSMutableArray *)callBarBtnsWithCallType:(KSCallType)callType deviceSwitch:(KSDeviceSwitch *)deviceSwitch {
    KSBtnInfo *btn1 = [[KSBtnInfo alloc] initWithTitle:nil
                                           defaultIcon:@"icon_bar_microphone_white" selectedIcon:@"icon_bar_microphone_red" isSelected:!deviceSwitch.microphoneEnabled btnType:KSCallBarBtnTypeMicrophone];
    KSBtnInfo *btn2 = [[KSBtnInfo alloc] initWithTitle:nil
                                           defaultIcon:@"icon_bar_volume_white" selectedIcon:@"icon_bar_volume_red" isSelected:!deviceSwitch.speakerEnabled btnType:KSCallBarBtnTypeSpeaker];
    KSBtnInfo *btn3 = [[KSBtnInfo alloc] initWithTitle:nil
                                           defaultIcon:@"icon_bar_camera_white" selectedIcon:@"icon_bar_camera_red" isSelected:!deviceSwitch.cameraEnabled btnType:KSCallBarBtnTypeCamera];
    if (callType == KSCallTypeSingleAudio) {
        btn3.isSelected = YES;
        btn3.isTouch    = NO;
    }
    /*
    KSBtnInfo *btn4 = [[KSBtnInfo alloc] initWithTitle:nil
                                           defaultIcon:@"icon_bar_bluetoot_white" selectedIcon:@"icon_bar_bluetoot_white" isSelected:NO btnType:KSCallBarBtnTypeBluetooth];
     */
    KSBtnInfo *btn5 = [[KSBtnInfo alloc] initWithTitle:nil
                                           defaultIcon:@"icon_bar_hangup_small_red" selectedIcon:@"icon_bar_hangup_small_red" isSelected:NO btnType:KSCallBarBtnTypePhone];
    NSMutableArray *btns = [NSMutableArray arrayWithObjects:btn1,btn2,btn3,btn5, nil];
    return btns;
}

+(NSMutableArray *)meetingBarBtns {
    KSBtnInfo *btn1 = [[KSBtnInfo alloc] initWithTitle:@"ks_app_global_text_microphone"
                                           defaultIcon:@"icon_bar_microphone_white" selectedIcon:@"icon_bar_microphone_red" isSelected:NO btnType:KSCallBarBtnTypeMicrophone];
    KSBtnInfo *btn2 = [[KSBtnInfo alloc] initWithTitle:@"ks_app_global_text_volume"
                                           defaultIcon:@"icon_bar_volume_white" selectedIcon:@"icon_bar_volume_red" isSelected:NO btnType:KSCallBarBtnTypeSpeaker];
    KSBtnInfo *btn3 = [[KSBtnInfo alloc] initWithTitle:@"ks_app_global_text_camera"
                                           defaultIcon:@"icon_bar_camera_white" selectedIcon:@"icon_bar_camera_red" isSelected:NO btnType:KSCallBarBtnTypeCamera];
    KSBtnInfo *btn4 = [[KSBtnInfo alloc] initWithTitle:@"ks_app_global_text_bluetoot"
                                           defaultIcon:@"icon_bar_bluetoot_white" selectedIcon:@"icon_bar_bluetoot_white" isSelected:NO btnType:KSCallBarBtnTypeBluetooth];
    NSMutableArray *btns = [NSMutableArray arrayWithObjects:btn1,btn2,btn3,btn4, nil];
    return btns;
}

+(NSMutableArray *)threeBarBtns {
    KSBtnInfo *btn1      = [[KSBtnInfo alloc] initWithTitle:@"ks_app_global_text_camera"
                                                defaultIcon:@"icon_bar_camera_white" selectedIcon:@"icon_bar_camera_red" isSelected:NO btnType:KSCallBarBtnTypeCamera];

    KSBtnInfo *btn2      = [[KSBtnInfo alloc] initWithTitle:@"ks_app_global_text_microphone"
                                           defaultIcon:@"icon_bar_microphone_white" selectedIcon:@"icon_bar_microphone_red" isSelected:NO btnType:KSCallBarBtnTypeMicrophone];
    KSBtnInfo *btn3      = [[KSBtnInfo alloc] initWithTitle:@"ks_app_global_text_volume"
                                           defaultIcon:@"icon_bar_volume_white" selectedIcon:@"icon_bar_volume_red" isSelected:NO btnType:KSCallBarBtnTypeSpeaker];
    NSMutableArray *btns = [NSMutableArray arrayWithObjects:btn1,btn2,btn3, nil];
    return btns;
}

+(NSMutableArray *)topVideoBarBtns {
    KSBtnInfo *btn1      = [[KSBtnInfo alloc] initWithTitle:nil
                                                defaultIcon:@"icon_bar_switch_white" selectedIcon:@"icon_bar_switch_white" isSelected:NO btnType:KSCallBarBtnTypeSwitchCamera];

    KSBtnInfo *btn2      = [[KSBtnInfo alloc] initWithTitle:nil
                                           defaultIcon:@"icon_bar_add_members_white" selectedIcon:@"icon_bar_add_members_white" isSelected:NO btnType:KSCallBarBtnTypeAddMember];
    KSBtnInfo *btn3      = [[KSBtnInfo alloc] initWithTitle:nil
                                           defaultIcon:@"icon_bar_double_arrow_small_white" selectedIcon:@"icon_bar_double_arrow_small_white" isSelected:NO btnType:KSCallBarBtnTypeZoomOut];
    NSMutableArray *btns = [NSMutableArray arrayWithObjects:btn1,btn2,btn3, nil];
    return btns;
}

+(NSMutableArray *)topAudioBarBtns {
    KSBtnInfo *btn1      = [[KSBtnInfo alloc] initWithTitle:nil
                                           defaultIcon:@"icon_bar_add_members_white" selectedIcon:@"icon_bar_add_members_white" isSelected:NO btnType:KSCallBarBtnTypeMicrophone];
    KSBtnInfo *btn2      = [[KSBtnInfo alloc] initWithTitle:nil
                                           defaultIcon:@"icon_bar_double_arrow_small_white" selectedIcon:@"icon_bar_double_arrow_small_white" isSelected:NO btnType:KSCallBarBtnTypeZoomOut];
    NSMutableArray *btns = [NSMutableArray arrayWithObjects:btn1, btn2, nil];
    return btns;
}

@end

