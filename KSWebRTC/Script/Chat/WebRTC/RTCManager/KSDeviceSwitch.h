//
//  KSDeviceSwitch.h
//  Telegraph
//
//  Created by saeipi on 2020/9/4.
//

#import <Foundation/Foundation.h>

@interface KSDeviceSwitch : NSObject

@property(nonatomic,assign)BOOL microphoneEnabled;//马克风
@property(nonatomic,assign)BOOL cameraEnabled;//相机
@property(nonatomic,assign)BOOL speakerEnabled;//扬声器

- (void)resetSwitch;

@end
