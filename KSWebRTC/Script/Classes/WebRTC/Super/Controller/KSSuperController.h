//
//  KSSuperController.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/8.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSNavigationBar.h"

typedef NS_ENUM(NSUInteger, KSDisplayFlag) {
    KSDisplayFlagNormalFirst   = 0,
    KSDisplayFlagAnimatedFirst = 1,
    KSDisplayFlagMore          = 2,
};

@interface KSSuperController : UIViewController

@property (nonatomic,assign) BOOL                isSuperBar;
@property (nonatomic,assign) KSDisplayFlag       displayFlag;
@property (nonatomic,weak  ) KSNavigationBar     *superBar;
@property (nonatomic,weak  ) UIView              *containerView;
@property (nonatomic,strong) NSMutableDictionary *executeArgs;

/// 如果executeArgs不为NULL则执行
- (void)executeTheExpectedInstruction;

@end
