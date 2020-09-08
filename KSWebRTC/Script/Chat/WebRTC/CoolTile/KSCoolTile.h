//
//  KSCoolTile.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/31.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSTileMediaView.h"
@class KSCoolTile;
@protocol KSCoolTileDelegate <NSObject>
- (void)returnToCallInterfaceOfCoolTile:(KSCoolTile *)coolTile;
@end

@interface KSCoolTile : KSTileMediaView
@property(nonatomic,weak) id<KSCoolTileDelegate> delegate;
@property (nonatomic,assign) BOOL isDisplay;

- (void)showMediaTrack:(KSMediaTrack *)mediaTrack;
- (void)callEnded;
- (void)resetKit;

@end
