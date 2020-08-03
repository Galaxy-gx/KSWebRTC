//
//  KSVideoLayout.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/2.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSConfigure.h"
struct KSLayout {
    CGFloat width;
    CGFloat height;
    CGFloat hpadding;//横向间距
    CGFloat vpadding;//纵向间距
};
typedef struct KSLayout KSLayout;

CG_INLINE KSLayout KSLayoutMake(CGFloat width, CGFloat height, CGFloat hpadding, CGFloat vpadding);
CG_INLINE KSLayout
KSLayoutMake(CGFloat width, CGFloat height, CGFloat hpadding, CGFloat vpadding)
{
  KSLayout l; l.width = width; l.height = height; l.hpadding = hpadding; l.vpadding = vpadding; return l;
}

@interface KSVideoLayout : NSObject

@property(nonatomic,assign)KSLayout layout;
@property(nonatomic,assign)KSScale scale;

@end
