//
//  OnboardingWelcomeViewController.m
//
//  Created by Aernout Peeters on 30-09-2015.
//  Copyright © 2015 Notificare. All rights reserved.
//

#import "OnboardingViewController.h"

#import "OnboardingWelcomeViewController.h"
#import "OnboardingNotificationsViewController.h"
#import "OnboardingLocationServicesViewController.h"
#import "OnboardingSignInUpViewController.h"
#import "SignInViewController.h"
#import "ResetPassViewController.h"
#import "OnboardingUserPreferenceViewController.h"
#import "AppDelegate.h"
#import "Configuration.h"


@interface OnboardingViewController ()

@property (nonatomic, readonly) NotificarePushLib *notificarePushLib;

@end


@implementation OnboardingViewController

- (NotificarePushLib *)notificarePushLib {
    return [NotificarePushLib shared];
}

+ (BOOL)isComplete {
    return NO;
}

+ (void)getStatus:(void (^)(OnboardingStatus status, NSDictionary *info))completionBlock {
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationBarHidden:YES animated:NO];
    
    [self next];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedActivationToken:) name:@"receivedActivationToken" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedResetPasswordToken:) name:@"receivedResetPasswordToken" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"receivedActivationToken" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"receivedResetPasswordToken" object:nil];
}

- (void)next {
    BOOL animated = self.viewControllers.count != 0;
    
    [[self class] getStatus:^(OnboardingStatus status, NSDictionary *info) {
        
        switch (status) {
            case kOnboardingStatusMustCompleteSteps:
                [self pushStep:info[@"step"] withAnimated:animated];
                break;
                
            case kOnboardingStatusMustLogIn: {
                OnboardingSignInUpViewController *onboardingSignInUpVC = [[OnboardingSignInUpViewController alloc] init];
                onboardingSignInUpVC.completionBlock = ^{
                    [self next];
                };
                [self pushViewController:onboardingSignInUpVC animated:animated];
                
                break;
            }
                
            case kOnboardingStatusMustCompleteUserPrefs: {
                OnboardingUserPreferenceViewController *onboardingUserPreferenceVC = [[OnboardingUserPreferenceViewController alloc] initWithUserPreference:info[@"userPreference"]];
                [self pushViewController:onboardingUserPreferenceVC animated:animated];
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
            [self next];
        };
        [self pushViewController:onboardingWelcomeVC animated:animated];
    }
    else if ([step isEqualToString:@"notifications"]) {
        
        OnboardingNotificationsViewController *onboardingNotificationsVC = [[OnboardingNotificationsViewController alloc] init];
        onboardingNotificationsVC.completionBlock = ^{
            [self next];
        };
        [self pushViewController:onboardingNotificationsVC animated:animated];
    }
    else if ([step isEqualToString:@"locationServices"]) {
        
        OnboardingLocationServicesViewController *onboardingLocationServicesVC = [[OnboardingLocationServicesViewController alloc] init];
        onboardingLocationServicesVC.completionBlock = ^{
            [self next];
        };
        [self pushViewController:onboardingLocationServicesVC animated:animated];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)present:(BOOL)animated {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window.rootViewController presentViewController:self animated:animated completion:NULL];
}

- (void)receivedActivationToken:(NSNotification *)notification {
    OnboardingSignInUpViewController *onboardingSignInUpVC = [[OnboardingSignInUpViewController alloc] init];
    SignInViewController *signInVC = [[SignInViewController alloc] init];
    
    self.viewControllers = @[onboardingSignInUpVC];
    
    [self pushViewController:signInVC animated:YES];
}

- (void)receivedResetPasswordToken:(NSNotification *)notification {
    OnboardingSignInUpViewController *onboardingSignInUpVC = [[OnboardingSignInUpViewController alloc] init];
    SignInViewController *signInVC = [[SignInViewController alloc] init];
    ResetPassViewController *resetPassView = [[ResetPassViewController alloc] init];
    
    resetPassView.token = [[notification userInfo] objectForKey:@"token"];
    
    self.viewControllers = @[onboardingSignInUpVC, signInVC];
    [self pushViewController:resetPassView animated:YES];
}

@end
