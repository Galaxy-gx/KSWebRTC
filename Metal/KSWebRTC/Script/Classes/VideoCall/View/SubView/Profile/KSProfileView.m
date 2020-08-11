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
@property(nonatomic,weak)UILabel *titleLabel;
@property(nonatomic,weak)UILabel *descLabel;
@property(nonatomic,strong)KSProfileConfigure *configure;
@end

@implementation KSProfileView

- (instancetype)initWithFrame:(CGRect)frame configure:(KSProfileConfigure *)configure {
    if (self = [super initWithFrame:frame]) {
        self.configure = configure;
        [self initKit];
    }
    return self;
}

- (void)initKit {
    int self_w                 = self.bounds.size.width;
    int icon_wh                = 100;
    int icon_x                 = (self_w - icon_wh)/2;
    int icon_y                 = 0;

    KSRoundImageView *iconView = [[KSRoundImageView alloc] initWithFrame:CGRectMake(icon_x, icon_y, icon_wh, icon_wh)
                                                             strokeColor:[UIColor ks_white] lineWidth:0.5];
    _iconView                  = iconView;
    [self addSubview:iconView];
    
    //offst:KS_Extern_Point32 Font:[UIFont ks_fontRegularOfSize:KS_Extern_30Font]
    UILabel *titleLabel        = [UILabel ks_labelWithTextColor:[UIColor ks_white]
                                                   font:_configure.titleFont
                                              alignment:NSTextAlignmentCenter];
    titleLabel.frame           = CGRectMake(0, CGRectGetMaxY(iconView.frame) + _configure.titleOffst, self_w, KS_Extern_Point42);
    _titleLabel                = titleLabel;
    if (_configure.title) {
        titleLabel.text        = _configure.title;
    }
    [self addSubview:titleLabel];

    //offst:8 Font:[UIFont ks_fontRegularOfSize:KS_Extern_16Font]
    UILabel *descLabel         = [UILabel ks_labelWithTextColor:[UIColor ks_white]
                                                   font:_configure.descFont
                                              alignment:NSTextAlignmentCenter];
    descLabel.frame            = CGRectMake(0, CGRectGetMaxY(titleLabel.frame) + _configure.descOffst, self_w, KS_Extern_Point22);
    _descLabel                 = descLabel;
    if (_configure.desc) {
        descLabel.text         = _configure.desc;
    }
    [self addSubview:descLabel];
}

- (void)updateConfiure:(KSProfileConfigure *)configure {
    _configure        = configure;
    if (_configure.title) {
        _titleLabel.text = _configure.title;
    }
    if (_configure.desc) {
        _descLabel.text = _configure.desc;
    }
    int self_w        = self.bounds.size.width;
    _titleLabel.frame = CGRectMake(0, CGRectGetMaxY(_iconView.frame) + _configure.titleOffst, self_w, KS_Extern_Point42);
    _descLabel.frame  = CGRectMake(0, CGRectGetMaxY(_titleLabel.frame) + _configure.descOffst, self_w, KS_Extern_Point22);
}
@end


