//
//  OnboardingLocationServicesViewController.m
//
//  Created by Aernout Peeters on 30-09-2015.
//  Copyright © 2015 Notificare. All rights reserved.
//

#import "OnboardingLocationServicesViewController.h"

#import "NotificarePushLib.h"

@interface OnboardingLocationServicesViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *allowLocationServicesButton;

@end


@implementation OnboardingLocationServicesViewController

+ (BOOL)isComplete {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"onboardingLocationServicesComplete"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get image name from Configuration.plist
    // self.headerImageView.image = [UIImage imageNamed:@"someImage"];
    self.headerImageView.backgroundColor = MAIN_COLOR;
    
    self.descriptionLabel.text = LSSTRING(@"onboarding_location_services_description");
    self.descriptionLabel.textColor = ALTO_COLOR;
    
    [self.allowLocationServicesButton setTitle:LSSTRING(@"button_allow_location_services") forState:UIControlStateNormal];
    [self.allowLocationServicesButton setTitleColor:BUTTON_TEXT_COLOR forState:UIControlStateNormal];
    self.allowLocationServicesButton.backgroundColor = ALTO_COLOR;
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateLocations)
                                                 name:@"updatedLocations"
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"updatedLocations"
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)allowLocationServices:(id)sender {
   /* UIButton *button = (UIButton *)sender;
    button.userInteractionEnabled = NO;*/
    
    [[NotificarePushLib shared] startLocationUpdates];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startedLocationUpdates" object:nil];
    
    [self next];
}

- (void)didUpdateLocations {
    [self next];
}

- (void)next {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"onboardingLocationServicesComplete"];
    
    [defaults synchronize];
    
    
    /*NotificarePushLib *pushLib = [NotificarePushLib shared];
    if ([pushLib checkLocationUpdates]) {
        if ([pushLib isLoggedIn] && self.navigationController.isBeingPresented) {
            [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
        }
        else {
            LandingViewController *landingVC = [[LandingViewController alloc] init];
            [self.navigationController pushViewController:landingVC animated:YES];
        }
    }*/
    
    if (self.completionBlock) {
        self.completionBlock();
    }
}

@end
