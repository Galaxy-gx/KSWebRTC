//
//  KSMeetingThemeView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/7.
//  Copyright © 2020 saeipi. All rights reserved.
//  w:252 * h:257

#import "KSMeetingThemeView.h"
#import "KSMeetingBarView.h"
#import "UIColor+Category.h"
#import "NSString+Category.h"
#import "UIFont+Category.h"
#import "UIButton+Category.h"

@interface KSMeetingThemeView()

@property(nonatomic,weak)UITextField *textField;
@property(nonatomic,weak)KSMeetingBarView *meetingBarView;

@end

@implementation KSMeetingThemeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
    }
    return self;
}

- (void)initKit {
    int input_w = 144;
    int inpt_h = 25;
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake((self.bounds.size.width - input_w)/2, 0, input_w, inpt_h)];
    textField.textColor = [UIColor ks_white];
    textField.textAlignment = NSTextAlignmentCenter;
    textField.attributedPlaceholder = [NSString ks_attributesOfText:[NSString ks_localizde:@"ks_meeting_btn_start"] color:[UIColor ks_white] font:[UIFont ks_fontRegularOfSize:KS_Extern_18Font]];
    _textField = textField;
    [self addSubview:textField];
    
    int bar_w = 246;
    int bar_h = 46;
    KSMeetingBarView *meetingBarView = [[KSMeetingBarView alloc] initWithFrame:CGRectMake((self.bounds.size.width - bar_w)/2, CGRectGetMaxY(textField.frame) + 95, bar_w, bar_h)];
    _meetingBarView = meetingBarView;
    [self addSubview:meetingBarView];
    
    int btn_w = 252;
    int btn_h = 44;
    UIButton *startBtn = [UIButton ks_buttonWithFrame:CGRectMake((self.bounds.size.width - btn_w)/2, CGRectGetMaxY(meetingBarView.frame) + KS_Extern_Point48, btn_w, btn_h)
                                                   title:@"ks_meeting_btn_start"
                                              titleColor:[UIColor ks_white]
                                                    font:[UIFont ks_fontMediumOfSize:KS_Extern_16Font]
                                                  radius:KS_Extern_Point04
                                         backgroundColor:[UIColor ks_blueBtn]];
    [startBtn ks_addTouchEventForTarget:self action:@selector(onStartClick)];
    [self addSubview:startBtn];
}

-(void)onStartClick {
    if (self.callback) {
        self.callback(KSEventTypeStartMeeting,nil);
    }
}

@end
