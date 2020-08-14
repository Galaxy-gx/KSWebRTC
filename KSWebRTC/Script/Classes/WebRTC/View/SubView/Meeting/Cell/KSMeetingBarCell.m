//
//  KSMeetingBarCell.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/7.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSMeetingBarCell.h"
#import "KSLayoutButton.h"
#import "KSBtnInfo.h"
#import "UIFont+Category.h"
#import "UIColor+Category.h"

@interface KSMeetingBarCell()

@property(nonatomic,weak)KSLayoutButton *button;
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
    KSLayoutButton *button = [[KSLayoutButton alloc] initWithFrame:CGRectMake(0, 0, 50, 46)
                                                        layoutType:KSButtonLayoutTypeTitleBottom
                                                              font:[UIFont ks_fontRegularOfSize:KS_Extern_12Font]
                                                         textColor:[UIColor ks_white]
                                                             space:KS_Extern_Point08
                                                        imageWidth:KS_Extern_Point20
                                                       imageHeight:KS_Extern_Point20];
    _button = button;
    [button addTarget:self action:@selector(onButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
}

-(void)layoutSubviews {
    [super layoutSubviews];

    int btn_w = _button.bounds.size.width;
    int btn_h = _button.bounds.size.height;
    _button.frame = CGRectMake((self.bounds.size.width - btn_w)/2, (self.bounds.size.height - btn_h)/2, btn_w, btn_w);
     
}

-(void)onButtonClick {
    _btnInfo.isSelected = !_btnInfo.isSelected;
    _button.selected  = _btnInfo.isSelected;
    [self.delegate meetingBarCell:self didSelectBarBtn:_btnInfo];
}

-(void)configureBarBtn:(KSBtnInfo *)btnInfo {
    [_button updateTitle:btnInfo.title normalIcon:btnInfo.defaultIcon selectedIcon:btnInfo.selectedIcon selected:btnInfo.isSelected];
}

@end
