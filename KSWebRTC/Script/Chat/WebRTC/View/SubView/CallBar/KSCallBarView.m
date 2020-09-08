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
#import "UIView+Category.h"
#import "UIColor+Category.h"
#import "KSCellAlignmentFlowLayout.h"

@interface KSCallBarView()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,KSCallBarCellDelegate>

@property (nonatomic, strong) NSMutableArray   *bars;
@property (nonatomic, weak  ) UICollectionView *collectionView;
@property (nonatomic, weak  ) KSDeviceSwitch   *deviceSwitch;
@end

static NSString *callBarCellIdentifier = @"callBarCellIdentifier";

@implementation KSCallBarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)initKits {
    [self initProperty];
    [self initCollectionView];
}

- (void)initProperty {
    if ([self.dataSource respondsToSelector:@selector(deviceSwitchOfCallBarView:)]) {
        _deviceSwitch = [self.dataSource deviceSwitchOfCallBarView:self];
    }
    if ([self.dataSource respondsToSelector:@selector(callTypeOfCallBarView:)]) {
        KSCallType type = [self.dataSource callTypeOfCallBarView:self];
        _bars           = [KSBtnInfo callBarBtnsWithCallType:type deviceSwitch:_deviceSwitch];
    }
}

- (void)reloadBar {
    [self initProperty];
    [_collectionView reloadData];
}

- (void)initCollectionView {
    [self ks_drawFilletOfRadius:24 backgroundColor:[UIColor ks_grayBar]];
    
    CGFloat collection_w                  = self.frame.size.width - KS_Extern_Point32 * 2;
    CGFloat minimumInteritemSpacing       = (collection_w - _bars.count * KS_Extern_Point40)/(_bars.count - 1) - 1;
    
    //KSCellAlignmentFlowLayout *flowLayout = [[KSCellAlignmentFlowLayout alloc]initWithType:KSCellAlignmentCenter spacing:KS_Extern_Point08];
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
    flowLayout.minimumInteritemSpacing     = minimumInteritemSpacing;
    flowLayout.sectionInset                = UIEdgeInsetsMake(0, 0, 0, 0);
    flowLayout.scrollDirection             = UICollectionViewScrollDirectionVertical;

    UICollectionView *collectionView       = [[UICollectionView alloc] initWithFrame:CGRectMake(KS_Extern_Point32,
                                                                                          KS_Extern_Point04,
                                                                                          collection_w,
                                                                                          KS_Extern_Point40)
                                                          collectionViewLayout:flowLayout];
    collectionView.backgroundColor         = [UIColor ks_grayBar];

    collectionView.dataSource              = self;
    collectionView.delegate                = self;
    _collectionView                        = collectionView;
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
            _deviceSwitch.microphoneEnabled = !btnInfo.isSelected;
            type = btnInfo.isSelected ? KSEventTypeInConversationMicrophoneClose : KSEventTypeInConversationMicrophoneOpen;
            break;
        case KSCallBarBtnTypeSpeaker:
            _deviceSwitch.speakerEnabled = !btnInfo.isSelected;
            type = btnInfo.isSelected ? KSEventTypeInConversationVolumeClose: KSEventTypeInConversationVolumeOpen;
            break;
        case KSCallBarBtnTypeCamera:
            _deviceSwitch.cameraEnabled = !btnInfo.isSelected;
            type = btnInfo.isSelected ? KSEventTypeInConversationCameraClose : KSEventTypeInConversationCameraOpen;
            break;
        case KSCallBarBtnTypeBluetooth:
            type = btnInfo.isSelected ? KSEventTypeInConversationBluetoothClose : KSEventTypeInConversationBluetoothOpen;
            break;
        case KSCallBarBtnTypePhone:
            type = KSEventTypeCallHangup;
            break;
        default:
            break;
    }
    
    if (self.callback) {
        self.callback(type,nil);
    }
}

@end
