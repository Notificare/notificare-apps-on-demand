//
//  SignUpViewController.m
//  app
//
//  Created by Joel Oliveira on 17/05/14.
//  Copyright (c) 2014 Notificare. All rights reserved.
//

#import "SignUpViewController.h"
#import "NotificarePushLib.h"
#import "AppDelegate.h"
#import "IIViewDeckController.h"
#import "UIColor+NSDictionary.h"

@interface SignUpViewController ()

@property (assign, nonatomic) CGPoint viewCenter;

@end

@implementation SignUpViewController


- (AppDelegate *)appDelegate {
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (NotificarePushLib *)notificare {
    
    return (NotificarePushLib *)[[self appDelegate] notificarePushLib];
}

- (id)initWithNibName:(NSString *) nibNameOrNil
               bundle:(NSBundle *) nibBundleOrNil
       viewProperties:(NSDictionary *) signUpProperties
            titleFont:(UIFont *) titleFont
           titleColor:(UIColor *) titleColor
 navigationBarBgColor:(UIColor *) navigationBarBgColor
 navigationBarFgColor:(UIColor *) navigationBarFgColor
          viewBgColor:(UIColor *) viewBgColor
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        _signUpProperties = signUpProperties;
        _titleFont = titleFont;
        _titleColor = titleColor;
        _navigationBackgroundColor = navigationBarBgColor;
        _navigationForegroundColor = navigationBarFgColor;
        _viewBackgroundColor = viewBgColor;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
    
    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    [title setText:LSSTRING(@"title_signup")];
    [title setFont:[self titleFont]];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setTextColor:[self titleColor]];
    [[self navigationItem] setTitleView:title];
    
    [[self view] setBackgroundColor:[self viewBackgroundColor]];
    
    [self resetForm];
    
    // Name Form Field
    NSDictionary *nameFormProperties = [[self signUpProperties] objectForKey:@"nameForm"];
    [[self name] setDelegate:self];
    [[self name] setPlaceholder:LSSTRING(@"placeholder_name")];
    [[self name] setFont:[UIFont fontWithName:[nameFormProperties objectForKey:@"textFont"]
                                          size:[[nameFormProperties objectForKey:@"textSize"] doubleValue]]];
    [[self name] setBackgroundColor:[UIColor colorFromRgbaDictionary:[nameFormProperties objectForKey:@"backgroundColor"]]];
    [[self name] setTextColor:[UIColor colorFromRgbaDictionary:[nameFormProperties objectForKey:@"textColor"]]];
    [[self name] setTintColor:[UIColor colorFromRgbaDictionary:[nameFormProperties objectForKey:@"tintColor"]]];
    [self name].layer.cornerRadius= [[nameFormProperties objectForKey:@"cornerRadius"] doubleValue];
    [self name].layer.borderColor= [[UIColor colorFromRgbaDictionary:[nameFormProperties objectForKey:@"borderColor"]] CGColor];
    [self name].layer.borderWidth= [[nameFormProperties objectForKey:@"borderWidth"] doubleValue];
    [[self name] setPlaceholderText:LSSTRING(@"placeholder_name")
                 withRGBaDictionary:[nameFormProperties objectForKey:@"placeholderColor"]];
    
    // Email Form Field
    NSDictionary *emailFormProperties = [[self signUpProperties] objectForKey:@"emailForm"];
    [[self email] setDelegate:self];
    [[self email] setFont:[UIFont fontWithName:[emailFormProperties objectForKey:@"textFont"]
                                             size:[[emailFormProperties objectForKey:@"textSize"] doubleValue]]];
    [[self email] setBackgroundColor:[UIColor colorFromRgbaDictionary:[emailFormProperties objectForKey:@"backgroundColor"]]];
    [[self email] setTextColor:[UIColor colorFromRgbaDictionary:[emailFormProperties objectForKey:@"textColor"]]];
    [[self email] setTintColor:[UIColor colorFromRgbaDictionary:[emailFormProperties objectForKey:@"tintColor"]]];
    [self email].layer.cornerRadius= [[emailFormProperties objectForKey:@"cornerRadius"] doubleValue];
    [self email].layer.borderColor= [[UIColor colorFromRgbaDictionary:[emailFormProperties objectForKey:@"borderColor"]] CGColor];
    [self email].layer.borderWidth= [[emailFormProperties objectForKey:@"borderWidth"] doubleValue];
    [[self email] setPlaceholderText:LSSTRING(@"placeholder_email")
                     withRGBaDictionary:[emailFormProperties objectForKey:@"placeholderColor"]];
    
    // Password Form Field
    NSDictionary *passwordFormProperties = [[self signUpProperties] objectForKey:@"passwordForm"];
    [[self password] setDelegate:self];
    [[self password] setSecureTextEntry:YES];
    [[self password] setFont:[UIFont fontWithName:[passwordFormProperties objectForKey:@"textFont"]
                                             size:[[passwordFormProperties objectForKey:@"textSize"] doubleValue]]];
    [[self password] setBackgroundColor:[UIColor colorFromRgbaDictionary:[passwordFormProperties objectForKey:@"backgroundColor"]]];
    [[self password] setTextColor:[UIColor colorFromRgbaDictionary:[passwordFormProperties objectForKey:@"textColor"]]];
    [[self password] setTintColor:[UIColor colorFromRgbaDictionary:[passwordFormProperties objectForKey:@"tintColor"]]];
    [self password].layer.cornerRadius= [[passwordFormProperties objectForKey:@"cornerRadius"] doubleValue];
    [self password].layer.borderColor= [[UIColor colorFromRgbaDictionary:[passwordFormProperties objectForKey:@"borderColor"]] CGColor];
    [self password].layer.borderWidth= [[passwordFormProperties objectForKey:@"borderWidth"] doubleValue];
    [[self password] setPlaceholderText:LSSTRING(@"placeholder_password")
                     withRGBaDictionary:[passwordFormProperties objectForKey:@"placeholderColor"]];
    
    // Confirm Password Form Field
    NSDictionary *confirmPasswordFormProperties = [[self signUpProperties] objectForKey:@"confirmPasswordForm"];
    [[self passwordConfirm] setDelegate:self];
    [[self passwordConfirm] setSecureTextEntry:YES];
    [[self passwordConfirm] setFont:[UIFont fontWithName:[confirmPasswordFormProperties objectForKey:@"textFont"]
                                             size:[[confirmPasswordFormProperties objectForKey:@"textSize"] doubleValue]]];
    [[self passwordConfirm] setBackgroundColor:[UIColor colorFromRgbaDictionary:[confirmPasswordFormProperties objectForKey:@"backgroundColor"]]];
    [[self passwordConfirm] setTextColor:[UIColor colorFromRgbaDictionary:[confirmPasswordFormProperties objectForKey:@"textColor"]]];
    [[self passwordConfirm] setTintColor:[UIColor colorFromRgbaDictionary:[confirmPasswordFormProperties objectForKey:@"tintColor"]]];
    [self passwordConfirm].layer.cornerRadius= [[confirmPasswordFormProperties objectForKey:@"cornerRadius"] doubleValue];
    [self passwordConfirm].layer.borderColor= [[UIColor colorFromRgbaDictionary:[confirmPasswordFormProperties objectForKey:@"borderColor"]] CGColor];
    [self passwordConfirm].layer.borderWidth= [[confirmPasswordFormProperties objectForKey:@"borderWidth"] doubleValue];
    [[self passwordConfirm] setPlaceholderText:LSSTRING(@"placeholder_confirm_password")
                            withRGBaDictionary:[confirmPasswordFormProperties objectForKey:@"placeholderColor"]];
    
    // Create Account Button
    NSDictionary *createAccountButtonProperties = [[self signUpProperties] objectForKey:@"createAccountButton"];
    [[self signupButton] setTitle:LSSTRING(@"button_signup") forState:UIControlStateNormal];
    [[[self signupButton] titleLabel] setFont:[UIFont fontWithName:[createAccountButtonProperties objectForKey:@"textFont"]
                                                                     size:[[createAccountButtonProperties objectForKey:@"textSize"] doubleValue]]];
    [[self signupButton] setTitleColor:[UIColor colorFromRgbaDictionary:[createAccountButtonProperties objectForKey:@"textColor"]] forState:UIControlStateNormal];
    [[self signupButton] setBackgroundColor:[UIColor colorFromRgbaDictionary:[createAccountButtonProperties objectForKey:@"backgroundColor"]]];
    [[[self signupButton] titleLabel] setShadowColor:[UIColor blackColor]];
    [self signupButton].layer.cornerRadius= [[createAccountButtonProperties objectForKey:@"cornerRadius"] doubleValue];
    [self signupButton].layer.borderColor= [[UIColor colorFromRgbaDictionary:[createAccountButtonProperties objectForKey:@"borderColor"]] CGColor];
    [self signupButton].layer.borderWidth= [[createAccountButtonProperties objectForKey:@"borderWidth"] doubleValue];

    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackButton"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    [leftButton setTintColor:[self navigationForegroundColor]];
    
    [[self navigationItem] setLeftBarButtonItem:leftButton];
    [[self navigationItem] setRightBarButtonItem:nil];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        [[[self navigationController] navigationBar] setTintColor:[self navigationBackgroundColor]];
        
        [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"Transparent"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"Transparent"] forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
        
    } else {
        
        [[[self navigationController] navigationBar] setBarTintColor:[self navigationBackgroundColor]];
    }
    
    [self setViewCenter:[[self view] center]];
}

