//
//  KSFunctionalBarCell.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/25.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSFunctionalBarCell.h"
#import "KSComposeButton.h"
#import "UIFont+Category.h"
#import "UIColor+Category.h"
#import "KSLayoutButton.h"

@interface KSFunctionalBarCell()
@property(nonatomic,weak)KSComposeButton *button;
@end

@implementation KSFunctionalBarCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
    }
    return self;
}

- (void)initKit {
    int btn_wh              = 90;
    UIColor *bgColor = [UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:0.25];
    KSComposeButton *button = [[KSComposeButton alloc] initWithFrame:CGRectMake(0, 0, btn_wh, btn_wh)
                                                           textColor:[UIColor ks_white]
                                                                font:[UIFont ks_fontRegularOfSize:KS_Extern_16Font]
                                                           alignment:NSTextAlignmentCenter
                                                         titleHeight:KS_Extern_Point20
                                                           imageSize:CGSizeMake(30, 30)
                                                     backgroundColor:bgColor
                                                      backgroundSize:CGSizeMake(62, 62)
                                                             spacing:KS_Extern_Point08];
    _button                 = button;
    [self addSubview:button];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    int btn_wh = 90;
    _button.frame = CGRectMake((self.bounds.size.width - btn_wh)/2, (self.bounds.size.height - btn_wh)/2, btn_wh, btn_wh);
}

-(void)setBtnInfo:(KSBtnInfo *)btnInfo {
    _btnInfo = btnInfo;
    [_button updateTitle:btnInfo.title defaultIcon:btnInfo.defaultIcon selectedIcon:btnInfo.selectedIcon selected:btnInfo.isSelected];
}

@end
