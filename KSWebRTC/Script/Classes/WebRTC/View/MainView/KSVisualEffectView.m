//
//  KSVisualEffectView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/7/27.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSVisualEffectView.h"

@implementation KSVisualEffectView

/*
+(KSVisualEffectView *)initKit {
    UIBlurEffect *blurEffrct = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    KSVisualEffectView *visualEffectView = [[KSVisualEffectView alloc] initWithEffect:blurEffrct];
    visualEffectView.contentView.backgroundColor = [UIColor colorWithRed:5/255.0 green:5/255.0 blue:5/255.0 alpha:0.5];
    return visualEffectView;
}
*/
-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
    }
    return self;
}

-(void)initKit {
    UIBlurEffect *blurEffrct = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.effect = blurEffrct;
    self.contentView.backgroundColor = [UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:0.5];
}

@end
