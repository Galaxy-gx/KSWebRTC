//
//  KSSuperController+Category.m
//  KSWebRTC
//
//  Created by saeipi on 2020/8/8.
//  Copyright © 2020 saeipi. All rights reserved.
//

#import "KSSuperController+Category.h"

@implementation KSSuperController (Category)

- (void)pop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pushViewController:(KSSuperController *)ctrl  {
    [self.navigationController pushViewController:ctrl animated:YES];
    if (ctrl.executeArgs) {
        [ctrl executeTheExpectedInstruction];
    }
}

- (void)pushViewCtrl:(KSSuperController *)ctrl {
    [self.navigationController pushViewController:ctrl animated:NO];
    if (ctrl.executeArgs) {
        [ctrl executeTheExpectedInstruction];
    }
}

- (void)popToRoot {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)presentController:(KSSuperController *)ctrl {
    ctrl.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:ctrl animated:YES completion:nil];
    if (ctrl.executeArgs) {
        [ctrl executeTheExpectedInstruction];
    }
}

- (void)presentCtrl:(KSSuperController *)ctrl {
    ctrl.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:ctrl animated:NO completion:nil];
    if (ctrl.executeArgs) {
        [ctrl executeTheExpectedInstruction];
    }
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