-(IBAction)createAccount:(id)sender{
    
    [[self signupButton] setEnabled:NO];
    
    if (![[self email] text]) {
        
        APP_ALERT_DIALOG(LSSTRING(@"error_create_account_invalid_email"));
        [[self signupButton] setEnabled:YES];
    }else if (![[[self password] text] isEqualToString:[[self passwordConfirm] text]]) {
        
        APP_ALERT_DIALOG(LSSTRING(@"error_create_account_passwords_match"));
        [[self signupButton] setEnabled:YES];
    }else if ([[[self passwordConfirm] text] length] < 5) {
        APP_ALERT_DIALOG(LSSTRING(@"error_create_account_small_password"));
        [[self signupButton] setEnabled:YES];
    } else {
        
        [[self notificare] createAccount:[[self email] text]
                                withName:[[self name] text]
                             andPassword:[[self password] text]
                       completionHandler:^(NSDictionary *info) {

            APP_ALERT_DIALOG(LSSTRING(@"success_create_account"));

            [[self signupButton] setEnabled:YES];
            [[self email] setText:@""];
            [[self name] setText:@""];
            [[self password] setText:@""];
            [[self passwordConfirm] setText:@""];
            [[self navigationController] popToRootViewControllerAnimated:YES];
            
        } errorHandler:^(NSError *error) {

            APP_ALERT_DIALOG(LSSTRING(@"error_create_account"));

            [[self signupButton] setEnabled:YES];
        }];
        
    }
    
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



-(void)goBack{
    
    [[self navigationController] popViewControllerAnimated:YES];
}

-(void)resetForm{
    
    [[self name] setText:@""];
    [[self email] setText:@""];
    [[self password] setText:@""];
    [[self passwordConfirm] setText:@""];
    [[self infoLabel] setText:@""];
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
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
