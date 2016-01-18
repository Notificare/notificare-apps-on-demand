//
//  OnboardingManager.h
//
//  Created by Aernout Peeters on 14-01-2016.
//  Copyright © 2016 Notificare. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, OnboardingStatus) {
    kOnboardingStatusUnknown,
    kOnboardingStatusMustCompleteSteps,
    kOnboardingStatusMustLogIn,
    kOnboardingStatusMustCompleteUserPrefs,
    kOnboardingStatusAllComplete
};


@class OnboardingManager;


@protocol OnboardingManagerDelegate <NSObject>

@optional

- (void)onboardingWillShow:(OnboardingManager *)onboardingManager;
- (void)onboardingDidShow:(OnboardingManager *)onboardingManager;
- (void)onboardingWillHide:(OnboardingManager *)onboardingManager;
- (void)onboardingDidHide:(OnboardingManager *)onboardingManager;
- (void)onboardingManager:(OnboardingManager *)onboardingManager didUpdateStatus:(OnboardingStatus)status;

@end

@interface OnboardingManager : NSObject

@property (strong, nonatomic) id<OnboardingManagerDelegate> delegate;
@property (nonatomic, readonly) OnboardingStatus status;
@property (nonatomic) BOOL deviceIsRegistered;
@property (nonatomic, readonly) BOOL completedNotifications;
@property (nonatomic, readonly) BOOL completedLocationServices;
@property (nonatomic) BOOL visible;

+ (instancetype)shared;
- (void)getStatus:(void (^)(OnboardingStatus status, NSDictionary *info))completionBlock;
- (void)setVisible:(BOOL)visible animated:(BOOL)animated;
- (void)update;
- (void)activateAccount:(NSNotification *)notification;
- (void)resetPassword:(NSNotification *)notification;

@end
