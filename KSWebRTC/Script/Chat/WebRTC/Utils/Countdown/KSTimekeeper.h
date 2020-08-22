//
//  KSTimekeeper.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/22.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSTimekeeperInfo : NSObject
@property (nonatomic, assign) int second;
@property (nonatomic, assign) int minute;
@property (nonatomic, assign) int hours;
@property (nonatomic, assign ,readonly) int sumSecond;

-(void)updateHours:(int)hours minute:(int)minute second:(int)second;

@end


@interface KSTimekeeper : NSObject
-(void)countdownOfTime:(int)time callback:(void(^)(KSTimekeeperInfo *countdown))callback;
-(void)timingOfCallback:(void(^)(KSTimekeeperInfo *countdown))callback;
@end
