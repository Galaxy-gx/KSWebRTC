//
//  KSMediaCapturer.m
//  KSWebRTC
//
//  Created by saeipi on 2020/7/10.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSMediaCapturer.h"

@implementation KSCapturerSetting
@end

static NSString *const KARDMediaStreamId = @"ARDAMS";
static NSString *const KARDAudioTrackId  = @"ARDAMSa0";
static NSString *const KARDVideoTrackId  = @"ARDAMSv0";
static int const kFramerateLimit         = 25.0;

@interface KSMediaCapturer()
@property(nonatomic,weak)RTCAudioSession *rtcAudioSession;
@end
@implementation KSMediaCapturer

-(instancetype)initWithSetting:(KSCapturerSetting *)setting {
    if (self = [super init]) {
        _setting         = setting;

        [self createPeerConnectionFactory];
        [self addMediaSource];

        _rtcAudioSession = [RTCAudioSession sharedInstance];
        [self configureAudioSession];
    }
    return self;
}

/*
 在 WebRTC Native 层，factory 可以说是 “万物的根源”，像 RTCVideoSource、RTCVideoTrack、RTCPeerConnection 这些类型的对象，都需要通过 factory 来创建。
 
 首先要调用 RTCPeerConnectionFactory 类的 initialize 方法进行初始化；
 然后创建 factory 对象。需要注意的是，在创建 factory 对象时，传入了两个参数：一个是默认的编码器；一个是默认的解码器。我们可以通过修改这两个参数来达到使用不同编解码器的目的。
 */
- (void)createPeerConnectionFactory {
    if (_setting.isSSL) {
        //设置SSL传输
        [RTCPeerConnectionFactory initialize];
    }
    RTCDefaultVideoDecoderFactory *decoderFactory = [[RTCDefaultVideoDecoderFactory alloc] init];
    RTCDefaultVideoEncoderFactory *encoderFactory = [[RTCDefaultVideoEncoderFactory alloc] init];
    NSArray *codes = [encoderFactory supportedCodecs];
    [encoderFactory setPreferredCodec:codes[2]];
    _factory = [[RTCPeerConnectionFactory alloc] initWithEncoderFactory:encoderFactory decoderFactory:decoderFactory];
}

/*
 WebRTC 为我们提供了一个专门的类，即 RTCVideoSource。它有两层含义：

 一是表明它是一个视频源。当我们要展示视频的时候，就从这里获取数据；
 另一方面，它也是一个终点。即，当我们从视频设备采集到视频数据时，要交给它暂存起来。
 
 除此之外，为了能更方便的控制视频设备，WebRTC 提供了一个专门用于操作设备的类，即 RTCCameraVideoCapture。通过它，我们就可以自如的控制视频设备了。
 */

- (void)addMediaSource {
    [self addAudioSource];
    if (_setting.callType == KSCallTypeManyVideo || _setting.callType == KSCallTypeSingleVideo) {
        [self addVideoSourceOfCallType:_setting.callType];
    }
}

- (void)addAudioSource {
    if (_audioTrack) {
        return;
    }
    // 检测权限
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (authStatus == AVAuthorizationStatusRestricted ||
        authStatus == AVAuthorizationStatusDenied) {
        NSLog(@"麦克风访问受限");
        return;
    }
    
    NSDictionary *mandatoryConstraints = @{};
    RTCMediaConstraints *constrains    = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints optionalConstraints:nil];
    RTCAudioSource *audioSource        = [_factory audioSourceWithConstraints:constrains];
    _audioTrack                        = [_factory audioTrackWithSource:audioSource trackId:KARDAudioTrackId];
}

- (void)addVideoSourceOfCallType:(KSCallType)callType {
    _setting.callType                = callType;
    if (_videoTrack) {
        return;
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
        return;
    }
    /*
     首先将 RTCVideoSource 与 RTCCameraVideoCapture 进行绑定，然后再开启设备，这样视频数据就源源不断的被采集到 RTCVideoSource 中了。
     */
    RTCVideoSource *videoSource = [_factory videoSource];
    _capturer                   = [[RTCCameraVideoCapturer alloc] initWithDelegate:videoSource];
    _videoTrack                 = [_factory videoTrackWithSource:videoSource trackId:KARDVideoTrackId];
    if ([_capturer.captureSession canSetSessionPreset:AVCaptureSessionPresetiFrame960x540]) {
        _capturer.captureSession.sessionPreset = AVCaptureSessionPresetiFrame960x540;
    }
    [self startCaptureWithDevice:device];
}

- (void)configureAudioSession {
    [_rtcAudioSession lockForConfiguration];
    @try {
        NSError *error = nil;
        [_rtcAudioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
        [_rtcAudioSession setMode:AVAudioSessionModeVoiceChat error:&error];
    } @catch (NSException *exception) {
        NSLog(@"Error setting AVAudioSession category %@",exception);
    } @finally {
    }
    [_rtcAudioSession unlockForConfiguration];
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

//关闭扬声器至默认播放设备：耳机/蓝牙/入耳式扬声器
- (void)speakerOff {
    [_rtcAudioSession lockForConfiguration];
    @try {
        NSError *error = nil;
        [_rtcAudioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
        [_rtcAudioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
    } @catch (NSException *exception) {
        NSLog(@"Error setting AVAudioSession category %@",exception);
    } @finally {
    }
    [_rtcAudioSession unlockForConfiguration];
}

//开启扬声器
- (void)speakerOn {
    [_rtcAudioSession lockForConfiguration];
    @try {
        NSError *error = nil;
        [_rtcAudioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
        [_rtcAudioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        if (error == nil) {
            [_rtcAudioSession setActive:YES error:&error];
        }
    } @catch (NSException *exception) {
        NSLog(@"Couldn't force audio to speaker: %@",exception);
    } @finally {
    }
    [_rtcAudioSession unlockForConfiguration];
}

- (void)switchCamera {
    _setting.isFront = !_setting.isFront;
    [self startCapture];
}

- (void)stopCapture {
    [_capturer stopCapture];
}

- (void)startCapture {
    AVCaptureDevice *device = [self currentCamera];
    [self startCaptureWithDevice:device];
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
    return captureDevices[0];
}

- (AVCaptureDeviceFormat *)selectFormatForDevice:(AVCaptureDevice *)device {
    NSArray<AVCaptureDeviceFormat *> *formats = [RTCCameraVideoCapturer supportedFormatsForDevice:device];
    int targetWidth                           = _setting.resolution.width;//540
    int targetHeight                          = _setting.resolution.height;//960
    AVCaptureDeviceFormat *selectedFormat     = nil;
    int currentDiff                           = INT_MAX;
    
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
    int maxSupportedFramerate = 0;
    for (AVFrameRateRange *fpsRange in format.videoSupportedFrameRateRanges) {
        maxSupportedFramerate = fmax(maxSupportedFramerate, fpsRange.maxFrameRate);
    }
    return fmin(maxSupportedFramerate, kFramerateLimit);
}

- (void)close {
    _videoTrack = nil;
    _audioTrack = nil;
    
    [_factory stopAecDump];
    _factory    = nil;
    
    [_capturer stopCapture];
    [_capturer.captureSession stopRunning];
    _capturer   = nil;
    
    _setting    = nil;
}

@end
