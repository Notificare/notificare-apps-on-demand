//
//  OnboardingManager.m
//
//  Created by Aernout Peeters on 14-01-2016.
//  Copyright © 2016 Notificare. All rights reserved.
//

#import "OnboardingManager.h"

#import "OnboardingWelcomeViewController.h"
#import "OnboardingNotificationsViewController.h"
#import "OnboardingLocationServicesViewController.h"
#import "OnboardingSignInUpViewController.h"
#import "OnboardingUserPreferenceViewController.h"
#import "SignInViewController.h"
#import "ResetPassViewController.h"
#import "Configuration.h"
#import "AppDelegate.h"


@interface OnboardingManager ()

@property (strong, nonatomic) UINavigationController *navigationController;
@property (nonatomic, readonly) UIViewController *windowRootVC;

@end


@implementation OnboardingManager

- (UIViewController *)windowRootVC {
    return  [[(AppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController];
}

+ (instancetype)shared {
    static OnboardingManager *shared = nil;
    
    if (shared == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            shared = [[self alloc] initPrivate];
        });
    }
    
    return shared;
}

- (instancetype)init {
    [NSException raise:@"Singleton" format:@"Use +[OnboardingManager shared]"];
    
    return nil;
}

- (instancetype)initPrivate {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

- (void)getStatus:(void (^)(OnboardingStatus status, NSDictionary *info))completionBlock {
    NSDictionary *appSettings = [[Configuration shared] getDictionary:@"appSettings"];
    
    for (NSString *step in appSettings[@"onboardingSteps"]) {
        
        if (([step isEqualToString:@"welcome"] && ![OnboardingWelcomeViewController isComplete]) ||
            ([step isEqualToString:@"notifications"] && ![OnboardingNotificationsViewController isComplete]) ||
            ([step isEqualToString:@"locationServices"] && ![OnboardingLocationServicesViewController isComplete])) {
            
            completionBlock(kOnboardingStatusMustCompleteSteps, @{@"step": step});
            return;
        }
    }
    
    if ([appSettings[@"userMustBeLoggedIn"] boolValue]) {
        if (![[NotificarePushLib shared] isLoggedIn]) {
            completionBlock(kOnboardingStatusMustLogIn, nil);
            return;
        }
    }
    else {
        completionBlock(kOnboardingStatusAllComplete, nil);
        return;
    }
    
    if ([appSettings[@"userMustCompletePreferences"] boolValue]) {
        
        [[NotificarePushLib shared] fetchUserPreferences:^(NSArray *preferences) {
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            for (NotificareUserPreference *preference in preferences) {
                NSString *key = [NSString stringWithFormat:@"onboardingUserPreference(%@)", preference.preferenceId];
                
                BOOL preferenceComplete = [defaults boolForKey:key];
                
                if ([preference.preferenceType isEqualToString:@"choice"]) {
                    BOOL aSegmentSelected = NO;
                    
                    for (NotificareSegment *segment in preference.preferenceOptions) {
                        if (segment.selected) {
                            aSegmentSelected = YES;
                            break;
                        }
                    }
                    
                    preferenceComplete &= aSegmentSelected;
                }
                
                if (!preferenceComplete) {
                    completionBlock(kOnboardingStatusMustCompleteUserPrefs, @{@"userPreference": preference});
                    return;
                }
            }
            
        } errorHandler:^(NSError *error) {
            NSLog(@"Failed to Fetch User Preferences:\n%@", error);
            // Maybe show an alert here?
        }];
    }
    else {
        completionBlock(kOnboardingStatusAllComplete, nil);
        return;
    }
}

- (void)show:(BOOL)animated {
    if (!self.navigationController) {
        self.navigationController = [[UINavigationController alloc] init];
    }
    
    [self update];
    
    if (self.windowRootVC.presentedViewController) {
        if (self.windowRootVC.presentedViewController == self.navigationController) {
            // No need to show it again
        }
        else {
            [self.windowRootVC.presentedViewController dismissViewControllerAnimated:animated completion:^{
                [self.windowRootVC presentViewController:self.navigationController animated:animated completion:NULL];
            }];
        }
    }
    else {
        [self.windowRootVC presentViewController:self.navigationController animated:animated completion:NULL];
    }
}

- (void)hide:(BOOL)animated {
    if (self.navigationController) {
        if (self.navigationController == self.windowRootVC.presentedViewController) {
            [self.navigationController dismissViewControllerAnimated:animated completion:^{
                self.navigationController = nil;
            }];
        }
        else {
            self.navigationController = nil;
        }
    }
    else {
        NSLog(@"There is no Onboarding Navigation Controller to hide.");
    }
}

- (void)update {
    if (!self.navigationController) {
        return;
    }
    
    BOOL animated = self.navigationController.viewControllers.count != 0;
    
    [self getStatus:^(OnboardingStatus status, NSDictionary *info) {
        
        switch (status) {
            case kOnboardingStatusMustCompleteSteps:
                [self pushStep:info[@"step"] withAnimated:animated];
                break;
                
            case kOnboardingStatusMustLogIn: {
                OnboardingSignInUpViewController *onboardingSignInUpVC = [[OnboardingSignInUpViewController alloc] init];
                onboardingSignInUpVC.completionBlock = ^{
                    [self update];
                };
                [self.navigationController pushViewController:onboardingSignInUpVC animated:animated];
                
                break;
            }
                
            case kOnboardingStatusMustCompleteUserPrefs: {
                OnboardingUserPreferenceViewController *onboardingUserPreferenceVC = [[OnboardingUserPreferenceViewController alloc] initWithUserPreference:info[@"userPreference"]];
                [self.navigationController pushViewController:onboardingUserPreferenceVC animated:animated];
                break;
            }
                
            case kOnboardingStatusAllComplete:
                // Should dismiss itself?
                break;
                
            default:
                break;
        }
        
    }];
    
}

- (void)pushStep:(NSString *)step withAnimated:(BOOL)animated {
    if ([step isEqualToString:@"welcome"]) {
        
        OnboardingWelcomeViewController *onboardingWelcomeVC = [[OnboardingWelcomeViewController alloc] init];
        onboardingWelcomeVC.completionBlock = ^{
            [self update];
        };
        [self.navigationController pushViewController:onboardingWelcomeVC animated:animated];
    }
    else if ([step isEqualToString:@"notifications"]) {
        
        OnboardingNotificationsViewController *onboardingNotificationsVC = [[OnboardingNotificationsViewController alloc] init];
        onboardingNotificationsVC.completionBlock = ^{
            [self update];
        };
        [self.navigationController pushViewController:onboardingNotificationsVC animated:animated];
    }
    else if ([step isEqualToString:@"locationServices"]) {
        
        OnboardingLocationServicesViewController *onboardingLocationServicesVC = [[OnboardingLocationServicesViewController alloc] init];
        onboardingLocationServicesVC.completionBlock = ^{
            [self update];
        };
        [self.navigationController pushViewController:onboardingLocationServicesVC animated:animated];
    }
}

- (void)activateAccount:(NSNotification *)notification {
    OnboardingSignInUpViewController *onboardingSignInUpVC = [[OnboardingSignInUpViewController alloc] init];
    SignInViewController *signInVC = [[SignInViewController alloc] init];
    
    self.navigationController.viewControllers = @[onboardingSignInUpVC];
    
    [self.navigationController pushViewController:signInVC animated:YES];
}

- (void)resetPassword:(NSNotification *)notification {
    OnboardingSignInUpViewController *onboardingSignInUpVC = [[OnboardingSignInUpViewController alloc] init];
    SignInViewController *signInVC = [[SignInViewController alloc] init];
    ResetPassViewController *resetPassView = [[ResetPassViewController alloc] init];
    
    resetPassView.token = [[notification userInfo] objectForKey:@"token"];
    
    self.navigationController.viewControllers = @[onboardingSignInUpVC, signInVC];
    [self.navigationController pushViewController:resetPassView animated:YES];
}

@end
