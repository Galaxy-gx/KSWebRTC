//
//  KSNavigationBar.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/8.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSNavigationBar.h"

@interface KSNavigationBar()

@property(nonatomic,weak)UILabel *titleLabel;
@property(nonatomic,assign)CGFloat statusBarHeight;
@property(nonatomic,assign)CGFloat barHeight;
@end

@implementation KSNavigationBar
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        _barHeight = self.bounds.size.height - _statusBarHeight;
    }
    return self;
}

- (void)initKit {
    
}

-(void)setTitle:(NSString *)title {
    _title               = title;

    self.titleLabel.text  = title;
    int padding           = KS_Extern_Point50;
    CGSize title_size     = [self.titleLabel ks_sizeOfMaxSize:CGSizeMake(self.bounds.size.width - padding * 2, _statusBarHeight)];
    self.titleLabel.frame = CGRectMake((self.bounds.size.width - title_size.width)/2, _statusBarHeight, title_size.width, _barHeight);
    [self bringSubviewToFront:_titleLabel];
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        UILabel *titleLabel = [UILabel ks_labelWithTextColor:[UIColor ks_white] font:[UIFont ks_fontMediumOfSize:KS_Extern_20Font] alignment:NSTextAlignmentCenter];
        _titleLabel = titleLabel;
        [self addSubview:titleLabel];
    }
    return _titleLabel;
}

-(void)setBackBarButtonItem:(UIButton *)backBarButtonItem {
    if (_backBarButtonItem) {
        [_backBarButtonItem removeFromSuperview];
        _backBarButtonItem = nil;
    }
    _backBarButtonItem      = backBarButtonItem;
    backBarButtonItem.frame = CGRectMake(KS_Extern_Point14,
                                         _statusBarHeight + (_barHeight - backBarButtonItem.bounds.size.height)/2,
                                         backBarButtonItem.bounds.size.width,
                                         backBarButtonItem.bounds.size.height);
    [self addSubview:backBarButtonItem];
}

- (void)toFront {
    if (self.superview) {
        [self.superview bringSubviewToFront:self];
    }
}
@end
