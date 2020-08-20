//
//  KSLocalView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/2.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSLocalView.h"
#import "UIView+Category.h"

@interface KSLocalView()
@end

@implementation KSLocalView

- (void)updateKit {
    self.profileBarView.hidden = YES;
    self.roundImageView.hidden = YES;
    
    
}

//KSVideoTrackDelegate
- (void)videoTrack:(KSVideoTrack *)videoTrack didChangeMediaState:(KSMediaState)mediaState {
    
}

@end
