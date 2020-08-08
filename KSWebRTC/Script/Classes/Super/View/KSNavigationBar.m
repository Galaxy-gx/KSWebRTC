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

@end

@implementation KSNavigationBar


-(void)setTitle:(NSString *)title {
    _title               = title;

    self.titleLabel.text = title;
    int title_h          = 44;
    int padding          = KS_Extern_Point50;
    CGSize title_size    = [_titleLabel ks_sizeOfMaxSize:CGSizeMake(self.bounds.size.width - padding * 2, title_h)];
    _titleLabel.frame    = CGRectMake((self.bounds.size.width - title_size.width)/2, self.bounds.size.height - title_h, title_size.width, title_h);
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        UILabel *titleLabel = [UILabel ks_labelWithTextColor:[UIColor ks_white] font:[UIFont ks_fontMediumOfSize:KS_Extern_20Font] alignment:NSTextAlignmentCenter];
        _titleLabel = titleLabel;
        [self addSubview:titleLabel];
    }
    return _titleLabel;
}

@end
