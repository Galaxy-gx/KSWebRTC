//
//  KSProfileBarView.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KSAudioStateType) {
    KSAudioStateTypeUnknown,
    KSAudioStateTypeMute,
    KSAudioStateTypeSound,
};

@interface KSProfileBarView : UIView

@property(nonatomic,assign)KSAudioStateType stateType;

- (void)setUserName:(NSString *)name;
- (void)updateStateType:(KSAudioStateType)stateType;

@end
