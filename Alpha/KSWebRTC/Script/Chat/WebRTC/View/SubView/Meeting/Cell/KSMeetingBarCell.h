//
//  KSMeetingBarCell.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/7.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KSBtnInfo;
@class KSMeetingBarCell;
@protocol KSMeetingBarCellDelegate <NSObject>
@required
-(void)meetingBarCell:(KSMeetingBarCell *)cell didSelectBarBtn:(KSBtnInfo *)btnInfo;

@end

@interface KSMeetingBarCell : UICollectionViewCell

@property(nonatomic,weak)id<KSMeetingBarCellDelegate> delegate;

-(void)configureBarBtn:(KSBtnInfo *)barBtn;

@end
