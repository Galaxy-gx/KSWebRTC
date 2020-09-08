//
//  RTCIceCandidate+Category.m
//  Telegraph
//
//  Created by saeipi on 2020/9/5.
//

#import "RTCIceCandidate+Category.h"
static NSString const *kRTCICECandidateTypeKey       = @"type";
static NSString const *kRTCICECandidateTypeValue     = @"candidate";
static NSString const *kRTCICECandidateMidKey        = @"sdpMid";
static NSString const *kRTCICECandidateMLineIndexKey = @"sdpMLineIndex";
static NSString const *kRTCICECandidateSdpKey        = @"sdp";
//static NSString const *kRTCICECandidatesTypeKey      = @"candidates";

@implementation RTCIceCandidate (Category)

+ (RTCIceCandidate *)candidateFromJSONDictionary:(NSDictionary *)dictionary {
    NSString *mid = dictionary[kRTCICECandidateMidKey];
    NSString *sdp = dictionary[kRTCICECandidateSdpKey];
    NSNumber *num = dictionary[kRTCICECandidateMLineIndexKey];
    if (mid == nil || sdp == nil || num == nil) {
        return nil;
    }
    int mLineIndex = [num intValue];
    return [[RTCIceCandidate alloc] initWithSdp:sdp
                                  sdpMLineIndex:mLineIndex
                                         sdpMid:mid];
}

- (NSData *)JSONData {
    NSDictionary *json = @{
        kRTCICECandidateTypeKey : kRTCICECandidateTypeValue,
        kRTCICECandidateMLineIndexKey : @(self.sdpMLineIndex),
        kRTCICECandidateMidKey : self.sdpMid,
        kRTCICECandidateSdpKey : self.sdp
    };
    NSError *error = nil;
    NSData *data =
    [NSJSONSerialization dataWithJSONObject:json
                                    options:NSJSONWritingPrettyPrinted
                                      error:&error];
    if (error) {
        RTCLogError(@"Error serializing JSON: %@", error);
        return nil;
    }
    return data;
}

- (NSDictionary *)JSONDictionary {
    NSDictionary *json = @{
        kRTCICECandidateMLineIndexKey : @(self.sdpMLineIndex),
        kRTCICECandidateMidKey : self.sdpMid,
        kRTCICECandidateSdpKey : self.sdp
    };
    return json;
}

@end
