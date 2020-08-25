//
//  KSCallMenuCell.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/24.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSCallMenuCell.h"
#import "KSButton.h"
#import "UIColor+Category.h"
#import "UIFont+Category.h"
#import "KSLayoutButton.h"
#import "UILabel+Category.h"
#import "UIView+Category.h"
@interface KSCallMenuCell()
@property (nonatomic,weak) KSLayoutButton *button;
@property (nonatomic,weak) UIView         *lineView;
@end

static NSString *const callMenuCell = @"KSCallMenuCell";
@implementation KSCallMenuCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

+ (instancetype)initWithTableView:(UITableView *)tableView {
    KSCallMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:callMenuCell];
    if (cell == nil) {
        cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:callMenuCell];
    }
    return cell;
}

- (void)initCell {
    KSLayoutButton *button        = [[KSLayoutButton alloc] initWithFrame:CGRectMake(0, 0, 300, 30) layoutType:KSButtonLayoutTypeTitleRight font:[UIFont ks_fontRegularOfSize:15] textColor:[UIColor ks_blackMenu] space:8 imageWidth:16 imageHeight:16];
    button.userInteractionEnabled = NO;
    _button                       = button;
    [self addSubview:button];

    UIView *lineView              = [[UIView alloc] init];
    lineView.backgroundColor      = [UIColor ks_grayMenu];
    lineView.hidden               = YES;
    _lineView                     = lineView;
    [self addSubview:lineView];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    _button.frame   = CGRectMake((self.bounds.size.width - 300)/2, (self.bounds.size.height - 30)/2, 300, 30);
    _lineView.frame = CGRectMake(0, self.bounds.size.height - 1, self.bounds.size.width, 1);

}
- (void)setMenu:(KSCallMenu *)menu {
    _menu = menu;
    [_button updateTitle:menu.title normalIcon:menu.defaultIcon selectedIcon:menu.selectedIcon selected:YES];
    _lineView.hidden = (menu.menuType == KSCallMenuTypeVideo) ? NO : YES;
}

@end


@interface KSCallMenuCancelCell()
@property(nonatomic,weak)UILabel *titleLabel;
@property(nonatomic,weak)UIView *lineView;
@end

static NSString *const callMenuCancelCell = @"KSCallMenuCancelCell";

@implementation KSCallMenuCancelCell

+ (instancetype)initWithTableView:(UITableView *)tableView {
    KSCallMenuCancelCell *cell = [tableView dequeueReusableCellWithIdentifier:callMenuCancelCell];
    if (cell == nil) {
        cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:callMenuCancelCell];
    }
    return cell;
}

- (void)initCell {
    UILabel *titleLabel      = [UILabel ks_labelWithTextColor:[UIColor ks_blackMenu] font:[UIFont ks_fontRegularOfSize:15] alignment:NSTextAlignmentCenter];
    _titleLabel              = titleLabel;
    [self addSubview:titleLabel];

    UIView *lineView         = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor ks_grayMenu];
    _lineView                = lineView;
    [self addSubview:lineView];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    _titleLabel.frame = CGRectMake((self.bounds.size.width - 300)/2, (self.bounds.size.height - 30)/2 + 6, 300, 30);
    _lineView.frame   = CGRectMake(0, 0, self.bounds.size.width, 6);
}

- (void)setMenu:(KSCallMenu *)menu {
    _menu            = menu;
    _titleLabel.text = menu.title;
}

@end
