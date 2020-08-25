//
//  KSBtnInfo.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, KSCallBarBtnType) {
    KSCallBarBtnTypeMicrophone,
    KSCallBarBtnTypeVolume,
    KSCallBarBtnTypeCamera,
    KSCallBarBtnTypeBluetooth,
    KSCallBarBtnTypePhone,
};

@interface KSBtnInfo : NSObject

@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *defaultIcon;
@property(nonatomic,copy)NSString *selectedIcon;
@property(nonatomic,copy)NSString *icon;
@property(nonatomic,assign)BOOL isSelected;
@property(nonatomic,assign)KSCallBarBtnType btnType;

+(NSMutableArray *)callBarBtns;
+(NSMutableArray *)meetingBarBtns;
+(NSMutableArray *)threeBarBtns;
@end
