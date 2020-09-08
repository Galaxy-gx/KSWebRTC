//
//  KSRoundImageView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSRoundImageView.h"
#import "UIColor+Category.h"
#import "UILabel+Category.h"
#import "UIFont+Category.h"

@interface KSRoundImageView()

@property(nonatomic,weak)UIImageView *photoView;
@property(nonatomic,weak)UILabel *titleLabel;

@end

@implementation KSRoundImageView

-(instancetype)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)backgroundColor textColor:(UIColor *)textColor font:(UIFont *)font strokeColor:(UIColor *)strokeColor lineWidth:(CGFloat)lineWidth {
    if (self = [super initWithFrame:frame]) {
        [self createKitWithBackgroundColor:backgroundColor textColor:textColor font:font strokeColor:strokeColor lineWidth:lineWidth];
    }
    return self;
}

-(void)createKitWithBackgroundColor:(UIColor *)backgroundColor textColor:(UIColor *)textColor font:(UIFont *)font strokeColor:(UIColor *)strokeColor lineWidth:(CGFloat)lineWidth {
    CGFloat self_w                = self.bounds.size.width;
    UIImageView *photoView        = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, self_w - 4, self_w - 4)];
    photoView.backgroundColor     = backgroundColor;//[UIColor ks_blueBtn];
    photoView.layer.cornerRadius  = photoView.bounds.size.width/2;
    photoView.layer.masksToBounds = YES;
    [self addSubview:photoView];
    _photoView                    = photoView;

    CAShapeLayer *roundLayer      = [[CAShapeLayer alloc] init];
    roundLayer.lineWidth          = lineWidth;
    roundLayer.strokeColor        = strokeColor.CGColor;
    roundLayer.fillColor          = [UIColor clearColor].CGColor;
    CGFloat radius                = self_w/2;
    BOOL clockWise                = true;
    UIBezierPath *path            = [UIBezierPath bezierPathWithArcCenter:photoView.center radius:radius startAngle:0 endAngle:2*M_PI clockwise:clockWise];
    roundLayer.path               = [path CGPath];
    [self.layer addSublayer:roundLayer];

    CGFloat title_h               = self.bounds.size.height;
    //[UIColor ks_white] [UIFont ks_fontMediumOfSize:KS_Extern_18Font]
    UILabel *titleLabel           = [UILabel ks_labelWithFrame:CGRectMake(0, 0, self_w, title_h) textColor:textColor font:font  alignment:NSTextAlignmentCenter];
    _titleLabel                   = titleLabel;
    [self addSubview:titleLabel];
}

-(void)updateImage:(NSString *)url {
    
}

-(void)updateTitle:(NSString *)title {
    if ([title length] > 3) {
        title = [title substringToIndex:2];
    }
    _titleLabel.text = title;
}

-(void)updateTitle:(NSString *)title font:(UIFont *)font {
    [self updateTitle:title];
    _titleLabel.font = font;;
}

@end
