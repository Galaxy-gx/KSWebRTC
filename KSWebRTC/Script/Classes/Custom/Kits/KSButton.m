//
//  KSButton.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSButton.h"
#import "NSString+Category.h"
@interface KSButton()

@property(nonatomic,copy)NSString *defaultIcon;
@property(nonatomic,copy)NSString *selectedIcon;
@property(nonatomic,weak)UIImageView *iconView;
@property(nonatomic,weak)UILabel *titleLabel;
@end

@implementation KSButton

-(instancetype)initWithFrame:(CGRect)frame title:(NSString *)title textColor:(UIColor*)textColor font:(UIFont *)font alignment:(NSTextAlignment)alignment titleHeight:(int)titleHeight defaultIcon:(NSString *)defaultIcon selectedIcon:(NSString *)selectedIcon imageSize:(CGSize)imageSize layoutType:(KSButtonLayoutType)layoutType spacing:(CGFloat)spacing {
    if (self = [super initWithFrame:frame]) {
        _defaultIcon = defaultIcon;
        _selectedIcon = selectedIcon;
        
        UIImageView *iconView = [[UIImageView alloc] init];
        iconView.image = [UIImage imageNamed:defaultIcon];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = title.localizde;
        titleLabel.textColor = textColor;
        titleLabel.font = font;
        titleLabel.textAlignment = alignment;
        
        [self addSubview:iconView];
        [self addSubview:titleLabel];
        
        int image_y;
        int title_y;
        switch (layoutType) {
            case KSButtonLayoutTypeTitleTop:
            {
                image_y = self.bounds.size.height/2 + spacing/2;
                title_y = self.bounds.size.height/2 - spacing/2 - titleHeight;
            }
                break;
            case KSButtonLayoutTypeTitleCenter:
            {
                image_y = (self.bounds.size.height - imageSize.height)/2;
                title_y = (self.bounds.size.height - titleHeight)/2;
            }
                break;
            case KSButtonLayoutTypeTitleBottom:
            {
                image_y = self.bounds.size.height/2 - spacing/2 - imageSize.height;
                title_y = self.bounds.size.height/2 + spacing/2;
            }
                break;
                
            default:
                break;
        }
        
        iconView.frame = CGRectMake((self.bounds.size.width - imageSize.width)/2, image_y, imageSize.width, imageSize.height);
        titleLabel.frame = CGRectMake(0, title_y, self.bounds.size.width, titleHeight);
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame textColor:(UIColor*)textColor font:(UIFont *)font alignment:(NSTextAlignment)alignment titleHeight:(int)titleHeight imageSize:(CGSize)imageSize layoutType:(KSButtonLayoutType)layoutType spacing:(CGFloat)spacing {
    if (self = [super initWithFrame:frame]) {
        
        UIImageView *iconView = [[UIImageView alloc] init];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = textColor;
        titleLabel.font =font;
        titleLabel.textAlignment = alignment;
        
        [self addSubview:iconView];
        [self addSubview:titleLabel];
        
        int image_y;
        int title_y;
        switch (layoutType) {
            case KSButtonLayoutTypeTitleTop:
            {
                image_y = self.bounds.size.height/2 + spacing/2;
                title_y = self.bounds.size.height/2 - spacing/2 - titleHeight;
            }
                break;
            case KSButtonLayoutTypeTitleCenter:
            {
                image_y = (self.bounds.size.height - imageSize.height)/2;
                title_y = (self.bounds.size.height - titleHeight)/2;
            }
                break;
            case KSButtonLayoutTypeTitleBottom:
            {
                image_y = self.bounds.size.height/2 - spacing/2 - imageSize.height;
                title_y = self.bounds.size.height/2 + spacing/2;
            }
                break;
                
            default:
                break;
        }
        
        iconView.frame = CGRectMake((self.bounds.size.width - imageSize.width)/2, image_y, imageSize.width, imageSize.height);
        titleLabel.frame = CGRectMake(0, title_y, self.bounds.size.width, titleHeight);
    }
    return self;
}

-(void)updateTitle:(NSString *)title {
    _titleLabel.text = title.localizde;
}

-(void)updateDefaultIcon:(NSString *)defaultIcon selectedIcon:(NSString *)selectedIcon selected:(BOOL)selected {
    _defaultIcon = defaultIcon;
    _selectedIcon = selectedIcon;
    self.selected = selected;
}

-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        _iconView.image = [UIImage imageNamed:_selectedIcon];
    }
    else{
        _iconView.image = [UIImage imageNamed:_defaultIcon];
    }
}

@end
