//
//  KSCallBarCell.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KSBtnInfo;
@class KSCallBarCell;

@protocol KSCallBarCellDelegate <NSObject>
@required
-(void)callBarCell:(KSCallBarCell *)cell didSelectBarBtn:(KSBtnInfo *)btnInfo;

@end

@interface KSCallBarCell : UICollectionViewCell

@property(nonatomic,weak)id<KSCallBarCellDelegate> delegate;

-(void)configureBarBtn:(KSBtnInfo *)btnInfo;

@end
