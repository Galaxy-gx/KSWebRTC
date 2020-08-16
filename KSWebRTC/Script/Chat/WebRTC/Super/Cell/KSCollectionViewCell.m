//
//  KSCollectionViewCell.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/16.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSCollectionViewCell.h"

@implementation KSCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initCell];
    }
    return self;
}
- (void)initCell {
    self.contentView.backgroundColor = [UIColor whiteColor];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:self.bounds];
    [self addSubview:textLabel];
    _textLabel = textLabel;
}
@end
