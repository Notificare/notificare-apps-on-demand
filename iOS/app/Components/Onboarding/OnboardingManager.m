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

- (void)setStatus:(OnboardingStatus)status {
    OnboardingStatus oldStatus = _status;
    
    _status = status;
    
    if (status != oldStatus && self.delegate) {
        [self.delegate onboardingManager:self didUpdateStatus:status];
    }
}

- (void)setDeviceIsRegistered:(BOOL)deviceIsRegistered {
    _deviceIsRegistered = deviceIsRegistered;
    
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if ([viewController class] == [OnboardingSignInUpViewController class]) {
            OnboardingSignInUpViewController *onboardingSignInUpVC = (OnboardingSignInUpViewController *)viewController;
            [onboardingSignInUpVC checkDeviceAndUser];
        }
    }
}

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
        _status = kOnboardingStatusUnknown;
    }
    
    return self;
}

- (void)getStatus:(void (^)(OnboardingStatus status, NSDictionary *info))completionBlock {
    NSDictionary *appSettings = [[Configuration shared] getDictionary:@"appSettings"];
    
    for (NSString *step in appSettings[@"onboardingSteps"]) {
        
        if (([step isEqualToString:@"welcome"] && ![OnboardingWelcomeViewController isComplete]) ||
            ([step isEqualToString:@"notifications"] && ![OnboardingNotificationsViewController isComplete]) ||
            ([step isEqualToString:@"locationServices"] && ![OnboardingLocationServicesViewController isComplete])) {
            
            self.status = kOnboardingStatusMustCompleteSteps;
            completionBlock(self.status, @{@"step": step});
            
            return;
        }
    }
    
    if ([appSettings[@"userMustBeLoggedIn"] boolValue]) {
        
        if (![[NotificarePushLib shared] isLoggedIn]) {
            
            self.status = kOnboardingStatusMustLogIn;
            completionBlock(self.status, nil);
            
            return;
        }
        
    }
    else {
        
        self.status = kOnboardingStatusAllComplete;
        completionBlock(self.status, nil);
        
        return;
        
    }
    
    if ([appSettings[@"userMustCompletePreferences"] boolValue]) {
        
        [[NotificarePushLib shared] fetchUserPreferences:^(NSArray *preferences) {
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            BOOL allPreferencesComplete = YES;
            
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
                
                allPreferencesComplete &= preferenceComplete;
                
                if (!preferenceComplete) {
                    self.status = kOnboardingStatusMustCompleteUserPrefs;
                    completionBlock(self.status, @{@"userPreference": preference});
                    
                    return;
                }
            }
            
            if (allPreferencesComplete) {
                self.status = kOnboardingStatusAllComplete;
                completionBlock(self.status, nil);
                
                return;
            }
            
        } errorHandler:^(NSError *error) {
            NSLog(@"Failed to Fetch User Preferences:\n%@", error);
            // Maybe show an alert here?
        }];
    }
    else {
        
        self.status = kOnboardingStatusAllComplete;
        completionBlock(self.status, nil);
        
        return;
        
    }
}

- (BOOL)visible {
    return self.navigationController != nil && self.windowRootVC.presentedViewController == self.navigationController;
}

- (void)setVisible {
    [self setVisible:NO];
}

- (void)setVisible:(BOOL)visible animated:(BOOL)animated {
    if (visible == self.visible) {
        return;
    }
    
    if (visible) {
        [self show:animated];
    }
    else {
        [self hide:animated];
    }
}

- (void)show:(BOOL)animated {
    if (!self.navigationController) {
        self.navigationController = [[UINavigationController alloc] init];
    }
    
    if (self.windowRootVC.presentedViewController) {
        if (self.windowRootVC.presentedViewController == self.navigationController) {
            // No need to show it again
        }
        else {
            
            if (self.delegate) {
                [self.delegate onboardingWillShow:self];
            }
            
            [self.windowRootVC presentViewController:self.navigationController animated:animated completion:^{
                if (self.delegate) {
                    [self.delegate onboardingDidShow:self];
                }
            }];
            
        }
    }
    else {
        
        if (self.delegate) {
            [self.delegate onboardingWillShow:self];
        }
        
        [self.windowRootVC presentViewController:self.navigationController animated:animated completion:^{
            if (self.delegate) {
                [self.delegate onboardingDidShow:self];
            }
        }];
        
    }
    
    [self update];
}

- (void)hide:(BOOL)animated {
    if (self.navigationController) {
        
        if (self.navigationController == self.windowRootVC.presentedViewController) {
            
            if (self.delegate) {
                [self.delegate onboardingWillHide:self];
            }
            
            [self.navigationController dismissViewControllerAnimated:animated completion:^{
                self.navigationController = nil;
                
                if (self.delegate) {
                    [self.delegate onboardingDidHide:self];
                }
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
                [self showStep:info[@"step"] animated:animated];
                break;
                
            case kOnboardingStatusMustLogIn: {
                OnboardingSignInUpViewController *onboardingSignInUpVC = [[OnboardingSignInUpViewController alloc] init];
                onboardingSignInUpVC.completionBlock = ^{
                    [self update];
                };
                [self showViewController:onboardingSignInUpVC animated:animated];
                
                break;
            }
                
            case kOnboardingStatusMustCompleteUserPrefs: {
                OnboardingUserPreferenceViewController *onboardingUserPreferenceVC = [[OnboardingUserPreferenceViewController alloc] initWithUserPreference:info[@"userPreference"]];
                [self showViewController:onboardingUserPreferenceVC animated:animated];
                break;
            }
                
            case kOnboardingStatusAllComplete:
                [self hide:YES];
                break;
                
            default:
                break;
        }
        
    }];
}

- (void)showStep:(NSString *)step animated:(BOOL)animated {
    if ([step isEqualToString:@"welcome"]) {
        
        OnboardingWelcomeViewController *onboardingWelcomeVC = [[OnboardingWelcomeViewController alloc] init];
        onboardingWelcomeVC.completionBlock = ^{
            [self update];
        };
        [self showViewController:onboardingWelcomeVC animated:animated];
    }
    else if ([step isEqualToString:@"notifications"]) {
        
        OnboardingNotificationsViewController *onboardingNotificationsVC = [[OnboardingNotificationsViewController alloc] init];
        onboardingNotificationsVC.completionBlock = ^{
            [self update];
        };
        [self showViewController:onboardingNotificationsVC animated:animated];
    }
    else if ([step isEqualToString:@"locationServices"]) {
        
        OnboardingLocationServicesViewController *onboardingLocationServicesVC = [[OnboardingLocationServicesViewController alloc] init];
        onboardingLocationServicesVC.completionBlock = ^{
            [self update];
        };
        [self showViewController:onboardingLocationServicesVC animated:animated];
    }
}

- (void)showViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (!self.navigationController) {
        return;
    }
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    
    if (viewControllers.count == 0) {
        [self.navigationController pushViewController:viewController animated:animated];
        return;
    }
    
    // Check if we're not pushing the same view controller twice
    if ([viewControllers.lastObject class] == [viewController class]) {
        
        if ([viewController class] == [OnboardingSignInUpViewController class]) {
            OnboardingSignInUpViewController *onboardingSignInUpVC = (OnboardingSignInUpViewController *)viewController;
            [onboardingSignInUpVC checkDeviceAndUser];
        }
        
    }
    else {
        [self.navigationController pushViewController:viewController animated:animated];
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
