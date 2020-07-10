//
//  RTCSessionDescription+Category.m
//  KSWebRTC
//
//  Created by saeipi on 2020/7/10.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "RTCSessionDescription+Category.h"

static NSString const *KSRTCSessionDescriptionTypeKey = @"type";
static NSString const *KSRTCSessionDescriptionSdpKey = @"sdp";

@implementation RTCSessionDescription (Category)

+ (RTCSessionDescription *)descriptionFromJSONDictionary:(NSDictionary *)dictionary {
    NSString *typeString = dictionary[KSRTCSessionDescriptionTypeKey];
    RTCSdpType type = [[self class] typeForString:typeString];
    NSString *sdp = dictionary[KSRTCSessionDescriptionSdpKey];
    return [[RTCSessionDescription alloc] initWithType:type sdp:sdp];
}

- (NSData *)jsonData {
    NSString *type = [[self class] stringForType:self.type];
    NSDictionary *json = @{
            KSRTCSessionDescriptionTypeKey: type,
            KSRTCSessionDescriptionSdpKey: self.sdp
    };
    return [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
}

@end
