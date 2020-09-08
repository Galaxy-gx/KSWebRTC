//
//  KSFunctionalBarView.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/25.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSBlock.h"
@interface KSFunctionalBarView : UIView

@property (nonatomic,copy  ) KSEventCallback callback;
@property (nonatomic,assign) BOOL            isSession;

- (void)setEventCallback:(KSEventCallback)callback;

@end
