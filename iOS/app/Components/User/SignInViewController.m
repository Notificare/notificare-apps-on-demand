//
//  SignInViewController.m
//  app
//
//  Created by Joel Oliveira on 16/05/14.
//  Copyright (c) 2014 Notificare. All rights reserved.
//

#import "SignInViewController.h"
#import "AppDelegate.h"
#import "NotificarePushLib.h"
#import "IIViewDeckController.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

+ (NSString *)configurationKey {
    return @"signIn";
}

/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
 
    // Email Form Field
    [self.email setup:self.configuration[@"emailField"]];
    self.email.delegate = self;
    
    // Password Form Field
    [self.password setup:self.configuration[@"passwordField"]];
    self.password.delegate = self;
    
    // Forgotten Password Transparent Button
    [self.forgotPasswordButton setup:self.configuration[@"forgottenPasswordButton"]];
    
    // Sign In Button
    [self.signinButton setup:self.configuration[@"signinButton"]];
    
    // Create Account Button
    [self.createAccountButton setup:self.configuration[@"signupButton"]];
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)back {
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)changeBadge{
    
    [self setupNavigationBar];
}


-(IBAction)doLogin:(id)sender{
    
    [[self signinButton] setEnabled:NO];
    
    if (![[self email] text]) {
        APP_ALERT_DIALOG(LSSTRING(@"error_signin_invalid_email"));

        [[self signinButton] setEnabled:YES];
    }else if ([[[self password] text] length] < PASSWORD_MIN_LENGTH) {

        APP_ALERT_DIALOG(LSSTRING(@"error_signin_invalid_password"));
        [[self signinButton] setEnabled:YES];
    } else {
        
        [self.notificarePushLib loginWithUsername:[[self email] text] andPassword:[[self password] text] completionHandler:^(NSDictionary *info) {
            //

            [self.notificarePushLib fetchAccountDetails:^(NSDictionary *info) {
                
                NSDictionary * user = [info objectForKey:@"user"];

                if([[user objectForKey:@"token"] isKindOfClass:[NSNull class]]){
                    
                    [self.notificarePushLib generateAccessToken:^(NSDictionary *info) {
                        //
                    } errorHandler:^(NSError *error) {
                        //
                    }];
                }
                
                
            } errorHandler:^(NSError *error) {
                
                [[self signinButton] setEnabled:YES];
                
                APP_ALERT_DIALOG(LSSTRING(@"error_signin"));
    
            }];
            
            
        } errorHandler:^(NSError *error) {
            //
            [[self signinButton] setEnabled:YES];
            
            switch ([error code]) {
                case kNotificareErrorCodeBadRequest:
                    APP_ALERT_DIALOG(LSSTRING(@"error_signin_invalid_email"));
                    break;
                    
                case kNotificareErrorCodeForbidden:
                    APP_ALERT_DIALOG(LSSTRING(@"error_signin_invalid_password"));
                    break;
                    
                default:

                    break;
            }
        }];
    }
    
}

-(IBAction)forgottenPassword:(id)sender {
#warning Update to use a configuration dictionary
    LostPassViewController *lostPassVC = [[LostPassViewController alloc] init];
    [[self navigationController] pushViewController:lostPassVC animated:YES];
}

-(IBAction)goToCreateAccount:(id)sender{
#warning Update to use a configuration dictionary
    SignUpViewController *signUpVC = [[SignUpViewController alloc] init];
    [[self navigationController] pushViewController:signUpVC animated:YES];
}


-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self setActiveField:(FormField *)textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    [self setActiveField:nil];
    
    [textField resignFirstResponder];
}

- (void)keyboardDidShow:(NSNotification *)note
{
    NSDictionary* info = [note userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(NAV_BAR_HEIGHT, 0.0, kbSize.height+10, 0.0);
    [self scrollView].contentInset = contentInsets;
    [self scrollView].scrollIndicatorInsets = contentInsets;
    
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    
    if (!CGRectContainsPoint(aRect, [self activeField].frame.origin) ) {
        
        [self.scrollView scrollRectToVisible:[self activeField].frame animated:YES];
    }
    
    if (!CGRectContainsPoint(aRect, [self activeField].frame.origin) ) {
        
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             [self.scrollView scrollRectToVisible:[self activeField].frame animated:YES];
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
}

- (void)keyboardWillHide:(NSNotification *)note
{
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(NAV_BAR_HEIGHT, 0.0, 0.0, 0.0);
    
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         [self scrollView].contentInset = contentInsets;
                         [self scrollView].scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBadge) name:@"incomingNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupNavigationBar) name:@"rangingBeacons" object:nil];
    
    [self resetForm];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"incomingNotification"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"rangingBeacons"
                                                  object:nil];
    
}

-(void)resetForm{
    
    [[self email] setText:@""];
    [[self password] setText:@""];
    [[self infoLabel] setText:@""];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
