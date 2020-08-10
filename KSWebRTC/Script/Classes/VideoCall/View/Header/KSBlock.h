//
//  KSBlock.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/10.
//  Copyright © 2020 saeipi. All rights reserved.
//

#ifndef KSBlock_h
#define KSBlock_h

typedef NS_ENUM(NSInteger, KSEventType) {
    KSEventTypeCallerHangup,//呼叫时，呼叫方挂断
    KSEventTypeCalleeHangup,//被叫方挂断
    KSEventTypeCalleeAnswer,//被叫方接听
    KSEventTypeInConversationMicrophoneOpen,//会话中开启麦克风
    KSEventTypeInConversationMicrophoneClose,//会话中关闭麦克风
    KSEventTypeInConversationVolumeOpen,//会话中开启
    KSEventTypeInConversationVolumeClose,//会话中静音
    KSEventTypeInConversationCameraOpen,//会话中开启摄像机
    KSEventTypeInConversationCameraClose,//会话中关闭摄像机
    KSEventTypeInConversationBluetoothOpen,//会话中开启蓝牙
    KSEventTypeInConversationBluetoothClose,//会话中关闭蓝牙
    KSEventTypeInConversationHangup,//会话中挂断
    
    KSEventTypeMeetingThemeMicrophoneOpen,//会话中开启麦克风
    KSEventTypeMeetingThemeMicrophoneClose,//会话中关闭麦克风
    KSEventTypeMeetingThemeVolumeOpen,//会话中开启
    KSEventTypeMeetingThemeVolumeClose,//会话中静音
    KSEventTypeMeetingThemeCameraOpen,//会话中开启摄像机
    KSEventTypeMeetingThemeCameraClose,//会话中关闭摄像机
    KSEventTypeMeetingThemeBluetoothOpen,//会话中开启蓝牙
    KSEventTypeMeetingThemeBluetoothClose,//会话中关闭蓝牙
    KSEventTypeStartMeeting,//开始会议
};

//kse (^eventCallback)(KSEventType eventType,NSDictionary *info)

typedef void(^KSEventCallback)(KSEventType eventType,NSDictionary *info);

#endif /* KSBlock_h */
