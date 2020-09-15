//
//  KSUserInfo.h
//  Telegraph
//
//  Created by saeipi on 2020/8/28.
//

#import <Foundation/Foundation.h>
#import "KSCallState.h"
#import "KSConfigure.h"

@interface KSUserInfo : NSObject

@property (nonatomic,copy  ) NSString   *name;
@property (nonatomic,copy  ) NSString   *clientId;
@property (nonatomic,assign) long long  ID;
@property (nonatomic,assign) KSCallType callType;

+ (KSUserInfo *)userWithId:(long long)Id;
+ (KSUserInfo *)myself;
+ (long long)myID;

@end
