//
//  KSComposeButton.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/25.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSComposeButton.h"
#import "UIColor+Category.h"
#import "NSString+Category.h"

@interface KSComposeButton(){
    CGSize _imageSize;
    CGSize _backgroundSize;
    int _titleHeight;
    CGFloat _spacing;
}
@property(nonatomic,copy)NSString *defaultIcon;
@property(nonatomic,copy)NSString *selectedIcon;
@property(nonatomic,weak)UIImageView *iconView;
@property(nonatomic,weak)UIImageView *backgroundView;
@property(nonatomic,weak)UILabel *titleLabel;

@end
@implementation KSComposeButton

- (instancetype)initWithFrame:(CGRect)frame textColor:(UIColor*)textColor font:(UIFont *)font alignment:(NSTextAlignment)alignment titleHeight:(int)titleHeight imageSize:(CGSize)imageSize backgroundColor:(UIColor *)backgroundColor backgroundSize:(CGSize)backgroundSize spacing:(CGFloat)spacing {
    if (self = [super initWithFrame:frame]) {
        _titleHeight                = titleHeight;
        _imageSize                  = imageSize;
        _backgroundSize             = backgroundSize;
        _spacing                    = spacing;

        UIImageView *backgroundView = [[UIImageView alloc] init];
        backgroundView.image        = [UIColor ks_imageWithColor:backgroundColor radius:backgroundSize.width/2];

        UIImageView *iconView       = [[UIImageView alloc] init];

        UILabel *titleLabel         = [[UILabel alloc] init];
        titleLabel.textColor        = textColor;
        titleLabel.font             = font;
        titleLabel.textAlignment    = alignment;

        [self addSubview:backgroundView];
        [backgroundView addSubview:iconView];
        [self addSubview:titleLabel];

        _backgroundView             = backgroundView;
        _iconView                   = iconView;
        _titleLabel                 = titleLabel;
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGFloat self_w        = self.bounds.size.width;
    CGFloat self_h        = self.bounds.size.height;

    CGFloat  background_x = (self_w - _backgroundSize.width)/2;
    CGFloat  background_y = (self_h - _backgroundSize.height  - _titleHeight - _spacing)/2;
    _backgroundView.frame = CGRectMake(background_x, background_y, _backgroundSize.width, _backgroundSize.height);

    CGFloat  image_x      = (_backgroundSize.width - _imageSize.width)/2;
    CGFloat  image_y      = (_backgroundSize.height - _imageSize.height)/2;
    _iconView.frame       = CGRectMake(image_x, image_y, _imageSize.width, _imageSize.height);

    CGFloat  title_y      = background_y + _backgroundSize.height + _spacing;
    CGFloat  title_w      = self_w;
    _titleLabel.frame     = CGRectMake(0, title_y, title_w, _titleHeight);
}

- (void)updateTitle:(NSString *)title defaultIcon:(NSString *)defaultIcon selectedIcon:(NSString *)selectedIcon selected:(BOOL)selected {
    _defaultIcon     = defaultIcon;
    _selectedIcon    = selectedIcon;
    _titleLabel.text = title.localizde;
    self.selected    = selected;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        if (!_selectedIcon) {
            return;
        }
        _iconView.image = [UIImage imageNamed:_selectedIcon];
    }
    else{
        if (!_defaultIcon) {
            return;
        }
        _iconView.image = [UIImage imageNamed:_defaultIcon];
    }
}

@end
