//
//  KSAlertController.m
//  Telegraph
//
//  Created by saeipi on 2020/9/2.
//

#import "KSAlertController.h"
#import "NSString+Category.h"
#import "UIViewController+Category.h"

@implementation KSAlertInfo
-(instancetype)initWithType:(KSAlertType)type title:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel confirml:(NSString *)confirml target:(UIViewController *)target {
    if (self = [super init]) {
        _popType  = type;
        _title    = title.localizde;
        _message  = message.localizde;
        _cancel   = cancel.localizde;
        _confirml = confirml.localizde;
        _target   = target;
        
    }
    return self;
}

@end

@implementation KSAlertController
/**
 提示语
 */
+(void)showInfo:(KSAlertInfo *)info callback:(void (^)(KSAlertType actionType))callback {
    
    if (info == nil || callback == nil) {
        return;
    }
    NSString *title               = info.title ? info.title : nil;
    NSString *message             = info.message ? info.message : nil;
    NSString *cancelButtonTitle   = info.cancel ? info.cancel : nil;
    NSString *confirmlButtonTitle = info.confirml ? info.confirml : nil;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    switch (info.popType) {
        case KSAlertTypeConfirml://只有确认
        {
            UIAlertAction *confirmlAction = [UIAlertAction actionWithTitle:confirmlButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                callback(KSAlertTypeConfirml);
            }];
            [alertController addAction:confirmlAction];
        }
            break;
        case KSAlertTypeCancel://只有取消
        {
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                callback(KSAlertTypeCancel);
            }];
            [alertController addAction:cancelAction];
        }
            break;
        case KSAlertTypeIntegrity://确认/取消
        {
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                callback(KSAlertTypeCancel);
            }];
            UIAlertAction *confirmlAction = [UIAlertAction actionWithTitle:confirmlButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                callback(KSAlertTypeConfirml);
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:confirmlAction];
        }
            break;
        default:
            break;
    }
    if (info.target != nil) {
        [info.target presentViewController:alertController animated:YES completion:nil];
    }
    else{
        [[UIViewController currentViewController] presentViewController:alertController animated:YES completion:nil];
    }
}

@end
