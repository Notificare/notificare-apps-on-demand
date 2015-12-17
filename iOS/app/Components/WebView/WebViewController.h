//
//  WebViewController.h
//  app
//
//  Created by Joel Oliveira on 02/12/14.
//  Copyright (c) 2014 Notificare. All rights reserved.
//

#import "NotificareComponentViewController.h"
#import <UIKit/UIKit.h>
#import "BadgeLabel.h"

@interface WebViewController : NotificareComponentViewController <UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView * webView;
@property (nonatomic, strong) IBOutlet UIToolbar * toolbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem * backButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem * forwardButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem * refreshButton;
@property (nonatomic, strong) IBOutlet UIView * badge;
@property (nonatomic, strong) IBOutlet BadgeLabel * badgeNr;
@property (nonatomic, strong) IBOutlet UIButton * badgeButton;
@property (nonatomic, strong) IBOutlet UIImageView * buttonIcon;
@property (nonatomic, strong) IBOutlet UIView *loadingView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) NSString * viewTitle;
@property (nonatomic, strong) NSString * targetUrl;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *loadingViewColor;
@property (nonatomic, strong) UIColor *navigationBackgroundColor;
@property (nonatomic, strong) UIColor *navigationForegroundColor;
@property (nonatomic, strong) UIColor *toolbarBackgroundColor;
@property (nonatomic, strong) UIColor *toolbarForegroundColor;

@end
