//
//  KSProfileView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSProfileView.h"
#import "KSRoundImageView.h"

@interface KSProfileView()

@property(nonatomic,weak)KSRoundImageView *iconView;
@property(nonatomic,weak)UILabel *nameLabel;
@property(nonatomic,weak)UILabel *tipsLabel;

@end

@implementation KSProfileView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
    }
    return self;
}

- (void)initKit {
    int self_w = self.bounds.size.width;
    int icon_wh = 100;
    int icon_x = (self_w - icon_wh)/2;
    int icon_y = 0;
    
    KSRoundImageView *iconView = [[KSRoundImageView alloc] initWithFrame:CGRectMake(icon_x, icon_y, icon_wh, icon_wh)
                                                             strokeColor:[UIColor redColor] lineWidth:0.5];
    _iconView = iconView;
    [self addSubview:iconView];
    
    UILabel *nameLabel = [UILabel ks_labelWithTextColor:[UIColor ks_white]
                                                   font:[UIFont ks_fontRegularOfSize:KS_Extern_30Font]
                                              alignment:NSTextAlignmentCenter];
    nameLabel.frame = CGRectMake(0, CGRectGetMaxY(iconView.frame) + KS_Extern_Point32,
                                 self_w, KS_Extern_Point42);
    _nameLabel = nameLabel;
    [self addSubview:nameLabel];
    
    UILabel *tipsLabel = [UILabel ks_labelWithTextColor:[UIColor ks_white]
                                                   font:[UIFont ks_fontRegularOfSize:KS_Extern_16Font]
                                              alignment:NSTextAlignmentCenter];
    tipsLabel.frame = CGRectMake(0, CGRectGetMaxY(nameLabel.frame) + KS_Extern_Point08,
                                 self_w, KS_Extern_Point22);
    _tipsLabel = tipsLabel;
    [self addSubview:tipsLabel];
}

@end


