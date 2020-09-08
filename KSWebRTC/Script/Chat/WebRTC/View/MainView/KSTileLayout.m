//
//  KSTileLayout.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/2.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSTileLayout.h"

@implementation KSTileLayout

+ (KSTileLayout *)singleAudioLayout {
    KSTileLayout *tileLayout = [[KSTileLayout alloc] init];
    tileLayout.scale         = KSScaleMake(9, 16);
    tileLayout.mode          = KSContentModeScaleAspectFit;
    CGFloat width            = 99;
    CGFloat height           = width / tileLayout.scale.width * tileLayout.scale.height;
    tileLayout.layout        = KSLayoutMake(width, height, KS_Extern_Point10, KS_Extern_Point10);//KSLayoutMake(width, height, 0, 0);
    return tileLayout;
}

+ (KSTileLayout *)manyAudioLayout {
    KSTileLayout *tileLayout = [[KSTileLayout alloc] init];
    tileLayout.scale         = KSScaleMake(3, 4);
    tileLayout.mode          = KSContentModeScaleAspectFit;
    CGFloat width            = ([[UIScreen mainScreen]bounds].size.width - KS_Extern_Point10)/2;
    CGFloat height           = width / tileLayout.scale.width * tileLayout.scale.height;;
    tileLayout.layout        = KSLayoutMake(width, height, 0, 0);
    return tileLayout;
}

+ (KSTileLayout *)singleVideoLayout {
    KSTileLayout *tileLayout = [[KSTileLayout alloc] init];
    tileLayout.scale         = KSScaleMake(9, 16);
    tileLayout.mode          = KSContentModeScaleAspectFit;
    CGFloat width            = 96;
    CGFloat height           = width / tileLayout.scale.width * tileLayout.scale.height;
    tileLayout.layout        = KSLayoutMake(width, height, 0, 0);
    return tileLayout;
}

+ (KSTileLayout *)manyVideoLayout {
    KSTileLayout *tileLayout = [[KSTileLayout alloc] init];
    tileLayout.scale         = KSScaleMake(3, 4);
    tileLayout.mode          = KSContentModeScaleAspectFit;
    CGFloat width            = ([[UIScreen mainScreen]bounds].size.width - KS_Extern_Point10)/2;
    CGFloat height           = width / tileLayout.scale.width * tileLayout.scale.height;;
    tileLayout.layout        = KSLayoutMake(width, height, 0, 0);
    return tileLayout;
}

+ (KSTileLayout *)layoutWithCallType:(KSCallType)callType {
    KSTileLayout *tileLayout = nil;
    switch (callType) {
        case KSCallTypeSingleAudio:
            tileLayout = [KSTileLayout singleAudioLayout];
            break;
        case KSCallTypeManyAudio:
            tileLayout = [KSTileLayout manyAudioLayout];
            break;
        case KSCallTypeSingleVideo:
            tileLayout = [KSTileLayout singleVideoLayout];
            break;
        case KSCallTypeManyVideo:
            tileLayout = [KSTileLayout manyVideoLayout];
            break;
        default:
            break;
    }
    return tileLayout;
}

@end
