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

//前置摄像头/后置摄像头
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

/*
 在 WebRTC Native 层，factory 可以说是 “万物的根源”，像 RTCVideoSource、RTCVideoTrack、RTCPeerConnection 这些类型的对象，都需要通过 factory 来创建。
 
 首先要调用 RTCPeerConnectionFactory 类的 initialize 方法进行初始化；
 然后创建 factory 对象。需要注意的是，在创建 factory 对象时，传入了两个参数：一个是默认的编码器；一个是默认的解码器。我们可以通过修改这两个参数来达到使用不同编解码器的目的。
 */
- (void)createPeerConnectionFactory {
    //设置SSL传输
    //[RTCPeerConnectionFactory initialize];
    
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
- (void)captureLocalMedia:(RTCCameraPreviewView *)localView {
    NSDictionary *mandatoryConstraints = @{};
    RTCMediaConstraints *constrains = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints optionalConstraints:nil];
    RTCAudioSource *audioSource = [_factory audioSourceWithConstraints:constrains];
    _audioTrack = [_factory audioTrackWithSource:audioSource trackId:KARDAudioTrackId];

    AVCaptureDevice *device = [self currentCamera];
    if (!device) {
        NSLog(@"获取相机失败");
        return;
    }
    // 检测摄像头权限
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
    _capture = [[RTCCameraVideoCapturer alloc] initWithDelegate:videoSource];
    _videoTrack = [_factory videoTrackWithSource:videoSource trackId:KARDVideoTrackId];
    if ([_capture.captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        _capture.captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    }
    
    //将采集到的视频展示出来
    localView.captureSession = _capture.captureSession;
    
    [self startCaptureWithDevice:device];
    //通过上面的几行代码就可以从摄像头捕获视频数据了。
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
