//
//  KSProfileInfo.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/7.
//  Copyright © 2020 saeipi. All rights reserved.
//  Height:204

#import "KSProfileInfo.h"
#import "UIFont+Category.h"
#import "NSString+Category.h"
#import "KSUserInfo.h"

@implementation KSProfileInfo

-(void)setDesc:(NSString *)desc {
    _desc = desc;
    [self updateCallback];
}

-(void)setTitle:(NSString *)title {
    _title = title;
    [self updateCallback];
}

-(void)updateCallback {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(profileInfoUpdate:)]) {
            [self.delegate profileInfoUpdate:self];
        }
    }
}

//- (void)initProperty {
//    _timekeeper = [[KSTimekeeper alloc] init];
//}
//
//- (void)startTiming {
//    [self stopTiming];
//    __weak typeof(self) weakSelf = self;
//    [_timekeeper timingOfCallback:^(KSTimekeeperInfo *timing) {
//        weakSelf.desc = [NSString stringWithFormat:@"%.2d:%.2d:%.2d",timing.hours,timing.minute,timing.second];
//    }];
//}
//
//- (void)stopTiming {
//    [_timekeeper invalidate];
//}
//
//-(void)dealloc {
//    [self stopTiming];
//}

+ (KSProfileInfo *)profileWithCallType:(KSCallType)callType isCalled:(BOOL)isCalled title:(NSString *)title {
    KSProfileInfo *profile = [[KSProfileInfo alloc] init];
    profile.verticalOffst  = -100;
    profile.title          = title;
    profile.myname         = [KSUserInfo myself].name;
    profile.titleFont      = [UIFont ks_fontRegularOfSize:KS_Extern_30Font];
    profile.titleOffst     = KS_Extern_Point32;
    profile.descFont       = [UIFont ks_fontRegularOfSize:KS_Extern_16Font];
    profile.descOffst      = KS_Extern_Point08;
    [profile updateDescOfCallType:callType isCalled:isCalled];
    
    CGFloat screen_w       = [UIScreen mainScreen].bounds.size.width;
    CGFloat screen_h       = [UIScreen mainScreen].bounds.size.height;
    if (screen_w == 320 && screen_h == 568) {
        profile.verticalOffst = 100;
    }
    return profile;
}

- (void)updateDescOfCallType:(KSCallType)callType isCalled:(BOOL)isCalled {
    NSString *desc = nil;
    if (isCalled) {
        switch (callType) {
            case KSCallTypeSingleVideo:
            case KSCallTypeManyVideo:
                desc = @"ks_app_global_text_invite_video_call";
                break;
                case KSCallTypeSingleAudio:
                case KSCallTypeManyAudio:
                    desc = @"ks_app_global_text_invite_voice_call";
                    break;
            default:
                break;
        }
    }
    else{
        desc = @"ks_app_global_text_calling";
    }
    _desc = desc.localizde;
}

@end
