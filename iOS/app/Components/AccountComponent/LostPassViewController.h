//
//  LostPassViewController.h
//  app
//
//  Created by Joel Oliveira on 17/05/14.
//  Copyright (c) 2014 Notificare. All rights reserved.
//

#import "NotificareComponentViewController.h"
#import <UIKit/UIKit.h>
#import "FormField.h"
#import "FormButton.h"
#import "InfoLabel.h"

@interface LostPassViewController : NotificareComponentViewController <UITextFieldDelegate>

- (id)initWithNibName:(NSString *) nibNameOrNil
               bundle:(NSBundle *) nibBundleOrNil
       viewProperties:(NSDictionary *) lostPassProperties
            titleFont:(UIFont *) titleFont
           titleColor:(UIColor *) titleColor
 navigationBarBgColor:(UIColor *) navigationBarBgColor
 navigationBarFgColor:(UIColor *) navigationBarFgColor
          viewBgColor:(UIColor *) viewBgColor;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet FormField * email;
@property (nonatomic, strong) IBOutlet FormButton * forgotPassButton;
@property (nonatomic, strong) IBOutlet InfoLabel * infoLabel;
@property (nonatomic, strong) FormField *activeField;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *navigationBackgroundColor;
@property (nonatomic, strong) UIColor *navigationForegroundColor;
@property (nonatomic, strong) UIColor *viewBackgroundColor;
@property (nonatomic, strong) NSDictionary *lostPassProperties;

-(IBAction)recoverPassword:(id)sender;

@end
