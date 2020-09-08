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
@property (nonatomic,assign) int      ID;

+ (KSUserInfo *)userWithId:(int)Id;
+ (NSString *)nameWithId:(int)Id;
+ (KSUserInfo *)myself;
+ (int)myID;

@end
