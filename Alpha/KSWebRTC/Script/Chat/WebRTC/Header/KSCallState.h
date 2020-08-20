//
//  KSCallState.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/8.
//  Copyright © 2020 saeipi. All rights reserved.
//

#ifndef KSCallState_h
#define KSCallState_h

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

typedef NS_ENUM(NSInteger, KSCallEndType) {
    KSCallEndTypeNormal = 0,  //通话正常结束
    KSCallEndTypeCancel,      //通话未成功，主叫方取消
    KSCallEndTypeDecline,     //通话为成功，被叫方挂断
    KSCallEndTypeNoAnswer     //通话结束无人接听
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
    KSMediaStateMuteAudio,
    KSMediaStateUnmuteAudio,
    KSMediaStateMuteVideo,
    KSMediaStateUnmuteVideo,
    KSMediaStateTalking,
};

#endif /* KSCallState_h */
