//
//  KSCallMenu.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/24.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSCallMenu.h"
#import "NSString+Category.h"
@implementation KSCallMenu

- (instancetype)initWithTitle:(NSString *)title defaultIcon:(NSString *)defaultIcon selectedIcon:(NSString *)selectedIcon menuType:(KSCallMenuType)menuType {
    if (self = [super init]) {
        _title        = title.localizde;
        _defaultIcon  = defaultIcon;
        _selectedIcon = selectedIcon;
        _menuType     = menuType;
    }
    return self;
}

+ (NSMutableArray *)callMenus {
    NSMutableArray *sections = [NSMutableArray array];

    NSMutableArray *menus    = [NSMutableArray array];
    KSCallMenu *videoCall    = [[KSCallMenu alloc] initWithTitle:@"ks_app_global_text_video_call" defaultIcon:@"icon_menu_video_call" selectedIcon:@"icon_menu_video_call" menuType:KSCallMenuTypeVideo];
    [menus addObject:videoCall];
    KSCallMenu *voiceCall    = [[KSCallMenu alloc] initWithTitle:@"ks_app_global_text_voice_call" defaultIcon:@"icon_menu_voice_call" selectedIcon:@"icon_menu_voice_call" menuType:KSCallMenuTypeVoice];
    [menus addObject:voiceCall];

    [sections addObject:menus];

    NSMutableArray *cancels  = [NSMutableArray array];
    KSCallMenu *cancel       = [[KSCallMenu alloc] initWithTitle:@"ks_app_global_text_cancel" defaultIcon:nil selectedIcon:nil menuType:KSCallMenuTypeCancel];
    [cancels addObject:cancel];
    [sections addObject:cancels];
    return sections;
}
@end
