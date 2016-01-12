//
//  OnboardingWelcomeViewController.m
//
//  Created by Aernout Peeters on 30-09-2015.
//  Copyright © 2015 Notificare. All rights reserved.
//

#import "OnboardingWelcomeViewController.h"

@interface OnboardingWelcomeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIView *bodyView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pointOneImageView;
@property (weak, nonatomic) IBOutlet UIImageView *pointTwoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *pointThreeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *pointFourImageView;
@property (weak, nonatomic) IBOutlet UILabel *pointOneLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointTwoLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointThreeLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointFourLabel;
@property (weak, nonatomic) IBOutlet UILabel *thanksLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end

@implementation OnboardingWelcomeViewController

+ (BOOL)isComplete {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"onboardingWelcomeComplete"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Get Image name from Configuration.plist first
    // self.headerImageView.image = [UIImage imageNamed:@"someImage"];
    self.headerImageView.backgroundColor = ALTO_COLOR;
    
    self.bodyView.backgroundColor = MAIN_COLOR;
    
    self.descriptionLabel.text = LSSTRING(@"onboarding_welcome_description");
    self.descriptionLabel.textColor = ALTO_COLOR;
    
    // self.pointOneImageView.image = [UIImage imageNamed:@"someImage"];
    self.pointOneImageView.tintColor = ALTO_COLOR;
    
    // self.pointTwoImageView.image = [UIImage imageNamed:@"someImage"];
    self.pointTwoImageView.tintColor = ALTO_COLOR;
    
    // self.pointThreeImageView.image = [UIImage imageNamed:@"someImage"];
    self.pointThreeImageView.tintColor = ALTO_COLOR;
    
    // self.pointFourImageView.image = [UIImage imageNamed:@"someImage"];
    self.pointFourImageView.tintColor = ALTO_COLOR;
    
    self.pointOneLabel.text = LSSTRING(@"onboarding_welcome_point_one");
    self.pointOneLabel.textColor = ALTO_COLOR;
    
    self.pointTwoLabel.text = LSSTRING(@"onboarding_welcome_point_two");
    self.pointTwoLabel.textColor = ALTO_COLOR;
    
    self.pointThreeLabel.text = LSSTRING(@"onboarding_welcome_point_three");
    self.pointThreeLabel.textColor = ALTO_COLOR;
    
    self.pointFourLabel.text = LSSTRING(@"onboarding_welcome_point_four");
    self.pointFourLabel.textColor = ALTO_COLOR;
    
    self.thanksLabel.text = LSSTRING(@"onboarding_welcome_thanks");
    self.thanksLabel.textColor = ALTO_COLOR;
    
    [self.nextButton setTitle:LSSTRING(@"button_next") forState:UIControlStateNormal];
    [self.nextButton setTitleColor:BUTTON_TEXT_COLOR forState:UIControlStateNormal];
    self.nextButton.backgroundColor = ALTO_COLOR;
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)next:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"onboardingWelcomeComplete"];
    [defaults synchronize];
    
    if (self.completionBlock) {
        self.completionBlock();
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
