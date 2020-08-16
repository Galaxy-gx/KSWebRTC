//
//  KSSuperController+Category.h
//  KSWebRTC
//
//  Created by saeipi on 2020/8/8.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSSuperController.h"

@interface KSSuperController (Category)

- (void)pop;
- (void)pushViewController:(KSSuperController *)ctrl;
- (void)pushViewCtrl:(KSSuperController *)ctrl;
- (void)popToRoot;
- (void)presentController:(KSSuperController *)ctrl;
- (void)presentCtrl:(KSSuperController *)ctrl;
- (void)dismiss;

@end
