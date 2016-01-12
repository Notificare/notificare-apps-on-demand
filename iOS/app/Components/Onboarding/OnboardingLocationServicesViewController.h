//
//  OnboardingLocationServicesViewController.h
//
//  Created by Aernout Peeters on 30-09-2015.
//  Copyright © 2015 Notificare. All rights reserved.
//

#import "NotificareComponentViewController.h"

@interface OnboardingLocationServicesViewController : NotificareComponentViewController

@property (nonatomic, copy) void (^completionBlock)(void);

+ (BOOL)isComplete;

@end
