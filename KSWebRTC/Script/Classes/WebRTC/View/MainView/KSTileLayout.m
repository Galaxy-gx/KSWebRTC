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
    int width                = 96;
    int height               = width / tileLayout.scale.width * tileLayout.scale.height;
    tileLayout.layout        = KSLayoutMake(width, height, 0, 0);
    tileLayout.callType      = KSCallTypeSingleAudio;
    return tileLayout;
}

+ (KSTileLayout *)manyAudioLayout {
    KSTileLayout *tileLayout = [[KSTileLayout alloc] init];
    tileLayout.scale         = KSScaleMake(1, 1);
    tileLayout.mode          = KSContentModeScaleAspectFit;
    int width                = ([[UIScreen mainScreen]bounds].size.width - KS_Extern_Point10)/2;
    int height               = width;
    tileLayout.layout        = KSLayoutMake(width, height, 0, 0);
    tileLayout.callType      = KSCallTypeManyAudio;
    return tileLayout;
}

+ (KSTileLayout *)singleVideoLayout {
    KSTileLayout *tileLayout = [[KSTileLayout alloc] init];
    tileLayout.scale         = KSScaleMake(9, 16);
    tileLayout.mode          = KSContentModeScaleAspectFit;
    int width                = 96;
    int height               = width / tileLayout.scale.width * tileLayout.scale.height;
    tileLayout.layout        = KSLayoutMake(width, height, 0, 0);
    tileLayout.callType      = KSCallTypeSingleVideo;
    return tileLayout;
}

+ (KSTileLayout *)manyVideoLayout {
    KSTileLayout *tileLayout = [[KSTileLayout alloc] init];
    tileLayout.scale         = KSScaleMake(1, 1);
    tileLayout.mode          = KSContentModeScaleAspectFit;
    int width                = ([[UIScreen mainScreen]bounds].size.width - KS_Extern_Point10)/2;
    int height               = width;
    tileLayout.layout        = KSLayoutMake(width, height, 0, 0);
    tileLayout.callType      = KSCallTypeManyVideo;
    return tileLayout;
}

@end
