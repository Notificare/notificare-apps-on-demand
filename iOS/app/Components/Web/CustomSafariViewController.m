//
//  CustomSafariViewController.m
//
//  Created by Aernout Peeters on 21-09-2015.
//  Copyright © 2015 Notificare. All rights reserved.
//

#import "CustomSafariViewController.h"

#import "IIViewDeckController.h"
#import "AppDelegate.h"
#import "BadgeLabel.h"
#import "NotificarePushLib.h"
#import "BadgeViewController.h"

@interface CustomSafariViewController ()

@end

@implementation CustomSafariViewController

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (instancetype)initWithURL:(NSURL *)URL {
    self = [super initWithURL:URL];
    
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    [title setText:[self viewTitle]];
    [title setFont:[UIFont fontWithName:@"Arial-BoldMT" size:18]];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setTextColor:ICONS_COLOR];
    [[self navigationItem] setTitleView:title];
    
    self.navigationController.navigationBar.barTintColor = MAIN_COLOR;
    self.navigationController.navigationBar.translucent = YES;
    
    /*UIBarButtonItem * leftButton;
    if (self.navigationController.isBeingPresented) {
        leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"LeftCloseIcon"]
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(close)];
    }
    else {
        leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"LeftMenuIcon"]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:[self viewDeckController]
                                                                       action:@selector(toggleLeftView)];
    }
    
    [leftButton setTintColor:ICONS_COLOR];
    [[self navigationItem] setLeftBarButtonItem:leftButton];*/
    
    [self setupNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBadge) name:@"incomingNotification" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"incomingNotification"
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNavigationBar {
    int count = [[NotificarePushLib shared] myBadge];
    
    if(count > 0){
        BadgeViewController *badgeVC = [[BadgeViewController alloc] init];
        
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:badgeVC.view];
        [leftButton setTarget:[self viewDeckController]];
        [leftButton setAction:@selector(toggleLeftView)];
        [leftButton setTintColor:ICONS_COLOR];
        [[self navigationItem] setLeftBarButtonItem:leftButton];
    }
    else {
        
        UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"LeftMenuIcon"] style:UIBarButtonItemStylePlain target:[self viewDeckController] action:@selector(toggleLeftView)];
        [leftButton setTintColor:ICONS_COLOR];
        [[self navigationItem] setLeftBarButtonItem:leftButton];
        
    }
}

-(void)changeBadge{
    
    [self setupNavigationBar];
    
}

- (void)close {
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}


@end
