//
//  KSTimekeeper.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/22.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSTimekeeper.h"
@implementation KSTimekeeperInfo
-(void)updateHours:(int)hours minute:(int)minute second:(int)second {
    _hours  = hours;
    _minute = minute;
    _second = second;
}

- (int)sumSecond {
    int sumSecond = (_hours * 60 * 60) + (_minute * 60) + _second;
    return sumSecond;
}
@end

@interface KSTimekeeper()
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) KSTimekeeperInfo  *timekeeperInfo;
@end

@implementation KSTimekeeper

-(void)countdownOfTime:(int)time callback:(void(^)(KSTimekeeperInfo *countdown))callback {
    NSDate *targetDate            = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval targetInterval = [targetDate timeIntervalSince1970] + time;
    __weak typeof(self) weakSelf  = self;
    if (_timer == nil) {
        __block int timeSign = time;
        if (timeSign != 0) {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
            dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0);
            dispatch_source_set_event_handler(_timer, ^{
                NSDate *currentDate             = [NSDate dateWithTimeIntervalSinceNow:0];
                NSTimeInterval residualInterval = targetInterval - [currentDate timeIntervalSince1970];
                timeSign                        = residualInterval;
                if(timeSign <= 0){
                    [weakSelf invalidate];
                    [weakSelf.timekeeperInfo updateHours:0 minute:0 second:0];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (callback) {
                            callback(weakSelf.timekeeperInfo);
                        }
                    });
                }else{
                    int hours  = timeSign / 3600;
                    int minute = (timeSign / 60) % 60;
                    int second = timeSign % 60;
                    [weakSelf.timekeeperInfo updateHours:hours minute:minute second:second];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (callback) {
                            callback(weakSelf.timekeeperInfo);
                        }
                    });
                }
            });
            dispatch_resume(_timer);
        }
    }
}

-(void)timingOfCallback:(void(^)(KSTimekeeperInfo *timing))callback {
    NSDate *startDate            = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval startInterval = [startDate timeIntervalSince1970];
    __weak typeof(self) weakSelf = self;
    if (_timer == nil) {
        __block int timeSign   = 0;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
        dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler(_timer, ^{
            NSDate *currentDate             = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval residualInterval = [currentDate timeIntervalSince1970] - startInterval;
            timeSign                        = residualInterval;

            int hours                       = timeSign / 3600;
            int minute                      = (timeSign / 60) % 60;
            int second                      = timeSign % 60;
            [weakSelf.timekeeperInfo updateHours:hours minute:minute second:second];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback) {
                    callback(weakSelf.timekeeperInfo);
                }
            });
        });
        dispatch_resume(_timer);
    }
}

-(void)invalidate {
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

-(KSTimekeeperInfo *)timekeeperInfo {
    if (_timekeeperInfo == nil) {
        _timekeeperInfo = [[KSTimekeeperInfo alloc] init];
    }
    return _timekeeperInfo;
}
@end

