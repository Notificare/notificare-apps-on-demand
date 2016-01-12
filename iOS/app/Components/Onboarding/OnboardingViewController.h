//
//  OnboardingViewController.h
//
//  Created by Aernout Peeters on 30-09-2015.
//  Copyright © 2015 Notificare. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, OnboardingStatus) {
    kOnboardingStatusMustCompleteSteps,
    kOnboardingStatusMustLogIn,
    kOnboardingStatusMustCompleteUserPrefs,
    kOnboardingStatusAllComplete
};

@interface OnboardingViewController : UINavigationController

+ (BOOL)isComplete;
- (void)present:(BOOL)animated;

@end
