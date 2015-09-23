//
//  LostPassViewController.m
//  app
//
//  Created by Joel Oliveira on 17/05/14.
//  Copyright (c) 2014 Notificare. All rights reserved.
//

#import "LostPassViewController.h"
#import "NotificarePushLib.h"
#import "AppDelegate.h"
#import "IIViewDeckController.h"
#import "UIColor+NSDictionary.h"

@interface LostPassViewController ()

@end

@implementation LostPassViewController



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
    [title setText:LSSTRING(@"title_lostpass")];
    [title setFont:[self titleFont]];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setTextColor:[self titleColor]];
    [[self navigationItem] setTitleView:title];
    
    [[self view] setBackgroundColor:[self viewBackgroundColor]];
    
    [self resetForm];

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
    
    // Recover Password Button
    NSDictionary *forgotPassButtonProperties = [[self signUpProperties] objectForKey:@"createAccountButton"];
    [[self forgotPassButton] setTitle:LSSTRING(@"button_forgotpass") forState:UIControlStateNormal];
    [[[self forgotPassButton] titleLabel] setFont:[UIFont fontWithName:[forgotPassButtonProperties objectForKey:@"textFont"] size:[[forgotPassButtonProperties objectForKey:@"textSize"] doubleValue]]];
    [[self forgotPassButton] setTitleColor:[UIColor colorFromRgbaDictionary:[forgotPassButtonProperties objectForKey:@"textColor"]] forState:UIControlStateNormal];
    [[self forgotPassButton] setBackgroundColor:[UIColor colorFromRgbaDictionary:[forgotPassButtonProperties objectForKey:@"backgroundColor"]]];
    [[[self forgotPassButton] titleLabel] setShadowColor:[UIColor blackColor]];
    [self forgotPassButton].layer.cornerRadius= [[forgotPassButtonProperties objectForKey:@"cornerRadius"] doubleValue];
    [self forgotPassButton].layer.borderColor= [[UIColor colorFromRgbaDictionary:[forgotPassButtonProperties objectForKey:@"borderColor"]] CGColor];
    [self forgotPassButton].layer.borderWidth= [[forgotPassButtonProperties objectForKey:@"borderWidth"] doubleValue];

    [[self forgotPassButton] setTitle:LSSTRING(@"button_forgotpass") forState:UIControlStateNormal];

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


-(IBAction)recoverPassword:(id)sender{
    [[self forgotPassButton] setEnabled:NO];
    
    if (![[self email] text]) {
        APP_ALERT_DIALOG(LSSTRING(@"error_forgotpass_invalid_email"));
        [[self forgotPassButton] setEnabled:YES];
    } else {
        [[self notificare] sendPassword:[[self email] text] completionHandler:^(NSDictionary *info) {

            APP_ALERT_DIALOG(LSSTRING(@"success_forgotpass"));
            [[self forgotPassButton] setEnabled:YES];
            [[self email] setText:@""];
            [[self email] resignFirstResponder];
            [[self navigationController] popToRootViewControllerAnimated:YES];
        } errorHandler:^(NSError *error) {
            //
            APP_ALERT_DIALOG(LSSTRING(@"error_forgotpass"));
            [[self forgotPassButton] setEnabled:YES];
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

    [[self email] setText:@""];
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
