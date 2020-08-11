//
//  ARDSettingsModel.m
//  KSWebRTC
//
//  Created by saeipi on 2020/7/21.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "ARDSettingsModel.h"

@implementation ARDSettingsModel

- (int)currentVideoResolutionWidthFromStore {
    return 0;
}

- (int)currentVideoResolutionHeightFromStore {
    return 0;
}

- (RTCVideoCodecInfo *)currentVideoCodecSettingFromStore {
    return [[RTCVideoCodecInfo alloc] initWithName:@""];
}
@end
