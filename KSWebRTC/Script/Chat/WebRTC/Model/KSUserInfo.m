//
//  KSUserInfo.m
//  Telegraph
//
//  Created by saeipi on 2020/8/28.
//

#import "KSUserInfo.h"
//#import "TGDatabase.h"
//#import "TGTelegraph.h"
@implementation KSUserInfo

+ (KSUserInfo *)userWithId:(int)Id {
    KSUserInfo *userInfo = [[KSUserInfo alloc] init];
    userInfo.ID          = Id;
    return userInfo;
}

+ (NSString *)nameWithId:(int)Id {
    return @"saeipi";
}

+ (KSUserInfo *)myself {
    KSUserInfo *userInfo = [[KSUserInfo alloc] init];
    userInfo.name        = @"saeipi";
    userInfo.ID          = [self myID];
    return userInfo;
}

+ (int)myID {
    return [self randomNumber];
}

+ (int )randomNumber {
    static int random = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        random = (arc4random() % 10000) + 10000;
        NSLog(@"|============| user_id : %d |============|",random);
    });
    return random;
}
@end
