//
//  KSRegex.m
//  Telegraph
//
//  Created by saeipi on 2020/8/31.
//

#import "KSRegex.h"

@implementation KSRegex

+ (NSString *)verifyWithRegex:(NSString *)regex string:(NSString *)string {
    if (!string) {
        return nil;
    }
    NSError *error = NULL;
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:regex
                                                                                       options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                                                                         error:&error];
    NSTextCheckingResult *result =
    [regularExpression firstMatchInString:string options:NSMatchingReportProgress range:NSMakeRange(0, [string length])];
    return result ? [string substringWithRange:result.range] : nil;
}

+ (NSString *)sdpSessionOfString:(NSString *)string {
    return [self verifyWithRegex:@"[0-9]{4,}" string:string];
}

@end
