//
//  OnboardingSignInUpViewController.m
//
//  Created by Aernout Peeters on 15-09-2015.
//  Copyright (c) 2015 Notificare. All rights reserved.
//

#import "OnboardingSignInUpViewController.h"

#import "SignInViewController.h"
#import "SignUpViewController.h"
#import "UserDetailsViewController.h"


@interface OnboardingSignInUpViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIView *bodyView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIView *signInUpView;
@property (weak, nonatomic) IBOutlet UILabel *mainTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

@end


@implementation OnboardingSignInUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // self.headerImageView.image = [UIImage imageNamed:@"someImage"];
    // Should come from configuration.plist?
    // Check if image is really there first
    
    self.headerImageView.backgroundColor = ALTO_COLOR;
    self.bodyView.backgroundColor = MAIN_COLOR;
    
    self.mainTextLabel.text = LSSTRING(@"landing_main_text");
    self.mainTextLabel.textColor = ALTO_COLOR;
    // self.mainTextLabel.font = SOME_FONT_MACRO
    // font names and sizes should be defined in config file
    
    self.subTextLabel.text = LSSTRING(@"landing_sub_text");
    self.subTextLabel.textColor = ALTO_COLOR;
    
    [self.signInButton setTitle:LSSTRING(@"button_signin") forState:UIControlStateNormal];
    [self.signInButton setTitleColor:BUTTON_TEXT_COLOR forState:UIControlStateNormal];
    [self.signInButton setBackgroundColor:ALTO_COLOR];
    
    [self.signUpButton setTitle:LSSTRING(@"button_signup") forState:UIControlStateNormal];
    [self.signUpButton setTitleColor:BUTTON_TEXT_COLOR forState:UIControlStateNormal];
    [self.signUpButton setBackgroundColor:ALTO_COLOR];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    if (self.appDelegate.deviceIsRegistered) {
        if (self.notificarePushLib.isLoggedIn) {
            
            if (self.completionBlock) {
                self.completionBlock();
            }
            
            return;
            
        }
        else {
            [self showSignInUp:NO];
        }
    }
    else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRegisterDevice) name:@"registeredDevice" object:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changedAccount) name:@"changedAccount" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"registeredDevice" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"changedAccount" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // If the first view controller is not self
    // Set the view controllers to only this one
    // So that the navigation controller only pops back to this one
    if (self.navigationController.viewControllers[0] != self) {
        self.navigationController.viewControllers = @[self];
    }
}

- (void)showSignInUp:(BOOL)animated {
    [self.activityIndicatorView stopAnimating];
    
    self.signInUpView.hidden = NO;
    
    if (animated) {
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.signInUpView.alpha = 1;
                         } completion:^(BOOL finished) {
                             
                         }];
    }
    else {
        self.signInUpView.alpha = 1;
    }
}

- (void)didRegisterDevice {
    if (self.notificarePushLib.isLoggedIn) {
        if (self.completionBlock) {
            self.completionBlock();
        }
    }
    else {
        [self showSignInUp:YES];
    }
}

- (IBAction)signIn:(id)sender {
    SignInViewController *signInVC = [[SignInViewController alloc] init];
    
    [self.navigationController pushViewController:signInVC animated:YES];
}

- (IBAction)signUp:(id)sender {
    SignUpViewController *signUpVC = [[SignUpViewController alloc] init];
    
    [self.navigationController pushViewController:signUpVC animated:YES];
}

- (void)changedAccount {
    if (self.completionBlock) {
        self.completionBlock();
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
