//
//  KSTopBarView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/7.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSTopBarView.h"
#import "UIButton+Category.h"
#import "UIColor+Category.h"
#import "UIFont+Category.h"
#import "UILabel+Category.h"
#import "KSTimekeeper.h"
#import "KSCellAlignmentFlowLayout.h"
#import "KSBtnInfo.h"

@class KSTopBarCell;
@protocol KSTopBarCellDelegate <NSObject>
-(void)topBarCell:(KSTopBarCell *)cell callbackOfBtnInfo:(KSBtnInfo *)btnInfo;
@end
@interface KSTopBarCell : UICollectionViewCell
@property (nonatomic,strong) KSBtnInfo *btnInfo;
@property (nonatomic,weak  ) id<KSTopBarCellDelegate> delegate;
@end

@interface KSTopBarCell()
@property(nonatomic,weak)UIButton *button;
@end

@implementation KSTopBarCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
    }
    return self;
}

- (void)initKit {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button          = button;
    [button addTarget:self action:@selector(onButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
}

- (void)onButtonClick {
    if ([self.delegate respondsToSelector:@selector(topBarCell:callbackOfBtnInfo:)]) {
        [self.delegate topBarCell:self callbackOfBtnInfo:_btnInfo];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _button.frame = self.bounds;
}

- (void)setBtnInfo:(KSBtnInfo *)btnInfo {
    _btnInfo = btnInfo;
    [_button setImage:[UIImage imageNamed:btnInfo.defaultIcon] forState:UIControlStateNormal];
}

@end

@interface KSTopBarView()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,KSTopBarCellDelegate>
@property (nonatomic,weak  ) UILabel          *timeLabel;
@property (nonatomic,strong) KSTimekeeper     *timekeeper;
@property (nonatomic,strong) NSMutableArray   *menus;
@property (nonatomic,weak  ) UICollectionView *collectionView;
@end

static NSString *topBarCellIdentifier = @"KSTopBarCell";

@implementation KSTopBarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initProperty];
        [self initKit];
    }
    return self;
}

- (void)initProperty {
    _timekeeper = [[KSTimekeeper alloc] init];
}

- (void)initKit {
    self.backgroundColor    = [UIColor ks_grayBar];
    [self initCollectionView];
    
    double btn_y            = self.bounds.size.height - 23 - 22;
    KSButton *identifierBtn = [[KSButton alloc] initWithFrame:CGRectMake(KS_Extern_Point12, btn_y, 160, KS_Extern_Point22)
                                                        title:@"ID:000 000 000"
                                                    textColor:[UIColor ks_white]
                                                         font:[UIFont ks_fontMediumOfSize:KS_Extern_16Font]
                                                    alignment:NSTextAlignmentLeft
                                                  titleHeight:KS_Extern_Point22
                                                  defaultIcon:@"icon_bar_more_members_white"
                                                 selectedIcon:@"icon_bar_more_members_white"
                                                    imageSize:CGSizeMake(KS_Extern_Point10, KS_Extern_Point10)
                                                   layoutType:KSButtonLayoutTypeTitleLeft
                                                      spacing:KS_Extern_Point04];
    _identifierBtn          = identifierBtn;
    [self addSubview:identifierBtn];
    
    UILabel *timeLabel      = [UILabel ks_labelWithFrame:CGRectMake(KS_Extern_Point12, CGRectGetMaxY(identifierBtn.frame) + KS_Extern_Point02, KS_Extern_Point100, KS_Extern_Point18)
                                               textColor:[UIColor ks_white]
                                                    font:[UIFont fontWithName:@"Helvetica Neue" size:KS_Extern_12Font]
                                               alignment:NSTextAlignmentLeft];
    timeLabel.text          = @"00:00:00";
    _timeLabel              = timeLabel;
    [self addSubview:timeLabel];
}

- (void)initCollectionView {
    KSCellAlignmentFlowLayout * flowLayout = [[KSCellAlignmentFlowLayout alloc]initWithType:KSCellAlignmentRight spacing:14];
    flowLayout.itemSize                    = CGSizeMake(30, 30);
    flowLayout.minimumInteritemSpacing     = KS_Extern_Point08;
    flowLayout.sectionInset                = UIEdgeInsetsMake(0, 0, 0, 0);
    flowLayout.scrollDirection             = UICollectionViewScrollDirectionVertical;

    UICollectionView *collectionView       = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 12, self.bounds.size.height) collectionViewLayout:flowLayout];
    collectionView.backgroundColor         = [UIColor clearColor];

    collectionView.dataSource              = self;
    collectionView.delegate                = self;
    [collectionView registerClass:[KSTopBarCell class] forCellWithReuseIdentifier:topBarCellIdentifier];
    _collectionView                        = collectionView;
    [self addSubview:collectionView];
}

//UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.menus.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KSTopBarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:topBarCellIdentifier forIndexPath:indexPath];
    cell.delegate      = self;
    KSBtnInfo *btnInfo = self.menus[indexPath.item];
    cell.btnInfo       = btnInfo;
    return cell;
}

-(void)topBarCell:(KSTopBarCell *)cell callbackOfBtnInfo:(KSBtnInfo *)btnInfo {
    if ([self.delegate respondsToSelector:@selector(topBarView:btnInfo:)]) {
        [self.delegate topBarView:self btnInfo:btnInfo];
    }
}

- (NSMutableArray *)menus {
    if (_menus == nil) {
        _menus = [NSMutableArray array];
    }
    return _menus;
}

- (void)reloadBar {
    if ([self.dataSource respondsToSelector:@selector(menuDatasOfTopBarView:)]) {
        _menus = [self.dataSource menuDatasOfTopBarView:self];
    }
    if (_menus.count > 0) {
        [_collectionView reloadData];
    }
}
- (void)updateSessionID {
    if ([self.dataSource respondsToSelector:@selector(sessionIDOfTopBarView:)]) {
        NSString *sessionID = [self.dataSource sessionIDOfTopBarView:self];
        [_identifierBtn updateTitle:[NSString stringWithFormat:@"ID:%@",sessionID]];
    }
}

- (void)showKitOfStartingTime:(int)time {
    self.hidden = NO;
    [self reloadBar];
    [self updateSessionID];
    [self stopTiming];
    
    __weak typeof(self) weakSelf = self;
    [_timekeeper timingOfTime:time callback:^(KSTimekeeperInfo *timing) {
        weakSelf.timeLabel.text = [NSString stringWithFormat:@"%.2d:%.2d:%.2d",timing.hours,timing.minute,timing.second];
    }];
}

- (void)hiddenKit {
    self.hidden = YES;
    [self stopTiming];
}

- (void)stopTiming {
    [_timekeeper invalidate];
}

-(void)dealloc {
    [self stopTiming];
}

@end
