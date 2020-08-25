//
//  KSCallMenuCell.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/24.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSTableViewCell.h"
#import "KSCallMenu.h"

@interface KSCallMenuCell : KSTableViewCell

@property(nonatomic,strong)KSCallMenu *menu;

@end

@interface KSCallMenuCancelCell : KSTableViewCell

@property(nonatomic,strong)KSCallMenu *menu;

@end


