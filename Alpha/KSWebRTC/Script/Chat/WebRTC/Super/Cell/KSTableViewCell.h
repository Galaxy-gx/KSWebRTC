//
//  KSTableViewCell.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/15.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UITableViewCell;

@protocol KSTableViewCellDelegate <NSObject>

-(void)tableViewCell:(UITableViewCell *)cell callbackInfo:(id)info;

@end

@interface KSTableViewCell : UITableViewCell

@property(nonatomic,weak)id<KSTableViewCellDelegate> delegate;

+ (instancetype)initWithTableView:(UITableView *)tableView;

@end

