//
//  OnboardingNotificationsViewController.m
//
//  Created by Aernout Peeters on 30-09-2015.
//  Copyright © 2015 Notificare. All rights reserved.
//

#import "OnboardingNotificationsViewController.h"

@interface OnboardingNotificationsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *allowNotificationsButton;

@end


@implementation OnboardingNotificationsViewController

+ (BOOL)isComplete {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"onboardingNotificationsComplete"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get image name from Configuration.plist
    // self.headerImageView.image = [UIImage imageNamed:@"someImage"];
    self.headerImageView.backgroundColor = MAIN_COLOR;
    
    self.descriptionLabel.text = LSSTRING(@"intro_notifications_description");
    self.descriptionLabel.textColor = ALTO_COLOR;
    
    [self.allowNotificationsButton setTitle:LSSTRING(@"button_allow_notifications") forState:UIControlStateNormal];
    [self.allowNotificationsButton setTitleColor:BUTTON_TEXT_COLOR forState:UIControlStateNormal];
    self.allowNotificationsButton.backgroundColor = ALTO_COLOR;
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(registeredDevice)
                                                 name:@"registeredDevice"
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"registeredDevice"
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)allowNotifications:(id)sender {
    /*UIButton *button = (UIButton *)sender;
    button.userInteractionEnabled = NO;*/
    
#if TARGET_IPHONE_SIMULATOR
    [self.notificarePushLib registerUserNotifications];
#else
    [self.notificarePushLib registerForNotifications];
#endif
}

- (void)registeredDevice {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"onboardingNotificationsComplete"];
    [defaults synchronize];
    
    if (self.completionBlock) {
        self.completionBlock();
    }
}

@end
