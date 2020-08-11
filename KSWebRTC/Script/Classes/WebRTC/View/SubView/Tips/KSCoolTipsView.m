//
//  KSCoolTipsView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/8.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSCoolTipsView.h"

@interface KSCoolTipsView()

@property (nonatomic, weak  ) UIVisualEffectView *visualEffectView;
@property (nonatomic, weak  ) UILabel            *contentLabel;

@end

@implementation KSCoolTipsView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
    }
    return self;
}

- (void)initKit {
    //实现模糊效果
    UIBlurEffect *blurEffrct             = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    //毛玻璃视图
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffrct];
    visualEffectView.contentView.backgroundColor = [UIColor colorWithRed:5/255.0 green:5/255.0 blue:5/255.0 alpha:0.5];
    //visualEffectView.alpha               = 0.9;
    visualEffectView.layer.cornerRadius  = 5;
    visualEffectView.layer.masksToBounds = YES;
    [self addSubview:visualEffectView];
    visualEffectView.frame               = self.bounds;
    _visualEffectView                    = visualEffectView;

    UILabel *contentLabel                = [UILabel ks_labelWithTextColor:[UIColor ks_white] font:[UIFont ks_fontMediumOfSize:KS_Extern_14Font] alignment:NSTextAlignmentCenter];

    [self addSubview:contentLabel];
    _contentLabel                        = contentLabel;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    if (self.superview) {
        CGFloat max_w           = [UIScreen mainScreen].bounds.size.width - KS_Extern_Point50;
        CGSize size             = [_contentLabel ks_sizeOfMaxSize:CGSizeMake(max_w, KS_Extern_Point100)];
        CGFloat self_w          = size.width + 20;
        if (self_w < 150) {
            self_w              = 150;
        }
        CGFloat self_h          = size.height + 20;
        self.frame              = CGRectMake((self.superview.bounds.size.width - self_w)/2.0f, (self.superview.bounds.size.height - self_h)/2.0f, self_w, self_h);
        _visualEffectView.frame = self.bounds;
        _contentLabel.frame     = CGRectMake(10, 0, self_w - 20, self_h);
        self.layer.cornerRadius = self.bounds.size.height/2;
        self.layer.masksToBounds = YES;
    }
}

- (void)updateMessage:(NSString *)message {
    _contentLabel.text = message;
    [self setNeedsLayout];
}

@end
