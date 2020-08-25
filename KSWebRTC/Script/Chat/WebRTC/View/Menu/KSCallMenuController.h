//
//  KSCallMenuController.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/24.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSCallMenu.h"
@protocol KSCallMenuControllerDelegate <NSObject>
- (void)didSelectMenuOfMenuType:(KSCallMenuType)menuType;
@end

@interface KSCallMenuController : UIViewController
@property(nonatomic,copy)KSCallMenuCallback callback;

+(void)enterCallMenuWithCallback:(KSCallMenuCallback)callback target:(UIViewController *)target;

@end

