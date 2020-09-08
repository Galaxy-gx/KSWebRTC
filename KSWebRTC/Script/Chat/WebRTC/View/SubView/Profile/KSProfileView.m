//
//  KSProfileView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSProfileView.h"
#import "KSRoundImageView.h"
#import "UIColor+Category.h"
#import "UILabel+Category.h"
#import "UIFont+Category.h"

@interface KSProfileView()<KSProfileInfoDelegate>
@property (nonatomic,weak  ) KSRoundImageView *iconView;
@property (nonatomic,weak  ) UILabel          *titleLabel;
@property (nonatomic,weak  ) UILabel          *descLabel;
@end

@implementation KSProfileView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
    }
    return self;
}

- (void)initKit {
    CGFloat self_w             = self.bounds.size.width;
    int icon_wh                = 100;
    CGFloat icon_x             = (self_w - icon_wh)/2;
    int icon_y                 = 0;

    KSRoundImageView *iconView = [[KSRoundImageView alloc] initWithFrame:CGRectMake(icon_x, icon_y, icon_wh, icon_wh)
                                                         backgroundColor:[UIColor ks_blueBtn]
                                                               textColor:[UIColor ks_white]
                                                                    font:[UIFont ks_fontMediumOfSize:KS_Extern_30Font]
                                                             strokeColor:[UIColor ks_white]
                                                               lineWidth:0.5];
    _iconView                  = iconView;
    [self addSubview:iconView];
    
    //offst:KS_Extern_Point32 Font:[UIFont ks_fontRegularOfSize:KS_Extern_30Font]
    UILabel *titleLabel        = [UILabel ks_labelWithTextColor:[UIColor ks_white]
                                                   font:[UIFont ks_fontRegularOfSize:KS_Extern_30Font]
                                              alignment:NSTextAlignmentCenter];
    titleLabel.frame           = CGRectMake(0, CGRectGetMaxY(iconView.frame) + KS_Extern_Point32, self_w, KS_Extern_Point42);
    _titleLabel                = titleLabel;
    [self addSubview:titleLabel];

    //offst:8 Font:[UIFont ks_fontRegularOfSize:KS_Extern_16Font]
    UILabel *descLabel         = [UILabel ks_labelWithTextColor:[UIColor ks_white]
                                                   font:[UIFont ks_fontRegularOfSize:KS_Extern_16Font]
                                              alignment:NSTextAlignmentCenter];
    descLabel.frame            = CGRectMake(0, CGRectGetMaxY(titleLabel.frame) + KS_Extern_Point08, self_w, KS_Extern_Point22);
    _descLabel                 = descLabel;
    [self addSubview:descLabel];
}

- (void)setProfileInfo:(KSProfileInfo *)profileInfo {
    _profileInfo          = profileInfo;
    _profileInfo.delegate = self;
    self.hidden           = NO;
    if (_profileInfo.title) {
        _titleLabel.text = _profileInfo.title;
        //_titleLabel.font = _profileInfo.titleFont;
        [_iconView updateTitle:_profileInfo.title];
    }
    if (_profileInfo.desc) {
        _descLabel.text = _profileInfo.desc;
        //_descLabel.font = _profileInfo.descFont;
    }
    int self_w        = (int)self.bounds.size.width;
    _titleLabel.frame = CGRectMake(0, CGRectGetMaxY(_iconView.frame) + _profileInfo.titleOffst, self_w, KS_Extern_Point42);
    _descLabel.frame  = CGRectMake(0, CGRectGetMaxY(_titleLabel.frame) + _profileInfo.descOffst, self_w, KS_Extern_Point22);
}

//KSProfileInfoDelegate
- (void)profileInfoUpdate:(KSProfileInfo *)profileInfo {
    if (profileInfo.isHidden) {
        self.hidden = YES;
    }
    else{
        self.hidden = NO;
        if (profileInfo.title) {
            _titleLabel.text = profileInfo.title;
            [_iconView updateTitle:_profileInfo.title];
        }
        if (profileInfo.desc) {
            _descLabel.text = profileInfo.desc;
        }
    }
}

@end


