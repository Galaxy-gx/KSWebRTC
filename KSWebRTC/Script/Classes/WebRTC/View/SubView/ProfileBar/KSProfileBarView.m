//
//  KSProfileBarView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//  self_height = 20

#import "KSProfileBarView.h"
#import "UIImageView+Category.h"
#import "UILabel+Category.h"
#import "UIColor+Category.h"
#import "UIFont+Category.h"

@interface KSProfileBarView()

@property(nonatomic,weak)UIImageView *imageview;
@property(nonatomic,weak)UILabel *descLabel;
@property(nonatomic,copy)NSString *name;

@end

@implementation KSProfileBarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
    }
    return self;
}

- (void)initKit {
    UIImageView *imageview = [UIImageView ks_imageViewWithName:@"icon_bar_mute_red"];
    imageview.frame = CGRectMake(KS_Extern_Point04, (self.bounds.size.height - KS_Extern_Point14)/2, KS_Extern_Point14, KS_Extern_Point14);
    _imageview = imageview;
    imageview.hidden = YES;
    [self addSubview:_imageview];
    
    UILabel *descLabel = [UILabel ks_labelWithTextColor:[UIColor ks_white] font:[UIFont ks_fontRegularOfSize:KS_Extern_12Font] alignment:NSTextAlignmentLeft];
    _descLabel = descLabel;
    [self addSubview:descLabel];
}

- (void)setUserName:(NSString *)name {
    _name = name;
}

- (void)updateMediaState:(KSMediaState)mediaState {
    _mediaState = mediaState;
    int x = 10;
    int y = 0;
    NSString *desc = _name;
    if (_mediaState == KSMediaStateUnmuteAudio) {
        _imageview.hidden = YES;
    }
    else if (_mediaState == KSMediaStateMuteAudio) {
        _imageview.hidden = NO;
        x = KS_Extern_Point22;
        NSString *state = @"静音";
        desc = [NSString stringWithFormat:@"%@%@",_name,state];
    }
    else if (_mediaState == KSMediaStateTalking) {
        _imageview.hidden = NO;
        x = KS_Extern_Point22;
        NSString *state = @"发声";
        desc = [NSString stringWithFormat:@"%@%@",_name,state];
    }
    _descLabel.text = desc;
    CGSize size = [_descLabel ks_textSize];
    _descLabel.frame = CGRectMake(x, y, size.width, self.bounds.size.height);
}

@end
