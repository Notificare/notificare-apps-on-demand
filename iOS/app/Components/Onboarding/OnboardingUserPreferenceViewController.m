//
//  OnboardingUserPreferenceViewController.m
//  app
//
//  Created by Aernout Peeters on 12-01-2016.
//  Copyright © 2016 Notificare. All rights reserved.
//

#import "OnboardingUserPreferenceViewController.h"

@interface OnboardingUserPreferenceViewController ()

@property (strong, nonatomic) IBOutlet UIView *choiceView;
@property (strong, nonatomic) IBOutlet UIView *selectView;
@property (strong, nonatomic) IBOutlet UIView *singleView;

@end

@implementation OnboardingUserPreferenceViewController

- (instancetype)init {
    [NSException raise:@"wrong_initializer" format:@"Use [OnboardingUserPreferenceViewController initWithUserPreference:]"];
    
    return nil;
}

- (instancetype)initWithConfiguration:(NSDictionary *)configuration {
    [NSException raise:@"wrong_initializer" format:@"Use [OnboardingUserPreferenceViewController initWithConfiguration:andWithUserPreference:]"];
    
    return nil;
}

- (instancetype)initWithUserPreference:(NotificareUserPreference *)userPreference {
    self = [super init];
    
    if (self) {
        _userPreference = userPreference;
    }
    
    return self;
}

- (instancetype)initWithConfiguration:(NSDictionary *)configuration andWithUserPreference:(NotificareUserPreference *)userPreference {
    self = [super initWithConfiguration:configuration];
    
    if (self) {
        _userPreference = userPreference;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
