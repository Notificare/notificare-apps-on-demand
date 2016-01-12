//
//  OnboardingUserPreferenceViewController.h
//  app
//
//  Created by Aernout Peeters on 12-01-2016.
//  Copyright © 2016 Notificare. All rights reserved.
//

#import "NotificareComponentViewController.h"

@interface OnboardingUserPreferenceViewController : NotificareComponentViewController

@property (strong, nonatomic, readonly) NotificareUserPreference *userPreference;
@property (nonatomic, copy) void (^completionBlock)(void);

- (instancetype)initWithUserPreference:(NotificareUserPreference *)userPreference;
- (instancetype)initWithConfiguration:(NSDictionary *)configuration andWithUserPreference:(NotificareUserPreference *)userPreference;

@end
