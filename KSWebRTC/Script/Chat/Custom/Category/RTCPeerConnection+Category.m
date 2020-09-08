//
//  RTCPeerConnection+Category.m
//  Telegraph
//
//  Created by saeipi on 2020/9/5.
//

#import "RTCPeerConnection+Category.h"
#import "KSRTCKey.h"
@implementation RTCPeerConnection (Category)

- (NSMutableDictionary *)ks_jseps {
    RTCSessionDescription *localDescription = self.localDescription;
    NSString *type                          = [RTCSessionDescription stringForType:localDescription.type];
    NSString *sdp                           = localDescription.sdp;
    if (type && sdp) {
        NSMutableDictionary *jseps =[NSMutableDictionary dictionary];
        jseps[kRTCGlobalTypeKey] = type;
        jseps[kRTCGlobalSdpKey]  = sdp;
        jseps[kRTCGlobalFlagKey] = kRTCGlobalFlagKey;
        return jseps;
    }
    return nil;
}

@end
