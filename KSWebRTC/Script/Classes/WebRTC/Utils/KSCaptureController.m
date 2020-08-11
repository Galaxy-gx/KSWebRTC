//
//  KSCaptureController.m
//  KSWebRTC
//
//  Created by saeipi on 2020/7/21.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSCaptureController.h"
#import <WebRTC/RTCCameraVideoCapturer.h>
#import "ARDSettingsModel.h"

const Float64 kFramerateLimit = 30.0;

@interface KSCaptureController()
@property(nonatomic,strong)RTCCameraVideoCapturer *capturer;
@property(nonatomic,strong)ARDSettingsModel *settings;
@property(nonatomic,assign)BOOL usingFrontCamera;

@end
@implementation KSCaptureController

- (instancetype)initWithCapturer:(RTCCameraVideoCapturer *)capturer settings:(ARDSettingsModel *)settings {
    if (self = [super init]) {
        _capturer = capturer;
        _settings = settings;
        _usingFrontCamera = YES;
    }
    return self;
}

- (void)startCapture {
    AVCaptureDevicePosition position =  _usingFrontCamera ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    AVCaptureDevice *device = [self findDeviceForPosition:position];
    AVCaptureDeviceFormat *format = [self selectFormatForDevice:device];
    
    if (format == nil) {
        NSLog(@"No valid formats for device %@", device);
        NSAssert(NO, @"");
        return;
    }
    
    NSInteger fps = [self selectFpsForFormat:format];
    [_capturer startCaptureWithDevice:device format:format fps:fps];
}

- (void)stopCapture {
    [_capturer stopCapture];
}

- (void)switchCamera {
    _usingFrontCamera = !_usingFrontCamera;
    [self startCapture];
}

#pragma mark - Private

- (AVCaptureDevice *)findDeviceForPosition:(AVCaptureDevicePosition)position {
    NSArray<AVCaptureDevice *> *captureDevices = [RTCCameraVideoCapturer captureDevices];
    for (AVCaptureDevice *device in captureDevices) {
        if (device.position == position) {
            return device;
        }
    }
    return captureDevices[0];
}

- (AVCaptureDeviceFormat *)selectFormatForDevice:(AVCaptureDevice *)device {
    NSArray<AVCaptureDeviceFormat *> *formats =
    [RTCCameraVideoCapturer supportedFormatsForDevice:device];
    int targetWidth = [_settings currentVideoResolutionWidthFromStore];
    int targetHeight = [_settings currentVideoResolutionHeightFromStore];
    AVCaptureDeviceFormat *selectedFormat = nil;
    int currentDiff = INT_MAX;
    
    for (AVCaptureDeviceFormat *format in formats) {
        CMVideoDimensions dimension = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
        FourCharCode pixelFormat = CMFormatDescriptionGetMediaSubType(format.formatDescription);
        int diff = abs(targetWidth - dimension.width) + abs(targetHeight - dimension.height);
        if (diff < currentDiff) {
            selectedFormat = format;
            currentDiff = diff;
        } else if (diff == currentDiff && pixelFormat == [_capturer preferredOutputPixelFormat]) {
            selectedFormat = format;
        }
    }
    
    return selectedFormat;
}

- (NSInteger)selectFpsForFormat:(AVCaptureDeviceFormat *)format {
    Float64 maxSupportedFramerate = 0;
    for (AVFrameRateRange *fpsRange in format.videoSupportedFrameRateRanges) {
        maxSupportedFramerate = fmax(maxSupportedFramerate, fpsRange.maxFrameRate);
    }
    return fmin(maxSupportedFramerate, kFramerateLimit);
}

@end
