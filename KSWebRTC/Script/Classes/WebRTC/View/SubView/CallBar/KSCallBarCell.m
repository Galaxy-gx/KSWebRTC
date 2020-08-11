//
//  KSCallBarCell.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSCallBarCell.h"
#import "KSBtnInfo.h"
@interface KSCallBarCell()

@property(nonatomic,weak)UIButton *button;
@property(nonatomic,strong)KSBtnInfo *btnInfo;
@end

@implementation KSCallBarCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
    }
    return self;
}

- (void)initKit {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button = button;
    [button ks_addTarget:self action:@selector(onButtonClick)];
    [self addSubview:button];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    int btn_w = 21;
    int btn_h = 20;
    if (_btnInfo.btnType == KSCallBarBtnTypePhone) {
        btn_w = 32;
        btn_h = 32;
    }
    _button.frame = CGRectMake((self.frame.size.width - btn_w)/2, (self.frame.size.height - btn_h)/2, btn_w, btn_h);
}

-(void)onButtonClick {
    _btnInfo.isSelected = !_btnInfo.isSelected;
    [_button setImage:[UIImage imageNamed:_btnInfo.icon] forState:UIControlStateNormal];
    [self.delegate callBarCell:self didSelectBarBtn:_btnInfo];
}

-(void)configureBarBtn:(KSBtnInfo *)btnInfo {
    _btnInfo = btnInfo;
    [_button setImage:[UIImage imageNamed:btnInfo.icon] forState:UIControlStateNormal];
}

@end
