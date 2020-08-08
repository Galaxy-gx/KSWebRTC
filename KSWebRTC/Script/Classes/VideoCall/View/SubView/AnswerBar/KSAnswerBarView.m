//
//  KSAnswerBarView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/7.
//  Copyright © 2020 saeipi. All rights reserved.
//  h:90

#import "KSAnswerBarView.h"
#import "KSLayoutButton.h"
@implementation KSAnswerBarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
    }
    return self;
}

- (void)initKit {
    
    UIView *hangupBtn = [self createButtonWithPointX:0 title:@"ks_app_global_text_hang_up" defaultIcon:@"icon_bar_hangup_red" selectedIcon:@"icon_bar_hangup_red"];
    UIView *answerBtn = [self createButtonWithPointX:self.bounds.size.width - 90 title:@"ks_app_global_text_answer" defaultIcon:@"icon_bar_answer_green" selectedIcon:@"icon_bar_answer_green"];
    [self addSubview:hangupBtn];
    [self addSubview:answerBtn];
}

-(UIView *)createButtonWithPointX:(CGFloat)pointX title:(NSString *)title  defaultIcon:(NSString *)defaultIcon selectedIcon:(NSString *)selectedIcon{
    int btn_wh = 90;
    KSLayoutButton *button = [[KSLayoutButton alloc] initWithFrame:CGRectMake(pointX, 0, btn_wh, btn_wh)
                                                     layoutType:KSButtonLayoutTypeTitleBottom
                                                          title:title
                                                           font:[UIFont ks_fontRegularOfSize:KS_Extern_14Font]
                                                      textColor:[UIColor ks_white]
                                                      normalImg:defaultIcon
                                                      selectImg:selectedIcon
                                                          space:KS_Extern_Point08
                                                     imageWidth:62
                                                    imageHeight:62];
    return button;
}

@end
