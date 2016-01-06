//
//  SignInViewController.h
//  app
//
//  Created by Joel Oliveira on 16/05/14.
//  Copyright (c) 2014 Notificare. All rights reserved.
//

#import "NotificareComponentViewController.h"
#import <UIKit/UIKit.h>
#import "SignUpViewController.h"
#import "LostPassViewController.h"
#import "FormButton.h"
#import "FormField.h"
#import "InfoLabel.h"
#import "BadgeLabel.h"
#import "FormButtonTransparent.h"

@class SignUpViewController;
@class LostPassViewController;

@interface SignInViewController : NotificareComponentViewController <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet FormField * email;
@property (nonatomic, strong) IBOutlet FormField * password;
@property (nonatomic, strong) IBOutlet FormButton * signinButton;
@property (nonatomic, strong) IBOutlet FormButtonTransparent * forgotPasswordButton;
@property (nonatomic, strong) IBOutlet FormButton * createAccountButton;
@property (nonatomic, strong) IBOutlet InfoLabel * infoLabel;
@property (nonatomic, strong) IBOutlet UIView * badge;
@property (nonatomic, strong) IBOutlet BadgeLabel * badgeNr;
@property (nonatomic, strong) IBOutlet UIButton * badgeButton;
@property (nonatomic, strong) IBOutlet UIImageView * buttonIcon;
@property (nonatomic, strong) SignUpViewController * signUpView;
@property (nonatomic, strong) LostPassViewController * lostpassView;
@property (nonatomic, strong) FormField *activeField;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *navigationBackgroundColor;
@property (nonatomic, strong) UIColor *navigationForegroundColor;
@property (nonatomic, strong) UIColor *viewBackgroundColor;
@property (nonatomic, strong) NSDictionary *signInProperties;
@property (nonatomic, strong) NSDictionary *signUpProperties;
@property (nonatomic, strong) NSDictionary *lostPassProperties;

-(IBAction)doLogin:(id)sender;
-(IBAction)forgottenPassword:(id)sender;
-(IBAction)goToCreateAccount:(id)sender;

@end