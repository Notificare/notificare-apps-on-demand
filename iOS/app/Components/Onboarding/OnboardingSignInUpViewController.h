//
//  OnboardingSignInUpViewController.h
//
//  Created by Aernout Peeters on 15-09-2015.
//  Copyright (c) 2015 Notificare. All rights reserved.
//

#import "NotificareComponentViewController.h"

@interface OnboardingSignInUpViewController : NotificareComponentViewController

- (void)checkDeviceAndUser;

@property (nonatomic, copy) void (^completionBlock)(void);

@end
