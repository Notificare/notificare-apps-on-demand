//
//  NotificareComponentViewController.m
//  app
//
//  Created by Aernout Peeters on 16-12-2015.
//  Copyright © 2015 Notificare. All rights reserved.
//

#import "NotificareComponentViewController.h"

#import "Configuration.h"
#import "AppDelegate.h"
#import "NotificarePushLib.h"
#import "UIColor+Hex.h"
#import "NSDictionary+Merge.h"
#import "IIViewDeckController.h"
#import "BadgeLabel.h"

@interface NotificareComponentViewController ()

@property (nonatomic, strong) IBOutlet UIView *badge;
@property (nonatomic, strong) IBOutlet BadgeLabel *badgeNr;
@property (nonatomic, strong) IBOutlet UIButton *badgeButton;
@property (nonatomic, strong) IBOutlet UIImageView *buttonIcon;

@end


@implementation NotificareComponentViewController

+ (NSString *)configurationKey {
    return nil;
}

- (AppDelegate *)appDelegate {
    
    return (AppDelegate *)UIApplication.sharedApplication.delegate;
}

- (NotificarePushLib *)notificarePushLib {
    
    return [NotificarePushLib shared];
}

- (void)loadDefaultConfiguration {
    NSDictionary *componentConfigurations = [[Configuration shared] getDictionary:@"components"];
    
    // set configuration to default dictionary first
    _configuration = componentConfigurations[@"default"];
    
    //try to get default configuration
    NSString *configurationKey = [[self class] configurationKey];
    
    if (configurationKey && configurationKey.length > 0) {
        NSDictionary *configuration = componentConfigurations[configurationKey];
        
        if (configuration) {
            _configuration = [_configuration merge:configuration];
        }
        else {
            NSLog(@"Could not load default configuration for component: %@", configurationKey);
        }
    }
    else {
        NSLog(@"Missing component configuration key");
    }
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self loadDefaultConfiguration];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self loadDefaultConfiguration];
    }
    
    return self;
}

- (instancetype)initWithConfiguration:(NSDictionary * _Nonnull)configuration {
    self = [super init];
    
    if (self) {
        [self loadDefaultConfiguration];
        _configuration = [_configuration merge:configuration];
    }
    
    return self;
}

- (void)setupTitle {
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    titleView.text = LSSTRING(self.configuration[@"title"][@"text"]);
    titleView.font = [UIFont fontWithName:self.configuration[@"title"][@"font"] size:[self.configuration[@"title"][@"fontSize"] floatValue]];
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.textColor = [UIColor colorWithHexString:self.configuration[@"title"][@"color"]];
    
    [self.navigationItem setTitleView:titleView];
}

- (void)setupNavigationBar {
    UIColor *foregroundColor = [UIColor colorWithHexString:self.configuration[@"navigationBar"][@"foregroundColor"]];
    UIColor *backgroundColor = [UIColor colorWithHexString:self.configuration[@"navigationBar"][@"backgroundColor"]];
    
    self.navigationController.navigationBar.barTintColor = backgroundColor;
    
    int count = self.notificarePushLib.myBadge;
    
    if (count > 0) {
        self.buttonIcon.tintColor = foregroundColor;
        [self.badgeButton addTarget:self.viewDeckController action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
        
        self.badgeNr.text = [NSString stringWithFormat:@"%i", count];
        
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:self.badge];
        leftButton.target = self.viewDeckController;
        leftButton.action = @selector(toggleLeftView);
        leftButton.tintColor = foregroundColor;
        
        self.navigationItem.leftBarButtonItem = leftButton;
    }
    else {
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"LeftMenuIcon"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self.viewDeckController
                                                                      action:@selector(toggleLeftView)];
        leftButton.tintColor = foregroundColor;
        [[self navigationItem] setLeftBarButtonItem:leftButton];
    }
    
    if (self.appDelegate.beacons.count > 0) {
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"RightMenuIcon"]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self.viewDeckController
                                                                       action:@selector(toggleRightView)];
        
        rightButton.tintColor = foregroundColor;
        
        self.navigationItem.rightBarButtonItem = rightButton;
        
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)setupBackground {
    self.view.backgroundColor = [UIColor colorWithHexString:self.configuration[@"background"][@"color"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTitle];
    [self setupNavigationBar];
    [self setupBackground];
}


@end
