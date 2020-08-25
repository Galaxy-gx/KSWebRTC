//
//  KSCallMenuController.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/24.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSCallMenuController.h"
#import "KSCallMenuView.h"
@interface KSCallMenuController ()
@property (nonatomic,weak   ) KSCallMenuView *menuView;
@property (nonatomic, weak  ) UIView         *colorView;
@end

@implementation KSCallMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *colorView            = [[UIView alloc] initWithFrame:self.view.bounds];
    colorView.backgroundColor    = [UIColor blackColor];
    colorView.alpha              = 0;
    _colorView                   = colorView;
    [self.view addSubview:colorView];
    
    KSCallMenuView *menuView     = [[KSCallMenuView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 166, self.view.bounds.size.width, 166)];
    _menuView                    = menuView;
    [self.view addSubview:menuView];
    
    UIBezierPath *maskPath       = [UIBezierPath bezierPathWithRoundedRect: menuView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(20,20)];
    CAShapeLayer *maskLayer      = [[CAShapeLayer alloc] init];
    maskLayer.frame              = menuView.bounds;
    maskLayer.path               = maskPath.CGPath;
    menuView.layer.mask          = maskLayer;
    
    __weak typeof(self) weakSelf = self;
    _menuView.callback           = ^(KSCallMenuType menuType) {
        [weakSelf callbackWithMenuType:menuType];
    };
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.1f animations:^{
        weakSelf.colorView.alpha = 0.05f;
        weakSelf.menuView.alpha  = 0.05f;
    } completion:^(BOOL finished) {
        [weakSelf dismissViewControllerAnimated:NO completion:^{
        }];
    }];
}

- (void)callbackWithMenuType:(KSCallMenuType)menuType{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.1f animations:^{
        weakSelf.colorView.alpha = 0.05f;
        weakSelf.menuView.alpha  = 0.05f;
    } completion:^(BOOL finished) {
        [weakSelf dismissViewControllerAnimated:NO completion:^{
            if (weakSelf.callback) {
                weakSelf.callback(menuType);
            }
        }];
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    __weak typeof(self) weakSelf = self;
    _menuView.alpha              = 0;
    [UIView animateWithDuration:0.1f animations:^{
        weakSelf.colorView.alpha = 0.5f;
        weakSelf.menuView.alpha  = 1;
    }];
}

+(void)enterCallMenuWithCallback:(KSCallMenuCallback)callback target:(UIViewController *)target {
    if (callback == nil) {
        return;
    }
    KSCallMenuController *ctrl                      = [[KSCallMenuController alloc] init];
    ctrl.providesPresentationContextTransitionStyle = YES;
    ctrl.definesPresentationContext                 = YES;
    [ctrl setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    ctrl.callback                                   = callback;
    [target presentViewController:ctrl animated:NO completion:nil];
}

@end
