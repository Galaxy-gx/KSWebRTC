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
    UIImageView *photoView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, self.bounds.size.width/2, self.bounds.size.width/2)];
    [self addSubview:photoView];
    _photoView = photoView;
    
    CAShapeLayer *roundLayer = [[CAShapeLayer alloc] init];
    roundLayer.lineWidth = lineWidth;
    roundLayer.strokeColor = strokeColor.CGColor;
    roundLayer.fillColor = [UIColor clearColor].CGColor;
    CGFloat radius = self.bounds.size.width/2;
    BOOL clockWise = true;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.center radius:radius startAngle:(1.25*M_PI) endAngle:1.75f*M_PI clockwise:clockWise];
    roundLayer.path = [path CGPath];
    [self.layer addSublayer:roundLayer];
    
    int title_h = 25;
    UILabel *titleLabel = [UILabel ks_labelWithFrame:CGRectMake(0, (self.bounds.size.height - title_h)/2, self.bounds.size.width, title_h) textColor:[UIColor ks_white] font:[UIFont ks_fontMediumOfSize:KS_Extern_18Font]  alignment:NSTextAlignmentCenter];
    _titleLabel = titleLabel;
    [self addSubview:titleLabel];
    
}

-(void)updateImage:(NSString *)url {
    
}

-(void)updateTitle:(NSString *)title {
    _titleLabel.text = title;
}

@end
