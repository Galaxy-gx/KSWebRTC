//
//  NSDictionary+Category.m
//  Telegraph
//
//  Created by saeipi on 2020/8/17.
//

#import "NSDictionary+Category.h"

@implementation NSDictionary (Category)

- (NSString *)toJson {
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        return nil;
    }
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return json;
}

@end
