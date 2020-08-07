//
//  KSMeetingBarCell.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/7.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSMeetingBarCell.h"
#import "KSButton.h"
#import "KSBtnInfo.h"
@interface KSMeetingBarCell()

@property(nonatomic,weak)KSButton *button;
@property(nonatomic,strong)KSBtnInfo *btnInfo;

@end

@implementation KSMeetingBarCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
    }
    return self;
}

- (void)initKit {
    KSButton *button = [[KSButton alloc] initWithFrame:CGRectMake(0, 0, 36, 45)
                                             textColor:[UIColor ks_white]
                                                  font:[UIFont ks_fontRegularOfSize:KS_Extern_12Font]
                                             alignment:NSTextAlignmentCenter
                                           titleHeight:KS_Extern_18Font
                                             imageSize:CGSizeMake(KS_Extern_Point20, KS_Extern_Point20)
                                            layoutType:KSButtonLayoutTypeTitleBottom
                                               spacing:KS_Extern_Point08];
    _button = button;
    [button addTarget:self action:@selector(onButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    _button.center = self.center;
    /*
    int btn_w = _button.bounds.size.width;
    int btn_h = _button.bounds.size.height;
    _button.frame = CGRectMake((self.bounds.size.width - btn_w)/2, (self.bounds.size.height - btn_h)/2, btn_w, btn_w);
     */
}

-(void)onButtonClick {
    _btnInfo.isSelected = !_btnInfo.isSelected;
    _button.selected  = _btnInfo.isSelected;
    [self.delegate meetingBarCell:self didSelectBarBtn:_btnInfo];
}

-(void)configureBarBtn:(KSBtnInfo *)btnInfo {
    [_button updateDefaultIcon:btnInfo.defaultIcon selectedIcon:btnInfo.selectedIcon selected:btnInfo.isSelected];
}

@end
