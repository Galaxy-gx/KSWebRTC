//
//  KSRemoteView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/2.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSRemoteView.h"
#import "UIView+Category.h"
#import "KSProfileView.h"
#import "KSProfileBarView.h"
#import "KSRoundImageView.h"
#import "UIColor+Category.h"

@interface KSRemoteView()
@end

@implementation KSRemoteView

- (void)updateKit {
    switch (self.connection.callType) {
        case KSCallTypeSingleAudio:

            break;
        case KSCallTypeManyAudio:
            
            break;
        case KSCallTypeSingleVideo:
            self.profileBarView.hidden = YES;
            self.roundImageView.hidden = YES;
            break;
        case KSCallTypeManyVideo:
            self.profileBarView.hidden = NO;
            self.roundImageView.hidden = YES;
            break;
        default:
            break;
    }
}

//KSMediaConnectionUpdateDelegate
- (void)mediaConnection:(KSMediaConnection *)mediaConnection didChangeMediaState:(KSMediaState)mediaState {
    
}

@end
