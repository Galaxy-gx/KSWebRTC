//
//  KSCallView.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/2.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSEventCallbackView.h"
#import <AVFoundation/AVFoundation.h>
//Configure
#import "KSConfigure.h"
#import "KSBlock.h"

//ViewModel
#import "KSTileLayout.h"
#import "KSProfileConfigure.h"

//Kit
#import "KSRemoteView.h"
#import "KSVideoTrack.h"


@class KSCallView;
@protocol KSCallViewDataSource <NSObject>

- (NSInteger)callView:(KSCallView *)callView numberOfItemsInSection:(NSInteger)section;
- (KSVideoTrack *)callView:(KSCallView *)callView itemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface KSCallView : KSEventCallbackView
@property(nonatomic,weak)id<KSCallViewDataSource> dataSource;

- (instancetype)initWithFrame:(CGRect)frame tileLayout:(KSTileLayout *)tileLayout;
- (void)createLocalViewWithTileLayout:(KSTileLayout *)tileLayout;
- (void)setLocalVideoTrack:(KSVideoTrack *)videoTrack;
- (void)createRemoteViewOfVideoTrack:(KSVideoTrack *)videoTrack;
- (void)leaveLocal;
- (void)leaveOfHandleId:(NSNumber *)handleId;

#pragma mark - KSProfileView
- (void)setProfileConfigure:(KSProfileConfigure *)configure;
#pragma mark - KSAnswerBarView
- (void)setAnswerState:(KSAnswerState)state;
- (void)hideAnswerBar;
#pragma mark - KSCallBarView
- (void)displayCallBar;
#pragma mark - UICollectionView
- (void)reloadItemsAtIndex:(NSInteger)index;
- (void)insertItemsAtIndex:(NSInteger)index;
- (void)deleteItemsAtIndex:(NSInteger)index;
- (void)reloadSection;
- (void)reloadCollectionView;

@end
