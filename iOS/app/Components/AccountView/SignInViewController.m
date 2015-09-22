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
#import "UIColor+NSDictionary.h"

@interface SignInViewController ()

@end

@implementation SignInViewController


- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (NotificarePushLib *)notificare {
    return (NotificarePushLib *)[[self appDelegate] notificarePushLib];
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

    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    [title setText:LSSTRING(@"title_signin")];
    [title setFont:[self titleFont]];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setTextColor:[self titleColor]];
    [[self navigationItem] setTitleView:title];
    
    [[self view] setBackgroundColor:[self viewBackgroundColor]];
    
    [self setupNavigationBar];
    
    [self resetForm];
    
    NSDictionary *emailFormProperties = [[self signInProperties] objectForKey:@"emailForm"];
    [[self email] setDelegate:self];
    [[self email] setFont:[UIFont fontWithName:[emailFormProperties objectForKey:@"textFont"]
                                          size:[[emailFormProperties objectForKey:@"textSize"] doubleValue]]];
    [[self email] setBackgroundColor:[UIColor colorFromRgbaDictionary:[emailFormProperties objectForKey:@"backgroundColor"]]];
    [[self email] setTextColor:[UIColor colorFromRgbaDictionary:[emailFormProperties objectForKey:@"textColor"]]];
    [self email].layer.cornerRadius= [[emailFormProperties objectForKey:@"cornerRadius"] doubleValue];
    [self email].layer.borderColor= [[UIColor colorFromRgbaDictionary:[emailFormProperties objectForKey:@"borderColor"]] CGColor];
    [self email].layer.borderWidth= [[emailFormProperties objectForKey:@"borderWidth"] doubleValue];
    
    if ([[self email] respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        
        [self email].attributedPlaceholder = [[NSAttributedString alloc] initWithString:LSSTRING(@"placeholder_email") attributes:@{NSForegroundColorAttributeName: [UIColor colorFromRgbaDictionary:[emailFormProperties objectForKey:@"placeholderColor"]]}];
        
    } else {
        
        [[self email] setPlaceholder:LSSTRING(@"placeholder_email")];
    }
    
    NSDictionary *passwordFormProperties = [[self signInProperties] objectForKey:@"passwordForm"];
    [[self password] setDelegate:self];
    [[self password] setSecureTextEntry:YES];
    [[self password] setFont:[UIFont fontWithName:[passwordFormProperties objectForKey:@"textFont"]
                                          size:[[passwordFormProperties objectForKey:@"textSize"] doubleValue]]];
    [[self password] setBackgroundColor:[UIColor colorFromRgbaDictionary:[passwordFormProperties objectForKey:@"backgroundColor"]]];
    [[self password] setTextColor:[UIColor colorFromRgbaDictionary:[passwordFormProperties objectForKey:@"textColor"]]];
    [self password].layer.cornerRadius= [[passwordFormProperties objectForKey:@"cornerRadius"] doubleValue];
    [self password].layer.borderColor= [[UIColor colorFromRgbaDictionary:[passwordFormProperties objectForKey:@"borderColor"]] CGColor];
    [self password].layer.borderWidth= [[passwordFormProperties objectForKey:@"borderWidth"] doubleValue];
    
    if ([[self password] respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        
        [self password].attributedPlaceholder = [[NSAttributedString alloc] initWithString:LSSTRING(@"placeholder_password") attributes:@{NSForegroundColorAttributeName: [UIColor colorFromRgbaDictionary:[passwordFormProperties objectForKey:@"placeholderColor"]]}];
        
    } else {
        
        [[self password] setPlaceholder:LSSTRING(@"placeholder_password")];
    }
    
    NSDictionary *forgottenPasswordButtonProperties = [[self signInProperties] objectForKey:@"forgottenPasswordButton"];
    [[self forgotPasswordButton] setTitle:LSSTRING(@"button_forgotpass") forState:UIControlStateNormal];
    [[[self forgotPasswordButton] titleLabel] setFont:[UIFont fontWithName:[forgottenPasswordButtonProperties objectForKey:@"textFont"]
                                                                      size:[[forgottenPasswordButtonProperties objectForKey:@"textSize"] doubleValue]]];
    [[self forgotPasswordButton] setTitleColor:[UIColor colorFromRgbaDictionary:[forgottenPasswordButtonProperties objectForKey:@"textColor"]] forState:UIControlStateNormal];
    
    NSDictionary *signInButtonProperties = [[self signInProperties] objectForKey:@"signInButton"];
    [[self signinButton] setTitle:LSSTRING(@"button_signin") forState:UIControlStateNormal];
    [[[self signinButton] titleLabel] setFont:[UIFont fontWithName:[signInButtonProperties objectForKey:@"textFont"]
                                                              size:[[signInButtonProperties objectForKey:@"textSize"] doubleValue]]];
    [[self signinButton] setTitleColor:[UIColor colorFromRgbaDictionary:[signInButtonProperties objectForKey:@"textColor"]] forState:UIControlStateNormal];
    [[self signinButton] setBackgroundColor:[UIColor colorFromRgbaDictionary:[signInButtonProperties objectForKey:@"backgroundColor"]]];
    [[[self signinButton] titleLabel] setShadowColor:[UIColor blackColor]];
    [self signinButton].layer.cornerRadius= [[signInButtonProperties objectForKey:@"cornerRadius"] doubleValue];
    [self signinButton].layer.borderColor= [[UIColor colorFromRgbaDictionary:[signInButtonProperties objectForKey:@"borderColor"]] CGColor];
    [self signinButton].layer.borderWidth= [[signInButtonProperties objectForKey:@"borderWidth"] doubleValue];
    
    NSDictionary *createAccountButtonProperties = [[self signInProperties] objectForKey:@"createAccountButton"];
    [[self createAccountButton] setTitle:LSSTRING(@"button_signup") forState:UIControlStateNormal];
    [[[self createAccountButton] titleLabel] setFont:[UIFont fontWithName:[createAccountButtonProperties objectForKey:@"textFont"]
                                                              size:[[createAccountButtonProperties objectForKey:@"textSize"] doubleValue]]];
    [[self createAccountButton] setTitleColor:[UIColor colorFromRgbaDictionary:[createAccountButtonProperties objectForKey:@"textColor"]] forState:UIControlStateNormal];
    [[self createAccountButton] setBackgroundColor:[UIColor colorFromRgbaDictionary:[createAccountButtonProperties objectForKey:@"backgroundColor"]]];
    [[[self createAccountButton] titleLabel] setShadowColor:[UIColor blackColor]];
    [self createAccountButton].layer.cornerRadius= [[createAccountButtonProperties objectForKey:@"cornerRadius"] doubleValue];
    [self createAccountButton].layer.borderColor= [[UIColor colorFromRgbaDictionary:[createAccountButtonProperties objectForKey:@"borderColor"]] CGColor];
    [self createAccountButton].layer.borderWidth= [[createAccountButtonProperties objectForKey:@"borderWidth"] doubleValue];

    
    [self setSignUpView:[[SignUpViewController alloc] initWithNibName:@"SignUpViewController" bundle:nil]];
    [self setLostpassView:[[LostPassViewController alloc] initWithNibName:@"LostPassViewController" bundle:nil]];
    
    //For iOS6
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        [[[self navigationController] navigationBar] setTintColor:[self navigationBackgroundColor]];
        
        [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"Transparent"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"Transparent"] forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
        
    } else {
        
        [[[self navigationController] navigationBar] setBarTintColor:[self navigationBackgroundColor]];
    }

}


-(void)setupNavigationBar{
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
    
    
}

-(void)changeBadge{
    
    [self setupNavigationBar];
    
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
        
        [[self notificare] loginWithUsername:[[self email] text] andPassword:[[self password] text] completionHandler:^(NSDictionary *info) {
            //

            [[self notificare] fetchAccountDetails:^(NSDictionary *info) {
                
                NSDictionary * user = [info objectForKey:@"user"];

                if([[user objectForKey:@"token"] isKindOfClass:[NSNull class]]){
                    
                    [[self notificare] generateAccessToken:^(NSDictionary *info) {
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
