//
//  KSTableViewCell.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/15.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSTableViewCell.h"

static NSString *const cellIdentifier = @"KSTableViewCell";

@implementation KSTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (instancetype)initWithTableView:(UITableView *)tableView {
    KSTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    return  cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initCell];
    }
    return self;
}

- (void)initCell {
    
}

-(void)callBackInfo:(id)info {
    if ([self.delegate respondsToSelector:@selector(tableViewCell:callbackInfo:)]) {
        [self.delegate tableViewCell:self callbackInfo:info];
    }
}

@end
