//
//  KSUserInfo.m
//  Telegraph
//
//  Created by saeipi on 2020/8/28.
//

#import "KSUserInfo.h"
@implementation KSUserInfo

+ (KSUserInfo *)userWithId:(int)Id {
    KSUserInfo *userInfo = [[KSUserInfo alloc] init];
    userInfo.ID          = Id;
    userInfo.name        = [NSString stringWithFormat:@"saeipi_%d",userInfo.ID];
    return userInfo;
}

+ (KSUserInfo *)myself {
    KSUserInfo *userInfo = [[KSUserInfo alloc] init];
    userInfo.ID          = [self myID];
    userInfo.name        = [NSString stringWithFormat:@"saeipi_%d",userInfo.ID];
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
