//
//  KSButton.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSButton.h"
#import "NSString+Category.h"
#import "UILabel+Category.h"

@interface KSButton() {
    CGFloat image_x;
    CGFloat image_y;
    CGFloat title_x;
    CGFloat title_y;
    CGFloat title_w;
    CGSize _imageSize;
    int _titleHeight;
    CGFloat _spacing;
    KSButtonLayoutType _layoutType;
}

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
        
        _titleHeight = titleHeight;
        _imageSize = imageSize;
        _spacing = spacing;
        _layoutType = layoutType;
        
        UIImageView *iconView = [[UIImageView alloc] init];
        iconView.image = [UIImage imageNamed:defaultIcon];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        if (title) {
            titleLabel.text = title.localizde;
        }
        titleLabel.textColor = textColor;
        titleLabel.font = font;
        titleLabel.textAlignment = alignment;
        
        [self addSubview:iconView];
        [self addSubview:titleLabel];
        
        _iconView = iconView;
        _titleLabel = titleLabel;
        
        [self updateKitsCoordinate];

        iconView.frame = CGRectMake(image_x, image_y, imageSize.width, imageSize.height);
        titleLabel.frame = CGRectMake(title_x, title_y, title_w, titleHeight);
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame textColor:(UIColor*)textColor font:(UIFont *)font alignment:(NSTextAlignment)alignment titleHeight:(int)titleHeight imageSize:(CGSize)imageSize layoutType:(KSButtonLayoutType)layoutType spacing:(CGFloat)spacing {
    if (self = [super initWithFrame:frame]) {
        
        _titleHeight = titleHeight;
        _imageSize = imageSize;
        _spacing = spacing;
        _layoutType = layoutType;
        
        UIImageView *iconView = [[UIImageView alloc] init];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = textColor;
        titleLabel.font =font;
        titleLabel.textAlignment = alignment;
        
        [self addSubview:iconView];
        [self addSubview:titleLabel];
        
        _iconView = iconView;
        _titleLabel = titleLabel;
        
        [self updateKitsCoordinate];
        
        iconView.frame = CGRectMake(image_x, image_y, imageSize.width, imageSize.height);
        titleLabel.frame = CGRectMake(title_x, title_y, title_w, titleHeight);
    }
    return self;
}

-(void)updateKitsCoordinate {
    
    image_x = 0;
    image_y = 0;
    title_x = 0;
    title_y = 0;
    title_w = 0;
    CGFloat self_w = self.bounds.size.width;
    CGFloat self_h = self.bounds.size.height;
    
    switch (_layoutType) {
        case KSButtonLayoutTypeTitleTop:
        {
            image_x = (self_w - _imageSize.width)/2;
            
            title_y = (self_h - _imageSize.height - _titleHeight - _spacing)/2;
            title_w = self_w;
            
            image_y = title_y + _titleHeight + _spacing;
        }
            break;
        case KSButtonLayoutTypeTitleCenter:
        {
            image_x = (self_w - _imageSize.width)/2;
            image_y = (self_h - _imageSize.height)/2;
            
            title_y = (self_h - _titleHeight)/2;
            title_w = self_w;
        }
            break;
        case KSButtonLayoutTypeTitleBottom:
        {
            image_x = (self_w - _imageSize.width)/2;
            image_y = (self_h - _imageSize.height - _titleHeight - _spacing)/2;
            
            title_y = image_y + _imageSize.height + _spacing;
            title_w = self_w;
        }
            break;
        case KSButtonLayoutTypeTitleLeft:
        {
            if (_titleLabel.text.length > 0) {
                CGSize size = [_titleLabel ks_textSize];
                image_x = size.width + _spacing;
                
                title_w = size.width;
            }
            else{
                image_x = self_w - _imageSize.width - _spacing;
                
                title_w = image_x;
            }
            
            image_y = (self_h - _imageSize.height)/2;
            
            title_y = (self_h - _titleHeight)/2;
        }
            break;
        case KSButtonLayoutTypeTitleRight:
        {
            if (_titleLabel.text.length > 0) {
                CGSize size = [_titleLabel ks_textSize];
                title_w = size.width;
                title_x = _imageSize.width + _spacing;
            }
            else{
                title_w = self_w - _imageSize.width - _spacing;
                title_x = _imageSize.width + _spacing;
            }
            
            image_y = (self_h - _imageSize.height)/2;
            
            title_y = (self_h - _titleHeight)/2;
        }
            break;
        default:
            break;
    }
}

-(void)updateTitle:(NSString *)title {
    _titleLabel.text  = title.localizde;
    [self updateKitsCoordinate];
    _iconView.frame   = CGRectMake(image_x, image_y, _imageSize.width, _imageSize.height);
    _titleLabel.frame = CGRectMake(title_x, title_y, title_w, _titleHeight);
}

-(void)updateDefaultIcon:(NSString *)defaultIcon selectedIcon:(NSString *)selectedIcon selected:(BOOL)selected {
    _defaultIcon = defaultIcon;
    _selectedIcon = selectedIcon;
    self.selected = selected;
}

-(void)setSelected:(BOOL)selected {
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
