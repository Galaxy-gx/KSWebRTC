//
//  KSDeviceSwitch.m
//  Telegraph
//
//  Created by saeipi on 2020/9/4.
//

#import "KSDeviceSwitch.h"

@implementation KSDeviceSwitch
-(instancetype)init {
    if (self = [super init]) {
        [self resetSwitch];
    }
    return self;
}

- (void)resetSwitch {
    _microphoneEnabled = YES;
    _cameraEnabled     = YES;
    _speakerEnabled    = YES;
}

@end
