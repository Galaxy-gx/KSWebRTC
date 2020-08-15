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
    tileLayout.scale         = KSScaleMake(3, 4);
    tileLayout.mode          = KSContentModeScaleAspectFit;
    int width                = ([[UIScreen mainScreen]bounds].size.width - KS_Extern_Point10)/2;
    int height               = width / tileLayout.scale.width * tileLayout.scale.height;;
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
    tileLayout.scale         = KSScaleMake(3, 4);
    tileLayout.mode          = KSContentModeScaleAspectFit;
    int width                = ([[UIScreen mainScreen]bounds].size.width - KS_Extern_Point10)/2;
    int height               = width / tileLayout.scale.width * tileLayout.scale.height;;
    tileLayout.layout        = KSLayoutMake(width, height, 0, 0);
    tileLayout.callType      = KSCallTypeManyVideo;
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
