//
//  KSProfileConfigure.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/7.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSProfileConfigure : UIView

@property(nonatomic,assign)int topPaddding;

@property(nonatomic,copy)NSString *title;
@property(nonatomic,strong)UIFont *titleFont;
@property(nonatomic,assign)int titleOffst;

@property(nonatomic,copy)NSString *desc;
@property(nonatomic,strong)UIFont *descFont;
@property(nonatomic,assign)int descOffst;

@end
