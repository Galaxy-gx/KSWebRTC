//
//  KSProfileInfo.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/7.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSConfigure.h"

@class KSProfileInfo;
@protocol KSProfileInfoDelegate <NSObject>
- (void)profileInfoUpdate:(KSProfileInfo *)profileInfo;
@end
@interface KSProfileInfo : NSObject

@property(nonatomic,weak)id<KSProfileInfoDelegate> delegate;
@property (nonatomic,assign) int      verticalOffst;

@property (nonatomic,copy  ) NSString *title;
@property (nonatomic,strong) UIFont   *titleFont;
@property (nonatomic,assign) int      titleOffst;

@property (nonatomic,copy  ) NSString *desc;
@property (nonatomic,strong) UIFont   *descFont;
@property (nonatomic,assign) int      descOffst;

@property (nonatomic,copy  ) NSString *myname;
@property (nonatomic,assign) BOOL     isHidden;

+ (KSProfileInfo *)profileWithCallType:(KSCallType)callType isCalled:(BOOL)isCalled title:(NSString *)title;
- (void)updateDescOfCallType:(KSCallType)callType isCalled:(BOOL)isCalled;

@end
