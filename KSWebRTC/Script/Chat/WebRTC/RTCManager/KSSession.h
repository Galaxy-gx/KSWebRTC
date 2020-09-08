//
//  KSSession.h
//  Telegraph
//
//  Created by saeipi on 2020/8/18.
//

#import <Foundation/Foundation.h>
#import "KSAckMessage.h"

@interface KSSession : NSObject

@property (nonatomic,assign) int       peerId;//被叫ID
@property (nonatomic,assign) BOOL      isCalled;//被叫
@property (nonatomic,copy  ) NSString  *session_id;
@property (nonatomic,copy  ) NSString  *room;

@end
