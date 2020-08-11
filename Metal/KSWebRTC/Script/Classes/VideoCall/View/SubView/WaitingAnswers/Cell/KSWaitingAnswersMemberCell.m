//
//  KSWaitingAnswersMemberCell.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/7.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSWaitingAnswersMemberCell.h"
#import "KSRoundImageView.h"

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
    int icon_wh = 38;
    KSRoundImageView *iconView = [[KSRoundImageView alloc] initWithFrame:CGRectMake(0, 0, icon_wh, icon_wh)
                                                             strokeColor:[UIColor ks_white] lineWidth:0.5];
    _iconView = iconView;
    [self addSubview:iconView];
}

@end
