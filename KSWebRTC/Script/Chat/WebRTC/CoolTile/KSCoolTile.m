//
//  KSCoolTile.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/31.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSCoolTile.h"
#import "UIColor+Category.h"
@interface KSCoolTile()
@property (assign, nonatomic  ) UIWindowLevel maxSupportedWindowLevel;
@property (nonatomic, readonly) UIWindow      *frontWindow;
@property (nonatomic,assign   ) CGPoint       tilePoint;
@property (nonatomic,assign   ) CGFloat       offset;
@end

@implementation KSCoolTile

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initKit];
        self.offset = frame.origin.y;
    }
    return self;
}

- (void)callEnded {
    if (_isDisplay) {
        [self resetKit];
    }
}

- (void)initKit {
    [super initKit];
    
    _maxSupportedWindowLevel                    = UIWindowLevelNormal;
    
    UITapGestureRecognizer *tapGesturRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapGestureRecognizer:)];
     [self addGestureRecognizer:tapGesturRecognizer];

    UIPanGestureRecognizer *panSwipeGesture     = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanSwipeGesture:)];
    [self addGestureRecognizer:panSwipeGesture];
}

- (void)onTapGestureRecognizer:(UITapGestureRecognizer *)sender {
    [self resetKit];
    if ([self.delegate respondsToSelector:@selector(returnToCallInterfaceOfCoolTile:)]) {
        [self.delegate returnToCallInterfaceOfCoolTile:self];
    }
}

- (void)onPanSwipeGesture:(UIGestureRecognizer *)sender {
    UIView *tileView = sender.view;
    _tilePoint       = [sender locationInView:self.frontWindow];
    CGFloat screen_w = [UIScreen mainScreen].bounds.size.width;
    CGFloat screen_h = [UIScreen mainScreen].bounds.size.height;
    if(sender.state == UIGestureRecognizerStateChanged) {
        tileView.center = _tilePoint;
    }
    else if(sender.state == UIGestureRecognizerStateEnded) {
        CGFloat hpadding = 0;
        //CGFloat vpadding = 64;
        CGFloat x        = _tilePoint.x - tileView.frame.size.width/2;
        CGFloat y        = _tilePoint.y - tileView.frame.size.height/2;
        if (_tilePoint.x > screen_w/2) {
            x = screen_w - tileView.frame.size.width - hpadding;
        }
        else{
            x = hpadding;
        }
        
        if (_tilePoint.y > (screen_h - tileView.frame.size.height/2 - self.offset)) {
            y = screen_h - tileView.frame.size.height - self.offset;
        }
        
        if (y < self.offset) {
            y = self.offset;
        }
        //NSLog(@"-----x:%f, y:%f vx:%f, vy:%f----",x,y,tileView.frame.origin.x,tileView.frame.origin.y);
        [UIView animateWithDuration: 0.2 animations:^{
            tileView.frame = CGRectMake(x, y, tileView.frame.size.width, tileView.frame.size.height);
        }];
    }
}

- (UIWindow *)frontWindow {
#if !defined(SV_APP_EXTENSIONS)
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows) {
        BOOL windowOnMainScreen   = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible      = !window.hidden && window.alpha > 0;
        BOOL windowLevelSupported = (window.windowLevel >= UIWindowLevelNormal && window.windowLevel <= self.maxSupportedWindowLevel);

        if(windowOnMainScreen && windowIsVisible && windowLevelSupported) {
            return window;
        }
    }
#endif
    return nil;
}

- (void)updateViewHierarchy {
    if (self.superview == nil) {
        [self.frontWindow addSubview:self];
    }
}

- (void)resetKit {
    self.isDisplay  = NO;
    self.mediaTrack = nil;
    [self removeFromSuperview];
}

- (void)showMediaTrack:(KSMediaTrack *)mediaTrack {
    [self updateViewHierarchy];
    self.isDisplay  = YES;
    self.mediaTrack = mediaTrack;
    [self hiddenBar];
}

@end
