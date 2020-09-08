//
//  UIViewController+Category.m
//  Telegraph
//
//  Created by saeipi on 2020/8/22.
//

#import "UIViewController+Category.h"

@implementation UIViewController (Category)

- (UIViewController *)topController {
    UIViewController *resultVC;
    resultVC = [self toRootCtrlForCurrentCtrl:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self toRootCtrlForCurrentCtrl:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)toRootCtrlForCurrentCtrl:(UIViewController *)currentCtrl {
    if ([currentCtrl isKindOfClass:[UINavigationController class]]) {
        return [self toRootCtrlForCurrentCtrl:[(UINavigationController *)currentCtrl topViewController]];
    } else if ([currentCtrl isKindOfClass:[UITabBarController class]]) {
        return [self toRootCtrlForCurrentCtrl:[(UITabBarController *)currentCtrl selectedViewController]];
    } else {
        return currentCtrl;
    }
    return nil;
}

+ (UIViewController *)currentViewController {
    UIViewController *resultCtrl;
    resultCtrl = [UIViewController topViewController:[UIViewController getCurrentWindowCtrl]];
    while (resultCtrl.presentedViewController) {
        resultCtrl = [UIViewController topViewController:resultCtrl.presentedViewController];
    }
    return resultCtrl;
}

+ (UIViewController *)topViewController:(UIViewController *)ctrl {
    if ([ctrl isKindOfClass:[UINavigationController class]]) {
        return [UIViewController topViewController:[(UINavigationController *)ctrl topViewController]];
    } else if ([ctrl isKindOfClass:[UITabBarController class]]) {
        return [UIViewController topViewController:[(UITabBarController *)ctrl selectedViewController]];
    } else {
        return ctrl;
    }
    return nil;
}

+ (UIViewController *)getCurrentWindowCtrl {
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tempWindow in windows)
        {
            if (tempWindow.windowLevel == UIWindowLevelNormal) {
                window = tempWindow;
                break;
            }
        }
    }
    if([[window subviews] count] <= 0){
        return nil;
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        result = nextResponder;
    }
    else {
        result = window.rootViewController;
    }
    return  result;
}

@end
