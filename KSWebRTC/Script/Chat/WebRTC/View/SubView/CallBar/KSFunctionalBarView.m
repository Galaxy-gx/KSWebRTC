//
//  KSFunctionalBarView.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/25.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSFunctionalBarView.h"
#import "UIView+Category.h"
#import "UIColor+Category.h"
#import "KSFunctionalBarCell.h"
#import "KSCellAlignmentFlowLayout.h"
@interface KSFunctionalBarView()<UICollectionViewDataSource,UICollectionViewDelegate>
@property(nonatomic,strong)NSMutableArray *bars;
@end

static NSString *const functionalBarCell = @"KSFunctionalBarCell";

@implementation KSFunctionalBarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
    }
    return self;
}

- (void)initKit {
    _bars = [KSBtnInfo threeBarBtns];
    KSCellAlignmentFlowLayout * flowLayout = [[KSCellAlignmentFlowLayout alloc]initWithType:KSCellAlignmentCenter spacing:KS_Extern_Point10];
    flowLayout.itemSize                    = CGSizeMake(90, 90);
    flowLayout.minimumLineSpacing          = 10;
    flowLayout.minimumInteritemSpacing     = KS_Extern_Point08;
    flowLayout.sectionInset                = UIEdgeInsetsMake(0, 0, 0, 0);
    flowLayout.scrollDirection             = UICollectionViewScrollDirectionVertical;

    UICollectionView *collectionView       = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.bounds.size.height) collectionViewLayout:flowLayout];
    collectionView.backgroundColor         = [UIColor clearColor];

    collectionView.dataSource              = self;
    collectionView.delegate                = self;
    [collectionView registerClass:[KSFunctionalBarCell class] forCellWithReuseIdentifier:functionalBarCell];
    [self addSubview:collectionView];
}

- (void)setEventCallback:(KSEventCallback)callback {
    _callback = callback;
}

//UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _bars.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KSFunctionalBarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:functionalBarCell forIndexPath:indexPath];
    KSBtnInfo *btnInfo        = _bars[indexPath.item];
    cell.btnInfo              = btnInfo;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    KSBtnInfo *btnInfo = _bars[indexPath.item];
    KSEventType type   = KSEventTypeStartUnknown;
    switch (btnInfo.btnType) {
        case KSCallBarBtnTypeCamera:
        {
            type = btnInfo.isSelected ? (_isSession ? KSEventTypeInConversationCameraClose : KSEventTypeMeetingThemeCameraClose) : (_isSession ? KSEventTypeInConversationCameraOpen : KSEventTypeMeetingThemeCameraOpen);
        }
            break;
        case KSCallBarBtnTypeMicrophone:
        {
            type = btnInfo.isSelected ? (_isSession ? KSEventTypeInConversationMicrophoneClose : KSEventTypeMeetingThemeMicrophoneClose) : (_isSession ? KSEventTypeInConversationMicrophoneOpen : KSEventTypeMeetingThemeMicrophoneOpen);
        }
            break;
        case KSCallBarBtnTypeSpeaker:
        {
            type = btnInfo.isSelected ? (_isSession ? KSEventTypeInConversationVolumeClose : KSEventTypeMeetingThemeVolumeClose) : (_isSession ? KSEventTypeInConversationVolumeOpen : KSEventTypeMeetingThemeVolumeOpen);
        }
            
            break;
        default:
            break;
    }
    if (_callback) {
        _callback(type,nil);
    }
}

@end
