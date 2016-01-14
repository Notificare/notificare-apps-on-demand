//
//  OnboardingManager.h
//
//  Created by Aernout Peeters on 14-01-2016.
//  Copyright © 2016 Notificare. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, OnboardingStatus) {
    kOnboardingStatusMustCompleteSteps,
    kOnboardingStatusMustLogIn,
    kOnboardingStatusMustCompleteUserPrefs,
    kOnboardingStatusAllComplete
};

@interface OnboardingManager : NSObject

+ (instancetype)shared;
- (void)getStatus:(void (^)(OnboardingStatus status, NSDictionary *info))completionBlock;
- (void)show:(BOOL)animated;
- (void)hide:(BOOL)animated;
- (void)update;
- (void)activateAccount:(NSNotification *)notification;
- (void)resetPassword:(NSNotification *)notification;

@end
