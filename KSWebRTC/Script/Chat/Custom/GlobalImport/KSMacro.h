//
//  KSMacro.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/10.
//  Copyright © 2020 saeipi. All rights reserved.
//

#ifndef KSMacro_h
#define KSMacro_h

#define KSWeakSelf __weak typeof(self) weakSelf = self;

#ifdef DEBUG
#define KSLog( s, ... ) NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define KSLog( s, ... )
#endif

#endif /* KSMacro_h */
