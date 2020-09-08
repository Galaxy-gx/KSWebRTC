//
//  KSWaitingAnswersMemberCell.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/7.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSWaitingAnswersMemberCell.h"
#import "KSRoundImageView.h"
#import "UIColor+Category.h"
#import "UIFont+Category.h"
@interface KSWaitingAnswersMemberCell()

@property(nonatomic,weak)KSRoundImageView *iconView;

@end

@implementation KSWaitingAnswersMemberCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
    }
    return self;
}

- (void)initKit {
    int icon_wh                = 38;
    CGFloat self_w             = self.bounds.size.width;
    CGFloat icon_x             = (self_w - icon_wh)/2;
    int icon_y                 = 0;
    KSRoundImageView *iconView = [[KSRoundImageView alloc] initWithFrame:CGRectMake(icon_x, icon_y, icon_wh, icon_wh)
                                                         backgroundColor:[UIColor ks_blueBtn]
                                                               textColor:[UIColor ks_white]
                                                                    font:[UIFont ks_fontMediumOfSize:KS_Extern_18Font]
                                                             strokeColor:[UIColor ks_white]
                                                               lineWidth:0.5];
    _iconView                  = iconView;
    [self addSubview:iconView];
}

@end
