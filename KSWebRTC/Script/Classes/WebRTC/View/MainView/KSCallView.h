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

//Other
#import "KSMediaConnection.h"

@class KSCallView;
@protocol KSCallViewDataSource <NSObject>

- (NSInteger)callView:(KSCallView *)callView numberOfItemsInSection:(NSInteger)section;
- (KSMediaConnection *)callView:(KSCallView *)callView itemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface KSCallView : KSEventCallbackView
@property(nonatomic,weak)id<KSCallViewDataSource> dataSource;

- (instancetype)initWithFrame:(CGRect)frame tileLayout:(KSTileLayout *)tileLayout callType:(KSCallType)callType;
- (void)createLocalViewWithTileLayout:(KSTileLayout *)tileLayout;
- (void)setLocalViewSession:(AVCaptureSession *)session;
- (void)leaveLocal;
- (void)leaveOfHandleId:(NSNumber *)handleId;
- (void)createRemoteViewOfConnection:(KSMediaConnection *)connection;

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
- (void)reloadCollectionView;

@end
