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
#import "KSProfileInfo.h"
#import "KSDeviceSwitch.h"
//Kit
#import "KSTileMediaView.h"
#import "KSMediaTrack.h"

@class KSCallView;
@protocol KSCallViewDataSource <NSObject>
- (NSInteger)callView:(KSCallView *)callView numberOfItemsInSection:(NSInteger)section;
- (KSMediaTrack *)callView:(KSCallView *)callView itemAtIndexPath:(NSIndexPath *)indexPath;
- (KSCallType)callTypeOfCallView:(KSCallView *)callView;
@end

@interface KSCallView : KSEventCallbackView
@property(nonatomic,weak)id<KSCallViewDataSource> dataSource;

- (instancetype)initWithFrame:(CGRect)frame tileLayout:(KSTileLayout *)tileLayout deviceSwitch:(KSDeviceSwitch *)deviceSwitch;
- (void)initKits;
- (void)setScreenMediaTrack:(KSMediaTrack *)mediaTrack;
- (void)setTileMediaTrack:(KSMediaTrack *)mediaTrack;

- (void)updateSwitchOfCalltype:(KSCallType)callType;
- (void)clearRender;//清除渲染
#pragma mark - KSProfileView
- (void)setProfileInfo:(KSProfileInfo *)profileInfo;
#pragma mark - KSAnswerBarView
- (void)setAnswerState:(KSAnswerState)state;
- (void)hideAnswerBar;
#pragma mark - KSCallBarView
- (void)displayCallBar;
- (void)setCallBarHidden:(BOOL)hidden;
#pragma mark - UICollectionView
- (void)reloadItemsAtIndex:(NSInteger)index;
- (void)insertItemsAtIndex:(NSInteger)index;
- (void)deleteItemsAtIndex:(NSInteger)index;
- (void)reloadSection;
- (void)reloadCollectionView;

@end

@interface KSMediaSwitch : NSObject
@property (nonatomic,assign) KSCallMenuType mediaType;
@property (nonatomic,assign) KSCallType     callType;
@end
