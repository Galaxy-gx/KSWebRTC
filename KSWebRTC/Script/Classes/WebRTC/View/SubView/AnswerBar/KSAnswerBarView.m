//
//  KSAnswerBarView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/7.
//  Copyright © 2020 saeipi. All rights reserved.
//  h:90

#import "KSAnswerBarView.h"
#import "KSLayoutButton.h"

@interface KSAnswerBarView()

@property(nonatomic,weak)KSLayoutButton *hangupBtn;
@property(nonatomic,weak)KSLayoutButton *answerBtn;

@end
@implementation KSAnswerBarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
    }
    return self;
}

- (void)initKit {
    
    KSLayoutButton *hangupBtn = [self createButtonWithPointX:0 title:@"ks_app_global_text_hang_up" defaultIcon:@"icon_bar_hangup_red" selectedIcon:@"icon_bar_hangup_red"];
    _hangupBtn = hangupBtn;
    [hangupBtn addTarget:self action:@selector(onHangupClock) forControlEvents:UIControlEventTouchUpInside];
    
    KSLayoutButton *answerBtn = [self createButtonWithPointX:self.bounds.size.width - 90 title:@"ks_app_global_text_answer" defaultIcon:@"icon_bar_answer_green" selectedIcon:@"icon_bar_answer_green"];
    _answerBtn = answerBtn;
    [answerBtn addTarget:self action:@selector(onAnswerClock) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:hangupBtn];
    [self addSubview:answerBtn];
}

-(void)onHangupClock {
    if (self.callback) {
        if (self.answerState == KSAnswerStateJoin) {
            self.callback(KSEventTypeCalleeHangup,nil);//被叫方挂断
        }
        else{
            self.callback(KSEventTypeCallerHangup,nil);//呼叫时，呼叫方挂断
        }
    }
}

-(void)onAnswerClock {
    if (self.callback) {
        self.callback(KSEventTypeCalleeAnswer,nil);//被叫方接听
    }
}

-(KSLayoutButton *)createButtonWithPointX:(CGFloat)pointX title:(NSString *)title  defaultIcon:(NSString *)defaultIcon selectedIcon:(NSString *)selectedIcon{
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

-(void)setAnswerState:(KSAnswerState)answerState {
    _answerState = answerState;
    int btn_wh = 90;
    
    if (answerState == KSAnswerStateAwait) {
        _answerBtn.hidden = YES;
        _hangupBtn.frame = CGRectMake((self.bounds.size.width - btn_wh)/2, 0, btn_wh, btn_wh);
    }
    else if (answerState == KSAnswerStateJoin) {
        _answerBtn.hidden = NO;
        _hangupBtn.frame = CGRectMake(0, 0, btn_wh, btn_wh);
        _answerBtn.frame = CGRectMake(self.bounds.size.width - btn_wh, 0, btn_wh, btn_wh);
    }
}

@end
