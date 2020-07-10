//
//  KSVideoChatController.m
//  KSWebRTC
//
//  Created by saeipi on 2020/7/10.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSVideoChatController.h"
#import <WebRTC/WebRTC.h>
#import "UIButton+Category.h"
@interface KSVideoChatController ()
@property (nonatomic, weak) RTCCameraPreviewView *localView;
@property (nonatomic, weak) RTCEAGLVideoView *remoteView;

@end

@implementation KSVideoChatController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)createVideoLayer {
    CGFloat layerWidth              = 180;
    CGFloat layerHeight             = 320;
    CGFloat layerX                  = self.view.bounds.size.width - layerWidth - 10;
    CGFloat layerY                  = 64;
    RTCCameraPreviewView *localView = [[RTCCameraPreviewView alloc] initWithFrame:CGRectMake(layerX, layerY, layerWidth, layerHeight)];
    RTCEAGLVideoView *remoteView    = [[RTCEAGLVideoView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:remoteView];
    [self.view addSubview:localView];
    _localView                      = localView;
    _remoteView                     = remoteView;
    
    UIButton *connectBtn = [UIButton initWithTitle:@"连接"
                                        titleColor:[UIColor whiteColor]
                                              font:[UIFont systemFontOfSize:14]
                                   backgroundColor:[UIColor blueColor]
                                       borderColor:[UIColor blueColor]
                                       borderWidth:2];
    
    UIButton *leaveBtn = [UIButton initWithTitle:@"连接"
                                      titleColor:[UIColor whiteColor]
                                            font:[UIFont systemFontOfSize:14]
                                 backgroundColor:[UIColor blueColor]
                                     borderColor:[UIColor blueColor]
                                     borderWidth:2];
    
    [self.view addSubview:connectBtn];
    [self.view addSubview:leaveBtn];
    
    [connectBtn addTarget:self action:@selector(onConnectClick) forControlEvents:UIControlEventTouchUpInside];
    [leaveBtn addTarget:self action:@selector(onLeaveClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)onConnectClick {
    
}

- (void)onLeaveClick {
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
