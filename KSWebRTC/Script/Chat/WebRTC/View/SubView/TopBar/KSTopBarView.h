//
//  KSTopBarView.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/7.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSButton.h"
#import "KSBtnInfo.h"
@class KSTopBarView;

@protocol KSTopBarViewDataSource <NSObject>
- (NSMutableArray *)menuDatasOfTopBarView:(KSTopBarView *)topBarView;
- (NSString *)sessionIDOfTopBarView:(KSTopBarView *)topBarView;
@end

@protocol KSTopBarViewDelegate <NSObject>
- (void)topBarView:(KSTopBarView *)topBarView btnInfo:(KSBtnInfo *)btnInfo;
@end

@interface KSTopBarView : UIView

@property(nonatomic,weak)KSButton *identifierBtn;
@property(nonatomic,weak)id<KSTopBarViewDataSource> dataSource;
@property(nonatomic,weak)id<KSTopBarViewDelegate> delegate;

- (void)reloadBar;
- (void)showKitOfStartingTime:(int)time;
- (void)hiddenKit;

@end
