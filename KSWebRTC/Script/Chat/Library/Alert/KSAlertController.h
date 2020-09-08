//
//  KSAlertController.h
//  Telegraph
//
//  Created by saeipi on 2020/9/2.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, KSAlertType) {
    KSAlertTypeCancel    = 0,//取消
    KSAlertTypeConfirml  = 1,//确认
    KSAlertTypeIntegrity = 2,//确认/取消
};

@interface KSAlertInfo : NSObject
@property (nonatomic, assign) KSAlertType   popType;
@property (nonatomic, copy  ) NSString         *title;
@property (nonatomic, copy  ) NSString         *message;
@property (nonatomic, copy  ) NSString         *cancel;
@property (nonatomic, copy  ) NSString         *confirml;
@property (nonatomic, weak  ) UIViewController *target;

-(instancetype)initWithType:(KSAlertType)type title:(NSString *)title message:(NSString *)message cancel:(NSString *)cancel confirml:(NSString *)confirml target:(UIViewController *)target;
@end


@interface KSAlertController : NSObject

+(void)showInfo:(KSAlertInfo *)info callback:(void (^)(KSAlertType actionType))callback;

@end
