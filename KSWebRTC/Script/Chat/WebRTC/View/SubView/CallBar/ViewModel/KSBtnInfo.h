//
//  KSBtnInfo.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSConfigure.h"
#import "KSDeviceSwitch.h"
typedef NS_ENUM(NSInteger, KSCallBarBtnType) {
    KSCallBarBtnTypeMicrophone,
    KSCallBarBtnTypeSpeaker,
    KSCallBarBtnTypeCamera,
    KSCallBarBtnTypeBluetooth,
    KSCallBarBtnTypePhone,
    KSCallBarBtnTypeSwitchCamera,
    KSCallBarBtnTypeAddMember,
    KSCallBarBtnTypeZoomOut 
};

@interface KSBtnInfo : NSObject

@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *defaultIcon;
@property(nonatomic,copy)NSString *selectedIcon;
@property(nonatomic,copy)NSString *icon;
@property(nonatomic,assign)BOOL isSelected;
@property(nonatomic,assign)BOOL isTouch;
@property(nonatomic,assign)KSCallBarBtnType btnType;

+(NSMutableArray *)callBarBtnsWithCallType:(KSCallType)callType deviceSwitch:(KSDeviceSwitch *)deviceSwitch;
+(NSMutableArray *)meetingBarBtns;
+(NSMutableArray *)threeBarBtns;
+(NSMutableArray *)topVideoBarBtns;
+(NSMutableArray *)topAudioBarBtns;

@end
