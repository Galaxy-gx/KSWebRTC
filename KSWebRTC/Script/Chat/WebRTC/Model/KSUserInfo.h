//
//  KSUserInfo.h
//  Telegraph
//
//  Created by saeipi on 2020/8/28.
//

#import <Foundation/Foundation.h>
#import "KSCallState.h"
@interface KSUserInfo : NSObject

@property (nonatomic,copy  ) NSString *name;
@property (nonatomic,assign) long long  ID;

+ (KSUserInfo *)userWithId:(long long)Id;
+ (KSUserInfo *)myself;
+ (long long)myID;

@end
