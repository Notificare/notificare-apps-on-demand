//
//  UserDetailsViewController.h
//  app
//
//  Created by Joel Oliveira on 18/05/14.
//  Copyright (c) 2014 Notificare. All rights reserved.
//

#import "NotificareComponentViewController.h"
#import <UIKit/UIKit.h>
#import "InfoLabel.h"
#import "FormButton.h"
#import "FormField.h"
#import "BadgeLabel.h"
#import "SignInViewController.h"
#import "UserDetailsOptionsViewController.h"
#import "NotificareUser.h"
#import <MessageUI/MessageUI.h>

@class SignInViewController;
@class UserDetailsOptionsViewController;

@interface UserDetailsViewController : NotificareComponentViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) IBOutlet InfoLabel * userName;
@property (nonatomic, strong) IBOutlet InfoLabel * userToken;
@property (nonatomic, strong) IBOutlet InfoLabel * userEmail;
@property (nonatomic, strong) IBOutlet FormField * password;
@property (nonatomic, strong) IBOutlet FormField * passwordConfirm;
@property (nonatomic, strong) IBOutlet FormButton * changePassButton;
@property (nonatomic, strong) IBOutlet FormButton * generateTokenButton;
@property (nonatomic, strong) IBOutlet FormButton * logoutButton;
@property (nonatomic, strong) IBOutlet UIView * badge;
@property (nonatomic, strong) IBOutlet BadgeLabel * badgeNr;
@property (nonatomic, strong) IBOutlet UIButton * badgeButton;
@property (nonatomic, strong) IBOutlet UIImageView * buttonIcon;
@property (nonatomic, strong) IBOutlet UITableView * tableView;
@property (nonatomic, strong) IBOutlet UITableViewController * tableViewController;
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) NSMutableArray * navSections;
@property (nonatomic, strong) NSMutableArray * sectionTitles;
@property (nonatomic, strong) NSMutableArray * segments;
@property (nonatomic, strong) NotificareUser * user;
@property (nonatomic, strong) MFMailComposeViewController *mailComposer;
@property (nonatomic, strong) SignInViewController * signInView;
@property (nonatomic, strong) UserDetailsOptionsViewController * optionsView;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *viewBackgroundColor;
@property (nonatomic, strong) UIColor *navigationBackgroundColor;
@property (nonatomic, strong) UIColor *navigationForegroundColor;
@property (nonatomic, strong) NSDictionary *userDetailsProperties;

-(IBAction)generateToken:(id)sender;
-(IBAction)changePass:(id)sender;
-(IBAction)logout:(id)sender;

@end
