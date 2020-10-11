//
//  KSCallState.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/8.
//  Copyright © 2020 saeipi. All rights reserved.
//

#ifndef KSCallState_h
#define KSCallState_h

/*
typedef NS_ENUM(NSInteger, KSCallState) {
    KSCallStateNone = 0,          //未连状态
    //KSCallStateCallerJoining,     //主叫方加入, 等待服务器返回结果，是否加入成功 （新的协议该状态省去）
    //KSCallStateCallerCalling,     //主叫方呼叫, 等待被叫方的加入
    //KSCallStateCallerOffering,    //主叫方发送offer, 等待被叫方的offer，和answer
    KSCallStateCalleeBeingCalled, //被叫方正在收到主叫方的呼叫
    //KSCallStateCalleeRinging,     //被叫方，呼叫画面出现，处于响铃状态
    //KSCallStateCalleeJoining,     //被叫方加入，等待服务器的返回结果，是否加入成功，加入成功，如果此时还收到主叫方的的calling，则表明主叫方没有收到自己的加入成功的包，此时需要再次调用join
    //KSCallStateCalleeOffering,    //被叫方发送offer, 如果发送offer成功，但是此时还是收到主叫方的offer包，则表明主叫方没有收到
    KSCallStateRecording,         //通话中
    //KSCallStateCallEnded          //通话结束
};
*/

//typedef NS_ENUM(NSInteger, KSCallState) {
//    KSCallStateNone = 0,          //未连状态
//    KSCallStateCalleeBeingCalled, //被叫方正在收到主叫方的呼叫
//    KSCallStateRecording,         //通话中
//};


typedef NS_ENUM(NSInteger, KSCallEndType) {
    KSCallEndTypeNormal = 0,  //通话正常结束
    KSCallEndTypeCancel,      //通话未成功，主叫方取消
    KSCallEndTypeDecline,     //通话为成功，被叫方挂断
    KSCallEndTypeNoAnswer     //通话结束无人接听
};

//通话状态维护
typedef NS_ENUM(NSInteger, KSCallStateMaintenance) {
    KSCallStateMaintenanceNormal = 0,//初始状态
    KSCallStateMaintenanceCaller,//主叫方发起Call
    KSCallStateMaintenanceCalled,//主叫方完成Call信令发送
    KSCallStateMaintenanceRinger,//被叫方收到Call准备响铃
    KSCallStateMaintenanceRinged,//被叫方发送响铃/主叫方收到响铃（此时等待被叫方接听）
    KSCallStateMaintenanceAnswoer,//主叫方收到接听/被叫方按下接听
    KSCallStateMaintenanceRecording,//通话中
    //KSCallStateMaintenanceLeave,//一方发送Leave消息（发送后不再处理收到的消息！！！）
    //KSCallStateMaintenanceLeft,//一方收到Left，回一个Leave消息（发送后不再处理收到的消息！！！）
    //KSCallStateMaintenanceDecline,//一方送到Decline,再收到Left后收到（不做任何处理）
    //KSCallStateMaintenanceCallEnded//通话结束
};

typedef NS_ENUM(NSInteger, KSWebRTCStatus) {
    KSWebRTCStatusCaller             = 0x00000001,      //是否为主叫 1 为是 0为被叫
    KSWebRTCStatusUseNewProtocol     = 0x00000001<<1,   //是否使用新协议 1 为使用新协议 0为使用旧协议
    KSWebRTCStatusCallerJoin         = 0x00000001<<2,   //主叫是否加入房间
    KSWebRTCStatusCalleeJoin         = 0x00000001<<3,   //被叫是否加入房间
    KSWebRTCStatusSendCall           = 0x00000001<<4,   //主叫是否发送了Call包
    KSWebRTCStatusReceCall           = 0x00000001<<5,   //是否收到了Call包
    KSWebRTCStatusSendOffer          = 0x00000001<<6,   //是否发送了Offer包
    KSWebRTCStatusReceOffer          = 0x00000001<<7,   //是否收到了Offer包
    KSWebRTCStatusSendHostCandidate  = 0x00000001<<8,   //是否发送了Host类型的candidate包
    KSWebRTCStatusReceHostCandidate  = 0x00000001<<9,   //是否收到了Host类型的candidate包
    KSWebRTCStatusSendSrflxCandidate = 0x00000001<<10,  //是否发送了Srflx类型的candidate包
    KSWebRTCStatusReceSrflxCandidate = 0x00000001<<11,  //是否收到了Srflx类型的candidate包
    KSWebRTCStatusSendRelayCandidate = 0x00000001<<12,  //是否发送了Relay类型的candidate包
    KSWebRTCStatusReceRelayCandidate = 0x00000001<<13,  //是否收到了Relay类型的candidate包
    KSWebRTCStatusSendAnswer         = 0x00000001<<14,  //是否发送了answer包
    KSWebRTCStatusReceAnswer         = 0x00000001<<15,  //是否收到了answer包
    KSWebRTCStatusAutoConnect        = 0x00000001<<16,  //是否自动连接
    KSWebRTCStatusTransform          = 0x00000001<<17,  //是否从主叫转为被叫
    KSWebRTCStatusWebRTCSuccessed    = 0x00000001<<18   //是否成功建立的连接
};

typedef NS_ENUM(NSInteger, KSMediaState) {
    KSMediaStateUnknown     = 0,
    KSMediaStateUnmuteAudio = 1,
    KSMediaStateMuteAudio   = 2,//静音
    KSMediaStateUnmuteVideo = 3,
    KSMediaStateMuteVideo   = 4,//关闭视频
    KSMediaStateTalking     = 5,//发声中
};

#endif /* KSCallState_h */
