//
//  KSMediaCapture.m
//  KSWebRTC
//
//  Created by saeipi on 2020/7/10.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSMediaCapture.h"

static NSString *const KARDMediaStreamId = @"ARDAMS";
static NSString *const KARDAudioTrackId = @"ARDAMSa0";
static NSString *const KARDVideoTrackId = @"ARDAMSv0";

@interface KSMediaCapture()
//当前使用的是前摄像头还是后摄像头
@property (nonatomic, assign) BOOL isFront;
@end

@implementation KSMediaCapture

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isFront = true;
    }
    return self;
}

- (void)createPeerConnectionFactory {
    RTCDefaultVideoDecoderFactory *decoderFactory = [[RTCDefaultVideoDecoderFactory alloc] init];
    RTCDefaultVideoEncoderFactory *encoderFactory = [[RTCDefaultVideoEncoderFactory alloc] init];
    NSArray *codes = [encoderFactory supportedCodecs];
    [encoderFactory setPreferredCodec:codes[2]];
    _factory = [[RTCPeerConnectionFactory alloc] initWithEncoderFactory:encoderFactory decoderFactory:decoderFactory];
}

- (void)captureLocalMedia:(RTCCameraPreviewView *)localView {
    NSDictionary *mandatoryConstraints = @{};
    RTCMediaConstraints *constrains = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints optionalConstraints:nil];
    RTCAudioSource *audioSource = [_factory audioSourceWithConstraints:constrains];
    _audioTrack = [_factory audioTrackWithSource:audioSource trackId:KARDAudioTrackId];

    AVCaptureDevice *device = [self currentCamera];
    if (!device) {
        return;
    }
    // 检测摄像头权限
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted ||
        authStatus == AVAuthorizationStatusDenied) {
        return;
    }
    
    RTCVideoSource *videoSource = [_factory videoSource];
    _capture = [[RTCCameraVideoCapturer alloc] initWithDelegate:videoSource];
    _videoTrack = [_factory videoTrackWithSource:videoSource trackId:KARDVideoTrackId];
    if ([_capture.captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        _capture.captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    }
    localView.captureSession = _capture.captureSession;
    [self startCaptureWithDevice:device];
}

- (void)switchCamera {
    _isFront = !_isFront;
    AVCaptureDevice *device = [self currentCamera];
    [self startCaptureWithDevice:device];
}

- (AVCaptureDevice *)currentCamera {
    NSArray<AVCaptureDevice *> *captureDevices = [RTCCameraVideoCapturer captureDevices];
    AVCaptureDevicePosition position = _isFront ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    AVCaptureDevice *device = NULL;
    for (AVCaptureDevice *obj in captureDevices) {
        if (obj.position == position) {
            device = obj;
            break;
        }
    }
    return device;
}

- (void)startCaptureWithDevice:(AVCaptureDevice *)device {
    if (!device) {
        return;
    }
    AVCaptureDeviceFormat *format = [[RTCCameraVideoCapturer supportedFormatsForDevice:device] lastObject];
    CGFloat fps = [[format videoSupportedFrameRateRanges] firstObject].maxFrameRate;
    [_capture startCaptureWithDevice:device format:format fps:fps];
}

@end
