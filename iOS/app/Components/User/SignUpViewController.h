//
//  SignUpViewController.h
//  app
//
//  Created by Joel Oliveira on 17/05/14.
//  Copyright (c) 2014 Notificare. All rights reserved.
//

#import "NotificareComponentViewController.h"
#import <UIKit/UIKit.h>
#import "FormButton.h"
#import "FormField.h"
#import "InfoLabel.h"

@interface SignUpViewController : NotificareComponentViewController <UITextFieldDelegate>

- (id)initWithNibName:(NSString *) nibNameOrNil
               bundle:(NSBundle *) nibBundleOrNil
       viewProperties:(NSDictionary *) signUpProperties
            titleFont:(UIFont *) titleFont
           titleColor:(UIColor *) titleColor
 navigationBarBgColor:(UIColor *) navigationBarBgColor
 navigationBarFgColor:(UIColor *) navigationBarFgColor
          viewBgColor:(UIColor *) viewBgColor;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet FormField *name;
@property (nonatomic, strong) IBOutlet FormField *email;
@property (nonatomic, strong) IBOutlet FormField *password;
@property (nonatomic, strong) IBOutlet FormField *passwordConfirm;
@property (nonatomic, strong) IBOutlet FormButton *signupButton;
@property (nonatomic, strong) IBOutlet FormButton *goBackButton;
@property (nonatomic, strong) IBOutlet InfoLabel *infoLabel;
@property (nonatomic, strong) FormField *activeField;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *navigationBackgroundColor;
@property (nonatomic, strong) UIColor *navigationForegroundColor;
@property (nonatomic, strong) UIColor *viewBackgroundColor;
@property (nonatomic, strong) NSDictionary *signUpProperties;

-(IBAction)createAccount:(id)sender;

@end
