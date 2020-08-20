//
//  KSLocalCell.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/12.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSLocalCell.h"
#import "KSLocalView.h"

@interface KSLocalCell()

@property(nonatomic,weak)KSLocalView *localView;

@end

@implementation KSLocalCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
    }
    return self;
}

- (void)initKit {
    KSLocalView *localView = [[KSLocalView alloc] initWithFrame:self.bounds];
    _localView = localView;
    [self addSubview:localView];
}

-(void)layoutSubviews {
    [super layoutSubviews];
}

-(void)setVideoTrack:(KSVideoTrack *)videoTrack {
    _videoTrack           = videoTrack;
    _localView.videoTrack = videoTrack;
}

@end
