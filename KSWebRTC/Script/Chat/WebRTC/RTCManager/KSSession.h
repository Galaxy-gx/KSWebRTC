//
//  KSSession.h
//  Telegraph
//
//  Created by saeipi on 2020/8/18.
//

#import <Foundation/Foundation.h>

@interface KSSession : NSObject

@property (nonatomic,assign) int      room;
@property (nonatomic,assign) BOOL     isCalled;//被叫
@property (nonatomic,copy  ) NSString *session_id;

@end
