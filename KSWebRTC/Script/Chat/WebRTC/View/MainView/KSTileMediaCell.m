//
//  KSRemoteCell.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/12.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSTileMediaCell.h"
#import "KSTileMediaView.h"

@interface KSTileMediaCell()

@property (nonatomic,weak) KSTileMediaView *mediaView;

@end
@implementation KSTileMediaCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
    }
    return self;
}

- (void)initKit {
    KSTileMediaView *mediaView = [[KSTileMediaView alloc] initWithFrame:self.bounds];
    _mediaView                 = mediaView;
    [self addSubview:mediaView];
}

-(void)setMediaTrack:(KSMediaTrack *)mediaTrack {
    _mediaTrack            = mediaTrack;
    _mediaView.mediaTrack = mediaTrack;
}

@end
