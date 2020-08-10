//
//  KSTopBarView.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/7.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSButton.h"

@interface KSTopBarView : UIView

@property(nonatomic,weak)UIButton *switchBtn;
@property(nonatomic,weak)UIButton *addBtn;
@property(nonatomic,weak)UIButton *scaleDownBtn;
@property(nonatomic,weak)KSButton *identifierBtn;
@end
