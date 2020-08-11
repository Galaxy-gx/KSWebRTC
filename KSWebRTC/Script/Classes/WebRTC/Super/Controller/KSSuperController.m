//
//  KSSuperController.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/8.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSSuperController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "KSNavigationBar.h"

@interface KSSuperController ()<UIGestureRecognizerDelegate>

@end

@implementation KSSuperController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor ks_colorWithHexString:@"#15161A"];
    
    if (_isSuperBar) {
        // 所有界面隐藏导航栏,用自定义的导航栏代替
        self.fd_prefersNavigationBarHidden = YES;
        [self createSuperBar];
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self displayAnimation];
}

-(void)displayAnimation {
    if (_displayFlag == KSDisplayFlagAnimatedFirst) {
        _displayFlag = KSDisplayFlagMore;
        self.view.alpha = 0;
        [UIView animateWithDuration:0.25f animations:^{
            self.view.alpha = 1;
        }];
    }
}
    
/// 如果executeArgs不为NULL则执行
- (void)executeTheExpectedInstruction {
    
}

- (void)createSuperBar {
    int screen_w                       = [UIScreen mainScreen].bounds.size.width;
    int screen_h                       = [UIScreen mainScreen].bounds.size.height;
    CGFloat status_h                   = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat nav_h                      = self.navigationController.navigationBar.frame.size.height;
    KSNavigationBar *superBar          = [[KSNavigationBar alloc] initWithFrame:CGRectMake(0, 0,  [UIScreen mainScreen].bounds.size.width, status_h + nav_h)];
    _superBar                          = superBar;
    [self.view addSubview:superBar];

    CGFloat container_y                = CGRectGetMaxY(superBar.frame);
    UIView              *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, container_y, screen_w, screen_h - container_y)];
    _containerView                     = containerView;
    [self.view addSubview:containerView];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        // 禁用返回手势
        //self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        // 视图完成显示添加手势代理
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        // 开启返回手势
        //self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        // 视图完成显示添加手势代理
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

#pragma mark - UIGestureRecognizerDelegate
// 手势代理方法
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    // 判断此手势是侧滑返回手势
    if (gestureRecognizer == self.navigationController.interactivePopGestureRecognizer) {
        if (self.navigationController.childViewControllers.count <= 1) {
            return NO;
        } else {
            return YES;
        }
        // return YES 有侧滑返回手势，return NO 无侧滑返回手
    }
    return YES;
}
*/

@end
