//
//  KSTopBarView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/7.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSTopBarView.h"
#import "KSButton.h"

@interface KSTopBarView()
@property(nonatomic,weak)KSButton *identifierBtn;
@property(nonatomic,weak)UILabel *countdownLabel;
@end

@implementation KSTopBarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
    }
    return self;
}

- (void)initKit {
    self.backgroundColor = [UIColor ks_grayBar];
    
    int self_w = self.bounds.size.width;
    int kit_y = self.bounds.size.height - 18 - 20;;
    
    UIButton *switchBtn = [UIButton ks_buttonWithNormalImg:@"icon_bar_switch_white" selectImg:@"icon_bar_switch_white"];
    switchBtn.frame = CGRectMake(self_w - 120, kit_y, KS_Extern_Point20, KS_Extern_Point20);
    [self addSubview:switchBtn];
    
    UIButton *addBtn = [UIButton ks_buttonWithNormalImg:@"icon_bar_add_members_white" selectImg:@"icon_bar_add_members_white"];
    addBtn.frame = CGRectMake(self_w - 76, kit_y, KS_Extern_Point20, KS_Extern_Point22);
    [self addSubview:addBtn];
    
    UIButton *scaleDownBtn = [UIButton ks_buttonWithNormalImg:@"icon_bar_double_arrow_small_white" selectImg:@"icon_bar_double_arrow_small_white"];
    scaleDownBtn.frame = CGRectMake(self_w - 32, kit_y, KS_Extern_Point20, 21);
    [self addSubview:scaleDownBtn];
    
    int btn_y = self.bounds.size.height - 23 - 22;
    KSButton *identifierBtn = [[KSButton alloc] initWithFrame:CGRectMake(KS_Extern_Point12, btn_y, 128, KS_Extern_Point22)
                                                        title:@"ID:000 000 000"
                                                    textColor:[UIColor ks_white]
                                                         font:[UIFont ks_fontMediumOfSize:KS_Extern_16Font]
                                                    alignment:NSTextAlignmentLeft
                                                  titleHeight:KS_Extern_Point22
                                                  defaultIcon:@"icon_bar_more_members_white"
                                                 selectedIcon:@"icon_bar_more_members_white"
                                                    imageSize:CGSizeMake(KS_Extern_Point10, KS_Extern_Point10)
                                                   layoutType:KSButtonLayoutTypeTitleLeft
                                                      spacing:KS_Extern_Point04];
    _identifierBtn = identifierBtn;
    [self addSubview:identifierBtn];
    
    UILabel *countdownLabel = [UILabel ks_labelWithFrame:CGRectMake(KS_Extern_Point12, CGRectGetMaxY(identifierBtn.frame) + KS_Extern_Point02, KS_Extern_Point100, KS_Extern_Point18)
                                               textColor:[UIColor ks_white]
                                                    font:[UIFont ks_fontRegularOfSize:KS_Extern_12Font]
                                               alignment:NSTextAlignmentLeft];
    countdownLabel.text = @"00:00";
    _countdownLabel = countdownLabel;
    [self addSubview:countdownLabel];
}

@end
