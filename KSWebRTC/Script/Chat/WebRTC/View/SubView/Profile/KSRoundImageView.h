//
//  KSRoundImageView.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSRoundImageView : UIView

-(instancetype)initWithFrame:(CGRect)frame strokeColor:(UIColor *)strokeColor lineWidth:(CGFloat)lineWidth;
-(void)updateTitle:(NSString *)title;
@end
