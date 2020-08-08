//
//  KSMeetingBarView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//  246:46

#import "KSMeetingBarView.h"
#import "KSMeetingBarCell.h"
#import "KSMeetingBarCell.h"
#import "KSBtnInfo.h"
@interface KSMeetingBarView()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,KSMeetingBarCellDelegate>

@property(nonatomic,strong)NSMutableArray *bars;

@end

static NSString *meetingBarCellIdentifier = @"meetingBarCellIdentifier";

@implementation KSMeetingBarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initProperty];
        [self initKit];
    }
    return self;
}

- (void)initProperty {
    _bars = [KSBtnInfo meetingBarBtns];
}

- (void)initKit {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize                = CGSizeMake(50, 46);
    /*
     //一个section有很多行item，这个属性表示最小行距，默认值不是0
     @property (nonatomic) CGFloat minimumLineSpacing;
     //这个属性表示两个item之间的最小间距，默认值不是0
     @property (nonatomic) CGFloat minimumInteritemSpacing;
     //这个属性表示section的内边距，上下左右的留边
     @property (nonatomic) UIEdgeInsets sectionInset;
     */
    flowLayout.minimumLineSpacing      = 0;
    flowLayout.minimumInteritemSpacing = KS_Extern_Point04;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    flowLayout.scrollDirection         = UICollectionViewScrollDirectionVertical;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 246, 46) collectionViewLayout:flowLayout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:[KSMeetingBarCell class] forCellWithReuseIdentifier:meetingBarCellIdentifier];
    [self addSubview:collectionView];
}

//UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _bars.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KSMeetingBarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:meetingBarCellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    [cell configureBarBtn:_bars[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

#pragma mark - KSMeetingBarCellDelegate
-(void)meetingBarCell:(KSMeetingBarCell *)cell didSelectBarBtn:(KSBtnInfo *)btnInfo {
    
}

@end
