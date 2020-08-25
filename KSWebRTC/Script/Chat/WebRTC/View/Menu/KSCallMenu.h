//
//  KSCallMenu.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/24.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSBlock.h"

@interface KSCallMenu : NSObject
@property (nonatomic,assign) KSCallMenuType menuType;
@property (nonatomic,copy  ) NSString       *title;
@property (nonatomic,copy  ) NSString       *defaultIcon;
@property (nonatomic,copy  ) NSString       *selectedIcon;

+ (NSMutableArray *)callMenus;

@end
