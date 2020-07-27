//
//  ARDSettingsModel.h
//  KSWebRTC
//
//  Created by saeipi on 2020/7/21.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebRTC/RTCVideoCodecInfo.h>

@interface ARDSettingsModel : NSObject

- (int)currentVideoResolutionWidthFromStore;
- (int)currentVideoResolutionHeightFromStore;


- (RTCVideoCodecInfo *)currentVideoCodecSettingFromStore;
@end
