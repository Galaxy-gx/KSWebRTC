//
//  KSCallMenuView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/24.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSCallMenuView.h"
#import "KSCallMenu.h"
#import "KSCallMenuCell.h"
#import "UIColor+Category.h"

@interface KSCallMenuView()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,weak  ) UITableView    *tableView;
@property (nonatomic,strong) NSMutableArray *menus;
@end

@implementation KSCallMenuView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
    }
    return self;
}

- (void)initKit {
    _menus                   = [KSCallMenu callMenus];
    self.backgroundColor     = [UIColor ks_colorWithHexString:@"#F5F7FA"];
    UITableView *tableView   = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    tableView.delegate       = self;
    tableView.dataSource     = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.scrollEnabled  = NO;
    _tableView               = tableView;
    [self addSubview:tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _menus.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *array = _menus[section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KSCallMenu *menu = self.menus[indexPath.section][indexPath.row];
    if (menu.menuType == KSCallMenuTypeCancel) {
        KSCallMenuCancelCell *cell = [KSCallMenuCancelCell initWithTableView:tableView];
        cell.menu                  = menu;
        return cell;
    }
    else{
        KSCallMenuCell *cell = [KSCallMenuCell initWithTableView:tableView];
        cell.menu            = menu;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    KSCallMenu *menu = self.menus[indexPath.section][indexPath.row];
    if (_callback) {
        _callback(menu.menuType);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return 56;
    }
    return 50;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 10;
//}
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 0.1;
//}

-(NSMutableArray *)menus {
    if (_menus == nil) {
        _menus = [NSMutableArray array];
    }
    return _menus;
}

@end
