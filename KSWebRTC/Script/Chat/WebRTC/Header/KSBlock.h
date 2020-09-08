//
//  KSBlock.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/10.
//  Copyright © 2020 saeipi. All rights reserved.
//

#ifndef KSBlock_h
#define KSBlock_h
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, KSEventType) {
    KSEventTypeStartUnknown                  = 0,//未知
    KSEventTypeCallHangup                    = 1,//挂断
    //KSEventTypeCalleeHangup                  = 1,//被叫方挂断
    KSEventTypeCalleeAnswer                  = 2,//被叫方接听
    KSEventTypeInConversationMicrophoneOpen  = 3,//会话中开启麦克风
    KSEventTypeInConversationMicrophoneClose = 4,//会话中关闭麦克风
    KSEventTypeInConversationVolumeOpen      = 5,//会话中开启声音
    KSEventTypeInConversationVolumeClose     = 6,//会话中静音
    KSEventTypeInConversationCameraOpen      = 7,//会话中开启摄像机
    KSEventTypeInConversationCameraClose     = 8,//会话中关闭摄像机
    KSEventTypeInConversationBluetoothOpen   = 9,//会话中开启蓝牙
    KSEventTypeInConversationBluetoothClose  = 10,//会话中关闭蓝牙
    //KSEventTypeInConversationHangup          = 11,//会话中挂断
    KSEventTypeMeetingThemeMicrophoneOpen    = 12,//会议主题开启麦克风
    KSEventTypeMeetingThemeMicrophoneClose   = 13,//会议主题关闭麦克风
    KSEventTypeMeetingThemeVolumeOpen        = 14,//会议主题开启声音
    KSEventTypeMeetingThemeVolumeClose       = 15,//会议主题静音
    KSEventTypeMeetingThemeCameraOpen        = 16,//会议主题开启摄像机
    KSEventTypeMeetingThemeCameraClose       = 17,//会议主题关闭摄像机
    KSEventTypeMeetingThemeBluetoothOpen     = 18,//会议主题开启蓝牙
    KSEventTypeMeetingThemeBluetoothClose    = 19,//会议主题关闭蓝牙
    KSEventTypeStartMeeting                  = 20,//开始会议
    KSEventTypeStartSwitch                   = 21,//开始会议
};

typedef NS_ENUM(NSInteger, KSCallMenuType) {
    KSCallMenuTypeVideo,
    KSCallMenuTypeVoice,
    KSCallMenuTypeCancel,
};

typedef NS_ENUM(NSInteger, KSDeviceType) {
    KSDeviceTypeMicrophone,
    KSDeviceTypeCamera,
};

typedef void(^KSEventCallback)(KSEventType eventType,id info);
typedef void(^KSCallMenuCallback)(KSCallMenuType menuType);
typedef void(^KSAuthorizationCallback)(KSDeviceType deviceType, AVAuthorizationStatus authStatus);

#endif /* KSBlock_h */
