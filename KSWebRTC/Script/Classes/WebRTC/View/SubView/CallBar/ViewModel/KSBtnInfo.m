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
    }
    return self;
}

-(NSString *)icon {
    if (_isSelected) {
        return _selectedIcon;
    }
    return _defaultIcon;
}

+(NSMutableArray *)callBarBtns {
    KSBtnInfo *btn1 = [[KSBtnInfo alloc] initWithTitle:nil
                                           defaultIcon:@"icon_bar_microphone_white" selectedIcon:@"icon_bar_microphone_red" isSelected:NO btnType:KSCallBarBtnTypeMicrophone];
    KSBtnInfo *btn2 = [[KSBtnInfo alloc] initWithTitle:nil
                                           defaultIcon:@"icon_bar_volume_white" selectedIcon:@"icon_bar_volume_red" isSelected:NO btnType:KSCallBarBtnTypeVolume];
    KSBtnInfo *btn3 = [[KSBtnInfo alloc] initWithTitle:nil
                                           defaultIcon:@"icon_bar_camera_white" selectedIcon:@"icon_bar_camera_red" isSelected:NO btnType:KSCallBarBtnTypeCamera];
    KSBtnInfo *btn4 = [[KSBtnInfo alloc] initWithTitle:nil
                                           defaultIcon:@"icon_bar_bluetoot_white" selectedIcon:@"icon_bar_bluetoot_white" isSelected:NO btnType:KSCallBarBtnTypeBluetooth];
    KSBtnInfo *btn5 = [[KSBtnInfo alloc] initWithTitle:nil
                                           defaultIcon:@"icon_bar_hangup_small_red" selectedIcon:@"icon_bar_hangup_small_red" isSelected:NO btnType:KSCallBarBtnTypePhone];
    NSMutableArray *btns = [NSMutableArray arrayWithObjects:btn1,btn2,btn3,btn4,btn5, nil];
    return btns;
}

+(NSMutableArray *)meetingBarBtns {
    KSBtnInfo *btn1 = [[KSBtnInfo alloc] initWithTitle:@"ks_app_global_text_microphone"
                                           defaultIcon:@"icon_bar_microphone_white" selectedIcon:@"icon_bar_microphone_red" isSelected:NO btnType:KSCallBarBtnTypeMicrophone];
    KSBtnInfo *btn2 = [[KSBtnInfo alloc] initWithTitle:@"ks_app_global_text_volume"
                                           defaultIcon:@"icon_bar_volume_white" selectedIcon:@"icon_bar_volume_red" isSelected:NO btnType:KSCallBarBtnTypeVolume];
    KSBtnInfo *btn3 = [[KSBtnInfo alloc] initWithTitle:@"ks_app_global_text_camera"
                                           defaultIcon:@"icon_bar_camera_white" selectedIcon:@"icon_bar_camera_red" isSelected:NO btnType:KSCallBarBtnTypeCamera];
    KSBtnInfo *btn4 = [[KSBtnInfo alloc] initWithTitle:@"ks_app_global_text_bluetoot"
                                           defaultIcon:@"icon_bar_bluetoot_white" selectedIcon:@"icon_bar_bluetoot_white" isSelected:NO btnType:KSCallBarBtnTypeBluetooth];
    NSMutableArray *btns = [NSMutableArray arrayWithObjects:btn1,btn2,btn3,btn4, nil];
    return btns;
}


@end
