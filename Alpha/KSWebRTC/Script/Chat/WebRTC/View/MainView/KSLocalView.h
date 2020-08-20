//
//  KSLocalView.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/2.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSMediaView.h"

@interface KSLocalView : KSMediaView

@property (nonatomic,strong) KSTileLayout      *tileLayout;
@property (nonatomic,assign) BOOL              isDrag;

@end
