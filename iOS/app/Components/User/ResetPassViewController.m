//
//  ResetPassViewController.m
//  app
//
//  Created by Joel Oliveira on 18/05/14.
//  Copyright (c) 2014 Notificare. All rights reserved.
//

#import "ResetPassViewController.h"
#import "NotificarePushLib.h"
#import "AppDelegate.h"
#import "IIViewDeckController.h"
#import "UIColor+Hex.h"

@interface ResetPassViewController ()

@end

@implementation ResetPassViewController

+ (NSString *)configurationKey {
    return @"resetPass";
}

- (id)initWithNibName:(NSString *) nibNameOrNil
               bundle:(NSBundle *) nibBundleOrNil
       viewProperties:(NSDictionary *) resetPassProperties
     signInProperties:(NSDictionary *) signInProperties
     signUpProperties:(NSDictionary *) signUpProperties
            titleFont:(UIFont *) titleFont
           titleColor:(UIColor *) titleColor
 navigationBarBgColor:(UIColor *) navigationBarBgColor
 navigationBarFgColor:(UIColor *) navigationBarFgColor
          viewBgColor:(UIColor *) viewBgColor
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        _resetPassProperties = resetPassProperties;
        _signUpProperties = signUpProperties;
        _signInProperties = signInProperties;
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
    
    [self setupNavigationBarWithTitle:LSSTRING(@"title_resetpass")];
    [self resetForm];
    [[self view] setBackgroundColor:[self viewBackgroundColor]];

    // Password Form Field
    [[self password] configureWithDelegate:self
                           secureTextEntry:YES
                                properties:[[self resetPassProperties] objectForKey:@"passwordForm"]
                           placeHolderText:LSSTRING(@"placeholder_newpass")];
    
    // Confirm Password Form Field
    [[self passwordConfirm] configureWithDelegate:self
                                  secureTextEntry:YES
                                       properties:[[self resetPassProperties] objectForKey:@"confirmPasswordForm"]
                                  placeHolderText:LSSTRING(@"placeholder_confirm_newpass")];
    
    // Reset Password Button
    [[self resetPassButton] configureWithProperties:[[self resetPassProperties] objectForKey:@"resetPasswordButton"]
                                          titleText:LSSTRING(@"button_resetpass")];
}

- (void) setupNavigationBarWithTitle:(NSString *) titleText {
    
    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    [title setText:titleText];
    [title setFont:[self titleFont]];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setTextColor:[self titleColor]];
    [[self navigationItem] setTitleView:title];
    
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
}

-(IBAction)resetPassword:(id)sender{
    
    [[self resetPassButton] setEnabled:NO];
    if (![[[self password] text] isEqualToString:[[self passwordConfirm] text]]) {

        APP_ALERT_DIALOG(LSSTRING(@"error_resetpass_passwords_match"));
         [[self resetPassButton] setEnabled:YES];
    }else if ([[[self password] text] length] < 5) {
        APP_ALERT_DIALOG(LSSTRING(@"error_resetpass_small_password"));

        [[self resetPassButton] setEnabled:YES];
    } else {

        [self.notificarePushLib resetPassword:[[self password] text] withToken:[self token] completionHandler:^(NSDictionary *info) {
            APP_ALERT_DIALOG(LSSTRING(@"success_resetpass"));
            [[self resetPassButton] setEnabled:YES];
            [[self password] setText:@""];
            [[self passwordConfirm] setText:@""];
            [[self navigationController] pushViewController:[self signInView] animated:YES];
        } errorHandler:^(NSError *error) {
            //
            APP_ALERT_DIALOG(LSSTRING(@"error_resetpass"));
            [[self resetPassButton] setEnabled:YES];
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
    
    [[self password] setText:@""];
    [[self passwordConfirm] setText:@""];
    [[self infoLabel] setText:@""];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    [self resetForm];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


