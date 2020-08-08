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
    KSCallTypeSingleAudio,
    KSCallTypeManyAudio,
    KSCallTypeSingleVideo,
    KSCallTypeManyVideo,
};

//typedef NS_ENUM(NSInteger, KSIdentity) {
//    KSIdentityUnknown,
//    KSIdentityLocal,
//    KSIdentityRemote,
//};

typedef NS_ENUM(NSInteger, KSDragState) {
    KSDragStateInactivity,
    KSDragStateActivity,
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
