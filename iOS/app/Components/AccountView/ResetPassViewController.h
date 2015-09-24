//
//  ResetPassViewController.h
//  app
//
//  Created by Joel Oliveira on 18/05/14.
//  Copyright (c) 2014 Notificare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormField.h"
#import "FormButton.h"
#import "InfoLabel.h"
#import "SignInViewController.h"


@class SignInViewController;

@interface ResetPassViewController : UIViewController <UITextFieldDelegate>

- (id)initWithNibName:(NSString *) nibNameOrNil
               bundle:(NSBundle *) nibBundleOrNil
       viewProperties:(NSDictionary *) resetPassProperties
     signInProperties:(NSDictionary *) signInProperties
     signUpProperties:(NSDictionary *) signUpProperties
            titleFont:(UIFont *) titleFont
           titleColor:(UIColor *) titleColor
 navigationBarBgColor:(UIColor *) navigationBarBgColor
 navigationBarFgColor:(UIColor *) navigationBarFgColor
          viewBgColor:(UIColor *) viewBgColor;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet FormField * password;
@property (nonatomic, strong) IBOutlet FormField * passwordConfirm;
@property (nonatomic, strong) IBOutlet FormButton * resetPassButton;
@property (nonatomic, strong) IBOutlet InfoLabel * infoLabel;
@property (nonatomic, strong) SignInViewController * signInView;
@property (nonatomic, strong) FormField *activeField;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *navigationBackgroundColor;
@property (nonatomic, strong) UIColor *navigationForegroundColor;
@property (nonatomic, strong) UIColor *viewBackgroundColor;
@property (nonatomic, strong) NSDictionary *resetPassProperties;
@property (nonatomic, strong) NSDictionary *signInProperties;
@property (nonatomic, strong) NSDictionary *signUpProperties;
@property (nonatomic, strong) NSString * token;

-(IBAction)resetPassword:(id)sender;


@end
