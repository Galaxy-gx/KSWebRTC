//
//  KSRoundImageView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSRoundImageView.h"

@interface KSRoundImageView()

@property(nonatomic,weak)UIImageView *photoView;
@property(nonatomic,weak)UILabel *titleLabel;

@end

@implementation KSRoundImageView

-(instancetype)initWithFrame:(CGRect)frame strokeColor:(UIColor *)strokeColor lineWidth:(CGFloat)lineWidth {
    if (self = [super initWithFrame:frame]) {
        [self createKitOfStrokeColor:strokeColor lineWidth:lineWidth];
    }
    return self;
}

-(void)createKitOfStrokeColor:(UIColor *)strokeColor lineWidth:(CGFloat)lineWidth {
    CGFloat self_w                = self.bounds.size.width;
    UIImageView *photoView        = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, self_w - 4, self_w - 4)];
    photoView.backgroundColor     = [UIColor ks_blueBtn];
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

    int title_h                   = 25;
    UILabel *titleLabel           = [UILabel ks_labelWithFrame:CGRectMake(0, (self.bounds.size.height - title_h)/2, self_w, title_h) textColor:[UIColor ks_white] font:[UIFont ks_fontMediumOfSize:KS_Extern_18Font]  alignment:NSTextAlignmentCenter];
    _titleLabel                   = titleLabel;
    [self addSubview:titleLabel];
}

-(void)updateImage:(NSString *)url {
    
}

-(void)updateTitle:(NSString *)title {
    _titleLabel.text = title;
}

@end
