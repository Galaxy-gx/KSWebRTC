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
    userInfo.ID          = 10101024;
    return userInfo;
}

+ (int)myID {
    return 10101024;
}

@end
