//
//  KSRegex.h
//  Telegraph
//
//  Created by saeipi on 2020/8/31.
//

#import <Foundation/Foundation.h>

@interface KSRegex : NSObject

+ (NSString *)verifyWithRegex:(NSString *)regex string:(NSString *)string;
+ (NSString *)sdpSessionOfString:(NSString *)string;
@end
