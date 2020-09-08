//
//  UIViewController+Category.h
//  Telegraph
//
//  Created by saeipi on 2020/8/22.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Category)

- (UIViewController *)topController;
+ (UIViewController *)currentViewController;
@end
