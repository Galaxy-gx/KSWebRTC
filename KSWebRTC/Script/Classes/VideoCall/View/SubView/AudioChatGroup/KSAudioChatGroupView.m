//
//  KSAudioChatGroupView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/7.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSAudioChatGroupView.h"
#import "KSAudioChatProfileCell.h"

@interface KSAudioChatGroupView()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@end

static NSString *audioChatProfileCellIdentifier = @"audioChatProfileCellIdentifier";

@implementation KSAudioChatGroupView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
    }
    return self;
}

- (void)initKit {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize                = CGSizeMake(KS_Extern_Point40, KS_Extern_Point40);
    /*
     //一个section有很多行item，这个属性表示最小行距，默认值不是0
     @property (nonatomic) CGFloat minimumLineSpacing;
     //这个属性表示两个item之间的最小间距，默认值不是0
     @property (nonatomic) CGFloat minimumInteritemSpacing;
     //这个属性表示section的内边距，上下左右的留边
     @property (nonatomic) UIEdgeInsets sectionInset;
     */
    flowLayout.minimumLineSpacing      = 0;
    flowLayout.minimumInteritemSpacing = KS_Extern_Point42;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    flowLayout.scrollDirection         = UICollectionViewScrollDirectionVertical;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(KS_Extern_Point32,
                                                                                          KS_Extern_Point04,
                                                                                          self.frame.size.width - KS_Extern_Point32 * 2,
                                                                                          KS_Extern_Point40)];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:[KSAudioChatProfileCell class] forCellWithReuseIdentifier:audioChatProfileCellIdentifier];
    [self addSubview:collectionView];
}


@end
