//
//  KSMember.h
//  KSWebRTC
//
//  Created by saeipi on 2020/7/12.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSMember : NSObject

@property(nonatomic,strong)NSNumber *ID;
@property(nonatomic,strong)NSNumber *feedId;
@property(nonatomic,copy)NSString *display;

@end
