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
#import "UIColor+Hex.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

+ (NSString *)configurationKey {
    return @"signIn";
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];

    [self setupNavigationBarWithTitle:LSSTRING(@"title_signin")];
    [self resetForm];
    [[self view] setBackgroundColor:[self viewBackgroundColor]];
 
    // Email Form Field
    [[self email] configureWithDelegate:self
                        secureTextEntry:NO
                             properties:[[self signInProperties] objectForKey:@"emailForm"]
                        placeHolderText:LSSTRING(@"placeholder_email")];
    
    // Password Form Field
    [[self password] configureWithDelegate:self
                           secureTextEntry:YES
                                properties:[[self signInProperties] objectForKey:@"passwordForm"]
                           placeHolderText:LSSTRING(@"placeholder_password")];
    
    // Forgotten Password Transparent Button
    NSDictionary *forgottenPasswordButtonProperties = [[self signInProperties] objectForKey:@"forgottenPasswordButton"];
    [[self forgotPasswordButton] setTitle:LSSTRING(@"button_forgotpass") forState:UIControlStateNormal];
    [[[self forgotPasswordButton] titleLabel] setFont:[UIFont fontWithName:[forgottenPasswordButtonProperties objectForKey:@"textFont"]
                                                                      size:[[forgottenPasswordButtonProperties objectForKey:@"textSize"] doubleValue]]];
    [[self forgotPasswordButton] setTitleColor:[UIColor colorWithHexString:[forgottenPasswordButtonProperties objectForKey:@"textColor"]] forState:UIControlStateNormal];
    
    // Sign In Button
    [[self signinButton] configureWithProperties:[[self signInProperties] objectForKey:@"signInButton"]
                                          titleText:LSSTRING(@"button_signin")];
    
    // Create Account Button
    [[self createAccountButton] configureWithProperties:[[self signInProperties] objectForKey:@"createAccountButton"]
                                       titleText:LSSTRING(@"button_signup")];

    [self setSignUpView:[[SignUpViewController alloc] initWithNibName:@"SignUpViewController"
                                                              bundle:nil
                                                      viewProperties:[self signUpProperties]
                                                           titleFont:[self titleFont]
                                                          titleColor:[self titleColor]
                                                navigationBarBgColor:[self navigationBackgroundColor]
                                                navigationBarFgColor:[self navigationForegroundColor]
                                                         viewBgColor:[self viewBackgroundColor]]];
    
    [self setLostpassView:[[LostPassViewController alloc] initWithNibName:@"LostPassViewController"
                                                                   bundle:nil
                                                           viewProperties:[self lostPassProperties]
                                                                titleFont:[self titleFont]
                                                               titleColor:[self titleColor]
                                                     navigationBarBgColor:[self navigationBackgroundColor]
                                                     navigationBarFgColor:[self navigationForegroundColor]
                                                              viewBgColor:[self viewBackgroundColor]]];
}

- (void) setupNavigationBarWithTitle:(NSString *) titleText {
    
    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    [title setText:titleText];
    [title setFont:[self titleFont]];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setTextColor:[self titleColor]];
    [[self navigationItem] setTitleView:title];
    
    int count = [[[self appDelegate] notificarePushLib] myBadge];

    if(count > 0){
        [[self buttonIcon] setTintColor:[self navigationForegroundColor]];
        [[self badgeButton] addTarget:[self viewDeckController] action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
        
        NSString * badge = [NSString stringWithFormat:@"%i", count];
        [[self badgeNr] setText:badge];
        
        UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithCustomView:[self badge]];
        [leftButton setTarget:[self viewDeckController]];
        [leftButton setAction:@selector(toggleLeftView)];
        [leftButton setTintColor:[self navigationForegroundColor]];
        [[self navigationItem] setLeftBarButtonItem:leftButton];
        
    } else {
        
        UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"LeftMenuIcon"] style:UIBarButtonItemStylePlain target:[self viewDeckController] action:@selector(toggleLeftView)];
        [leftButton setTintColor:[self navigationForegroundColor]];
        [[self navigationItem] setLeftBarButtonItem:leftButton];
    }

    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"RightMenuIcon"] style:UIBarButtonItemStylePlain target:[self viewDeckController] action:@selector(toggleRightView)];
    
    [rightButton setTintColor:[self navigationForegroundColor]];
    
    if([[[self appDelegate] beacons] count] > 0){
        
        [[self navigationItem] setRightBarButtonItem:rightButton];
        
    } else {
        
        [[self navigationItem] setRightBarButtonItem:nil];
    }
    
    //For iOS6
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        
        [[[self navigationController] navigationBar] setTintColor:[self navigationBackgroundColor]];
        
        [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"Transparent"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"Transparent"] forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
        
    } else {
        
        [[[self navigationController] navigationBar] setBarTintColor:[self navigationBackgroundColor]];
    }   
}

-(void)changeBadge{
    
    [self setupNavigationBarWithTitle:LSSTRING(@"title_signin")];
}


-(IBAction)doLogin:(id)sender{
    
    [[self signinButton] setEnabled:NO];
    
    if (![[self email] text]) {
        APP_ALERT_DIALOG(LSSTRING(@"error_signin_invalid_email"));

        [[self signinButton] setEnabled:YES];
    }else if ([[[self password] text] length] < 5) {

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

-(IBAction)forgottenPassword:(id)sender{
     [[self navigationController] pushViewController:[self lostpassView] animated:YES];
}

-(IBAction)goToCreateAccount:(id)sender{
    [[self navigationController] pushViewController:[self signUpView] animated:YES];
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
