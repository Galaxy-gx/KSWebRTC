//
//  KSAnswerBarView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/7.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSAnswerBarView.h"
#import "KSButton.h"
@implementation KSAnswerBarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
    }
    return self;
}

- (void)initKit {
    
    KSButton *hangupBtn = [self createButtonWithPointX:0 title:@"ks_app_global_text_hang_up" defaultIcon:@"icon_bar_hangup_red" selectedIcon:@"icon_bar_hangup_red"];
    KSButton *answerBtn = [self createButtonWithPointX:self.bounds.size.width - 90 title:@"ks_app_global_text_answer" defaultIcon:@"icon_bar_answer_green" selectedIcon:@"icon_bar_answer_green"];
    
    [self addSubview:hangupBtn];
    [self addSubview:answerBtn];
}

-(KSButton *)createButtonWithPointX:(CGFloat)pointX title:(NSString *)title  defaultIcon:(NSString *)defaultIcon selectedIcon:(NSString *)selectedIcon   {
    int btn_wh = 90;
    KSButton *button = [[KSButton alloc] initWithFrame:CGRectMake(pointX, 0, btn_wh, btn_wh)
                                                 title:title
                                             textColor:[UIColor ks_white]
                                                  font:[UIFont ks_fontRegularOfSize:KS_Extern_14Font]
                                             alignment:NSTextAlignmentCenter
                                           titleHeight:KS_Extern_Point20
                                           defaultIcon:defaultIcon
                                          selectedIcon:selectedIcon
                                             imageSize:CGSizeMake(62, 62)
                                              layoutType:KSButtonLayoutTypeTitleBottom
                                               spacing:KS_Extern_Point08];
    return button;
}

@end
