//
//  KSMediaCapturer.m
//  KSWebRTC
//
//  Created by saeipi on 2020/7/10.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSMediaCapturer.h"

static NSString *const KARDMediaStreamId = @"ARDAMS";
static NSString *const KARDAudioTrackId  = @"ARDAMSa0";
static NSString *const KARDVideoTrackId  = @"ARDAMSv0";
static int const kFramerateLimit         = 25.0;

@interface KSMediaCapturer()
@property (nonatomic,weak  ) RTCAudioSession            *rtcAudioSession;
@property (nonatomic,assign,readonly) KSCallType        myType;
@end

@implementation KSMediaCapturer

- (instancetype)initWithSetting:(KSCapturerSetting *)setting {
    if(self = [super init]) {
        _setting         = setting;
        [self createPeerConnectionFactory];
        [self initAudioSession];
    }
    return self;
}

- (void)initAudioSession {
    _rtcAudioSession = [RTCAudioSession sharedInstance];
    [_rtcAudioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    [self resetAudioSessionPort];
}

- (void)createPeerConnectionFactory {
    if (_setting.isSSL) {
        //设置SSL传输
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [RTCPeerConnectionFactory initialize];
        });
    }
    RTCDefaultVideoEncoderFactory *encoderFactory = [[RTCDefaultVideoEncoderFactory alloc] init];
    RTCDefaultVideoDecoderFactory *decoderFactory = [[RTCDefaultVideoDecoderFactory alloc] init];
    /*
    NSDictionary<NSString *, NSString *> *constrainedHighParams = @{
        @"profile-level-id" : kRTCMaxSupportedH264ProfileLevelConstrainedHigh,
        @"level-asymmetry-allowed" : @"1",
        @"packetization-mode" : @"1",
    };
    RTCVideoCodecInfo *constrainedHighInfo = [[RTCVideoCodecInfo alloc] initWithName:kRTCVideoCodecH264Name parameters:constrainedHighParams];
    encoderFactory.preferredCodec = constrainedHighInfo;
     */
    //NSArray *codes = [encoderFactory supportedCodecs];
    //[encoderFactory setPreferredCodec:codes[2]];
    _factory = [[RTCPeerConnectionFactory alloc] initWithEncoderFactory:encoderFactory decoderFactory:decoderFactory];
}

- (void)addMediaSource {
    [self addAudioSource];
    [self addVideoSource];
}

- (void)addAudioSource {
    if (_audioTrack) {
        _audioTrack = nil;
    }
    // 检测权限
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (authStatus == AVAuthorizationStatusRestricted ||
        authStatus == AVAuthorizationStatusDenied) {
        NSLog(@"麦克风访问受限");
        if (_setting.authCallback) {
            _setting.authCallback(KSDeviceTypeMicrophone,authStatus);
        }
        return;
    }
    NSDictionary *mandatoryConstraints = @{};
    RTCMediaConstraints *constrains    = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints optionalConstraints:nil];
    RTCAudioSource *audioSource        = [_factory audioSourceWithConstraints:constrains];
    _audioTrack                        = [_factory audioTrackWithSource:audioSource trackId:KARDAudioTrackId];
}

- (void)addVideoSource {
    if (self.myType == KSCallTypeManyAudio || self.myType == KSCallTypeSingleAudio) {
        return;
    }
    
    if (_videoTrack) {
        _videoTrack = nil;
    }
    AVCaptureDevice *device          = [self currentCamera];
    if (!device) {
        NSLog(@"获取相机失败");
        return;
    }
    // 检测权限
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted ||
        authStatus == AVAuthorizationStatusDenied) {
        NSLog(@"相机访问受限");
        if (_setting.authCallback) {
            _setting.authCallback(KSDeviceTypeCamera,authStatus);
        }
        return;
    }
    /*
     首先将 RTCVideoSource 与 RTCCameraVideoCapture 进行绑定，然后再开启设备，这样视频数据就源源不断的被采集到 RTCVideoSource 中了。
     */
    RTCVideoSource *videoSource = [_factory videoSource];
    _capturer                   = [[RTCCameraVideoCapturer alloc] initWithDelegate:videoSource];
    _videoTrack                 = [_factory videoTrackWithSource:videoSource trackId:KARDVideoTrackId];
    _setting.videoEnabled       = YES;
    NSLog(@"|============| videoTrack.trackId : %@|============|",_videoTrack.trackId);
    [self videoMirored];
}

/*
- (void)updateResolution:(CGSize)resolution {
    _setting.resolution = resolution;
    [self startCapture];
}
*/

//解决前置摄像头录制视频左右颠倒问题
- (void)videoMirored {
    AVCaptureSession* session = self.capturer.captureSession;
    for (AVCaptureVideoDataOutput* output in session.outputs) {
        for (AVCaptureConnection * connection in output.connections) {
            if (_setting.isFront) {
                if (connection.supportsVideoMirroring) {
                    connection.videoMirrored = YES;
                    return;
                }
            }
        }
    }
}

- (void)muteAudio {
    NSLog(@"audio muted");
    _audioTrack.isEnabled = NO;
}

