//
//  KSCellAlignmentFlowLayout.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/6.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,KSCellAlignment){
    KSCellAlignmentLeft,
    KSCellAlignmentCenter,
    KSCellAlignmentRight
};
@interface KSCellAlignmentFlowLayout : UICollectionViewFlowLayout
//两个Cell之间的距离
@property (nonatomic,assign)CGFloat spacing;
//cell对齐方式
@property (nonatomic,assign)KSCellAlignment cellType;

-(instancetype)initWthType : (KSCellAlignment)cellType;
//全能初始化方法 其他方式初始化最终都会走到这里
-(instancetype)initWithType:(KSCellAlignment) cellType spacing:(CGFloat)spacing;

@end
