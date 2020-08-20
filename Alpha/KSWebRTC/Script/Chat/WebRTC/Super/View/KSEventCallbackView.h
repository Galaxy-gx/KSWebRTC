//
//  KSEventCallbackView.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/10.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSBlock.h"

@interface KSEventCallbackView : UIView

@property(nonatomic,copy)KSEventCallback callback;

- (void)setEventCallback:(KSEventCallback)callback;

@end

