//
//  RTCIceCandidate+Category.h
//  Telegraph
//
//  Created by saeipi on 2020/9/5.
//

#import <WebRTC/WebRTC.h>

@interface RTCIceCandidate (Category)
+ (RTCIceCandidate *)candidateFromJSONDictionary:(NSDictionary *)dictionary;
- (NSData *)JSONData;
- (NSDictionary *)JSONDictionary;
@end
