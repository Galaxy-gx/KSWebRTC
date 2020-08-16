//
//  KSWaitingAnswersGroupView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/7.
//  Copyright © 2020 saeipi. All rights reserved.
//  顶部y-10抵消 flowLayout.minimumLineSpacing = KS_Extern_Point10;

#import "KSWaitingAnswersGroupView.h"
#import "KSWaitingAnswersMemberCell.h"
#import "KSCellAlignmentFlowLayout.h"

@interface KSWaitingAnswersGroupView()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@end

static NSString *waitingAnswersMemberCellIdentifier = @"waitingAnswersMemberCellIdentifier";

@implementation KSWaitingAnswersGroupView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
    }
    return self;
}

- (void)initKit {
    KSCellAlignmentFlowLayout * flowLayout = [[KSCellAlignmentFlowLayout alloc]initWithType:KSCellAlignmentCenter spacing:KS_Extern_Point10];
    //UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize                = CGSizeMake(KS_Extern_Point40, KS_Extern_Point40);
    /*
     //一个section有很多行item，这个属性表示最小行距，默认值不是0
     @property (nonatomic) CGFloat minimumLineSpacing;
     //这个属性表示两个item之间的最小间距，默认值不是0
     @property (nonatomic) CGFloat minimumInteritemSpacing;
     //这个属性表示section的内边距，上下左右的留边
     @property (nonatomic) UIEdgeInsets sectionInset;
     */
    flowLayout.minimumLineSpacing      = KS_Extern_Point10;
    flowLayout.minimumInteritemSpacing = KS_Extern_Point10;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, KS_Extern_Point20, 0, KS_Extern_Point20);
    flowLayout.scrollDirection         = UICollectionViewScrollDirectionVertical;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.bounds.size.height)
                                                          collectionViewLayout:flowLayout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.backgroundColor = [UIColor clearColor];
    [collectionView registerClass:[KSWaitingAnswersMemberCell class] forCellWithReuseIdentifier:waitingAnswersMemberCellIdentifier];
    [self addSubview:collectionView];
}

//UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 16;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KSWaitingAnswersMemberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:waitingAnswersMemberCellIdentifier forIndexPath:indexPath];
    return cell;
}

@end
