//
//  KSCallBarView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//  352 * 48

#import "KSCallBarView.h"
#import "KSCallBarCell.h"
#import "KSBtnInfo.h"
@interface KSCallBarView()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,KSCallBarCellDelegate>

@property(nonatomic,strong)NSMutableArray *bars;

@end

static NSString *callBarCellIdentifier = @"callBarCellIdentifier";

@implementation KSCallBarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initProperty];
        [self initKit];
    }
    return self;
}

- (void)initProperty {
    _bars = [KSBtnInfo callBarBtns];
}

- (void)initKit {
    [self ks_drawFilletOfRadius:24 backgroundColor:[UIColor ks_grayBar]];

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize                    = CGSizeMake(KS_Extern_Point40, KS_Extern_Point40);
    /*
     //一个section有很多行item，这个属性表示最小行距，默认值不是0
     @property (nonatomic) CGFloat minimumLineSpacing;
     //这个属性表示两个item之间的最小间距，默认值不是0
     @property (nonatomic) CGFloat minimumInteritemSpacing;
     //这个属性表示section的内边距，上下左右的留边
     @property (nonatomic) UIEdgeInsets sectionInset;
     */
    flowLayout.minimumLineSpacing          = 0;
    flowLayout.minimumInteritemSpacing     = KS_Extern_Point08;
    flowLayout.sectionInset                = UIEdgeInsetsMake(0, 0, 0, 0);
    flowLayout.scrollDirection             = UICollectionViewScrollDirectionVertical;

    UICollectionView *collectionView       = [[UICollectionView alloc] initWithFrame:CGRectMake(KS_Extern_Point32,
                                                                                          KS_Extern_Point04,
                                                                                          self.frame.size.width - KS_Extern_Point32 * 2,
                                                                                          KS_Extern_Point40)
                                                          collectionViewLayout:flowLayout];
    collectionView.backgroundColor         = [UIColor ks_grayBar];

    collectionView.dataSource              = self;
    collectionView.delegate                = self;
    [collectionView registerClass:[KSCallBarCell class] forCellWithReuseIdentifier:callBarCellIdentifier];
    [self addSubview:collectionView];
}

//UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _bars.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KSCallBarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:callBarCellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    [cell configureBarBtn:_bars[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

#pragma mark - KSCallBarCellDelegate
-(void)callBarCell:(KSCallBarCell *)cell didSelectBarBtn:(KSBtnInfo *)btnInfo {
    KSEventType type;
    switch (btnInfo.btnType) {
        case KSCallBarBtnTypeMicrophone:
            type = btnInfo.isSelected ? KSEventTypeInConversationMicrophoneClose : KSEventTypeInConversationMicrophoneOpen;
            break;
        case KSCallBarBtnTypeVolume:
            type = btnInfo.isSelected ? KSEventTypeInConversationVolumeClose: KSEventTypeInConversationVolumeOpen;
            break;
        case KSCallBarBtnTypeCamera:
            type = btnInfo.isSelected ? KSEventTypeInConversationCameraClose : KSEventTypeInConversationCameraOpen;
            break;
        case KSCallBarBtnTypeBluetooth:
            type = btnInfo.isSelected ? KSEventTypeInConversationBluetoothClose : KSEventTypeInConversationBluetoothOpen;
            break;
        case KSCallBarBtnTypePhone:
            type = KSEventTypeInConversationHangup;
            break;
        default:
            break;
    }
    
    if (self.callback) {
        self.callback(type,nil);
    }
}

@end
