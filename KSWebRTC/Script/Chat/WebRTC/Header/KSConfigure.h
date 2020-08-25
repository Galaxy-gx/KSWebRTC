//
//  KSConfigure.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/2.
//  Copyright © 2020 saeipi. All rights reserved.
//

#ifndef KSConfigure_h
#define KSConfigure_h

typedef NS_ENUM(NSInteger, KSContentMode) {
    KSContentModeScaleAspectFit,      //保持完整高填充
    KSContentModeScaleAspectFill,     //保持完整宽填充
};

typedef NS_ENUM(NSInteger, KSResizingMode) {
    KSResizingModeTile,//小块
    KSResizingModeScreen,//全屏
};

typedef NS_ENUM(NSInteger, KSCallType) {
    KSCallTypeUnknown,
    KSCallTypeSingleAudio,//一对一语音
    KSCallTypeManyAudio,//多人语音
    KSCallTypeSingleVideo,//一对一视频
    KSCallTypeManyVideo,//多人视频
};

typedef NS_ENUM(NSInteger, KSAnswerState) {
    KSAnswerStateAwait,//等待
    KSAnswerStateJoin,//接通
};

typedef NS_ENUM(NSInteger, KSIdentity) {
    KSIdentityUnknown,
    KSIdentityLocal,
    KSIdentityRemote,
};

typedef NS_ENUM(NSInteger, KSDragState) {
    KSDragStateInactivity,//不活动的
    KSDragStateActivity,//活动的
};

typedef NS_ENUM(NSInteger, KSManipulation) {
    KSManipulationSaveDisplay,//存储并展示
    KSManipulationSave,//存储
    KSManipulationDisplay,//展示
};

struct KSScale {
    CGFloat width;
    CGFloat height;
};
typedef struct KSScale KSScale;

CG_INLINE KSScale KSScaleMake(CGFloat width, CGFloat height);
CG_INLINE KSScale
KSScaleMake(CGFloat width, CGFloat height)
{
  KSScale s; s.width = width; s.height = height; return s;
}

#endif /* KSConfigure_h */