- (void)unmuteAudio {
    NSLog(@"audio unmuted");
    _audioTrack.isEnabled = YES;
}

#pragma mark - Video mute/unmute
- (void)muteVideo {
    NSLog(@"video muted");
    _videoTrack.isEnabled = NO;
}
- (void)unmuteVideo {
    NSLog(@"video unmuted");
    _videoTrack.isEnabled = YES;
}

- (void)changeOutputAudioPort:(AVAudioSessionPortOverride)portOverride {
    __weak typeof(self) weakSelf = self;
    [RTCDispatcher dispatchAsyncOnType:RTCDispatcherTypeAudioSession block:^{
        [weakSelf.rtcAudioSession lockForConfiguration];
        [weakSelf.rtcAudioSession overrideOutputAudioPort:portOverride error:nil];
        [weakSelf.rtcAudioSession unlockForConfiguration];
    }];
}

- (AVAudioSessionMode)audioSessionMode {
    if (self.myType == KSCallTypeManyVideo || self.myType == KSCallTypeSingleVideo) {
        return AVAudioSessionModeVideoChat;//视频通话
    }
    return AVAudioSessionModeVoiceChat;//VoIP
}

//关闭扬声器至默认播放设备
- (void)speakerOff {
    [self changeOutputAudioPort:AVAudioSessionPortOverrideNone];
}

//开启扬声器
- (void)speakerOn {
    [self changeOutputAudioPort:AVAudioSessionPortOverrideSpeaker];
}

- (void)resetAudioSessionPort {
    [self speakerOn];
}

- (void)switchTalkMode {
    _setting.isStartCapture = !_setting.isStartCapture;
    if (_setting.isStartCapture) {
        [self startCapture];
    }
    else{
        [self stopCapture];
    }
}

- (void)switchCamera {
    _setting.isFront = !_setting.isFront;
    [self startCapture];
}

- (void)startCapture {
    if (self.myType == KSCallTypeSingleAudio || self.myType == KSCallTypeManyAudio) {
        return;
    }
    AVCaptureDevice *device = [self currentCamera];
    [self startCaptureWithDevice:device];
}

- (void)stopCapture {
    [_capturer stopCapture];
}

- (void)closeCapturer {
    _videoTrack = nil;
    _audioTrack = nil;
    
    [_factory stopAecDump];
    _factory    = nil;
    
    [_capturer.captureSession stopRunning];
    [_capturer stopCapture];
    
    _capturer   = nil;
    _setting    = nil;
}

- (void)startCaptureWithDevice:(AVCaptureDevice *)device {
    AVCaptureDeviceFormat *format    = [self selectFormatForDevice:device];
    if (format == nil) {
        NSLog(@"No valid formats for device %@", device);
        return;
    }
    NSInteger fps                    = [self selectFpsForFormat:format];
    [_capturer startCaptureWithDevice:device format:format fps:fps];
}

#pragma mark - Private
- (AVCaptureDevice *)currentCamera {
    AVCaptureDevicePosition position = _setting.isFront ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    NSArray<AVCaptureDevice *> *captureDevices = [RTCCameraVideoCapturer captureDevices];
    for (AVCaptureDevice *device in captureDevices) {
        if (device.position == position) {
            return device;
        }
    }
    return captureDevices.firstObject;
}

- (AVCaptureDeviceFormat *)selectFormatForDevice:(AVCaptureDevice *)device {
    NSArray<AVCaptureDeviceFormat *> *formats = [RTCCameraVideoCapturer supportedFormatsForDevice:device];
    AVCaptureDeviceFormat *selectedFormat     = nil;
    KSScale scale                             = KSScaleMake(9, 16);
    if ([self.delegate respondsToSelector:@selector(scaleOfMediaCapturer:)]) {
        scale = [self.delegate scaleOfMediaCapturer:self];
    }
    for (AVCaptureDeviceFormat *format in formats) {
        CMVideoDimensions dimension = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
        //FourCharCode pixelFormat = CMFormatDescriptionGetMediaSubType(format.formatDescription);
        if (dimension.width/scale.height*scale.width == dimension.height) {
            NSLog(@"|------------| dimension.width : %d, dimension.height : %d |------------|",dimension.width,dimension.height);
            selectedFormat = format;
            break;
        }
    }
    return selectedFormat;
}

- (NSInteger)selectFpsForFormat:(AVCaptureDeviceFormat *)format {
    NSInteger maxSupportedFramerate = 0;
    for (AVFrameRateRange *fpsRange in format.videoSupportedFrameRateRanges) {
        maxSupportedFramerate = (NSInteger)fmax(maxSupportedFramerate, fpsRange.maxFrameRate);
    }
    return (NSInteger)fmin(maxSupportedFramerate, kFramerateLimit);
}

#pragma mark - Get
-(KSCallType)myType {
    if ([self.delegate respondsToSelector:@selector(callTypeOfMediaCapturer:)]) {
        return [self.delegate callTypeOfMediaCapturer:self];
    }
    return KSCallTypeSingleVideo;
}
-(void)setMyType:(KSCallType)myType {
}

@end
