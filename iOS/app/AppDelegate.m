//
//  AppDelegate.m
//  app
//
//  Created by Joel Oliveira on 16/04/14.
//  Copyright (c) 2014 Notificare. All rights reserved.
//

#import "AppDelegate.h"
#import "IIViewDeckController.h"
#import "MainViewController.h"
#import "PageThreeViewController.h"
#import "WebViewController.h"
#import "RightViewController.h"
#import "LeftViewController.h"
#import "LocationViewController.h"
#import "SignInViewController.h"
#import "UserDetailsViewController.h"
#import "ResetPassViewController.h"
#import "ProductsViewController.h"
#import "LogViewController.h"
#import "NSData+Hex.h"
#import "Configuration.h"
#import "NotificareDevice.h"
#import "UIColor+Hex.h"
#import "PassesViewController.h"
#import "OnboardingManager.h"


@interface AppDelegate () <OnboardingManagerDelegate>

@property (strong, nonatomic) OnboardingManager *onboardingManager;

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    if([[[Configuration shared] getProperty:@"host"] length] > 0){
        [self setApiEngine:[[ApiEngine alloc]
                            initWithHostName:[[Configuration shared] getProperty:@"host"]
                            customHeaderFields:nil]];
        
        [[self apiEngine] useCache];
        
        //[UIImageView setDefaultEngine:[self apiEngine]];
    }

    [self configureApp];
    [self setLog:[NSMutableArray array]];
    [self setCachedNotifications:[NSMutableArray array]];
    [self setBeacons:[NSMutableArray array]];
    [self setRegions:[NSMutableArray array]];
    
    [[NotificarePushLib shared] launch];
    [[NotificarePushLib shared] setDelegate:self];
    //[[NotificarePushLib shared] setShouldAlwaysLogBeacons:YES];
    
    [[NotificarePushLib shared] handleOptions:launchOptions];
    
    [self setNotificarePushLib:[NotificarePushLib shared]];
    
    IIViewDeckController* deckController = [self generateControllerStack];
    self.leftController = deckController.leftController;
    self.centerController = deckController.centerController;
    [self.window setRootViewController:deckController];
    
    NSLog(@"FENCES: %@", [[NotificarePushLib shared] currentRegions]);
    NSLog(@"BEACONS: %@", [[NotificarePushLib shared] currentBeacons]);

    //[self performSelector:@selector(createNotification) withObject:nil afterDelay:4.0];
    
    self.onboardingManager = [OnboardingManager shared];
    self.onboardingManager.delegate = self;
    [self.onboardingManager setVisible:YES animated:NO];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void) configureApp {
    
    NSDictionary *appSettings = [[Configuration shared] getDictionary:@"appSettings"];
    
    if ([appSettings[@"statusBarWhite"] boolValue]) {
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
    } else {
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
}


//-(void)createNotification{
//    UIApplication* app = [UIApplication sharedApplication];
//    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
//    localNotification.fireDate = [NSDate new];
//    localNotification.alertBody = @"MY Body ";
//    localNotification.alertAction = @"My Title";
//    localNotification.userInfo = @{@"id":@"54c6a6ba8333b10a315e80e1"};
//    localNotification.timeZone = [NSTimeZone defaultTimeZone];
//    localNotification.soundName = UILocalNotificationDefaultSoundName;
//    
//    [app scheduleLocalNotification:localNotification];
//}

- (IIViewDeckController*)generateControllerStack {
    
    [self setLeftController:[[LeftViewController alloc] initWithNibName:@"LeftViewController" bundle:nil]];
    [self setRightController:[[RightViewController alloc] initWithNibName:@"RightViewController" bundle:nil]];
    
    PageThreeViewController *pageThreeViewController = [[PageThreeViewController alloc] init];
    self.centerController = [[UINavigationController alloc] initWithRootViewController:pageThreeViewController];
    
   
    [self setDeckController:[[IIViewDeckController alloc] initWithCenterViewController:[self centerController]
                                                                    leftViewController:[self leftController]
                                                                   rightViewController:[self rightController]]];
        //deckController.rightSize = 100;
        
        //[[self deckController] disablePanOverViewsOfClass:NSClassFromString(@"_UITableViewHeaderFooterContentView")];
        return [self deckController];

}


- (void)notificarePushLib:(NotificarePushLib *)library onReady:(NSDictionary *)info{

    
    //NSLog(@"App Info: %@",[[NotificarePushLib shared] applicationInfo]);
    
#if TARGET_IPHONE_SIMULATOR
    
    //Simulator
    [[NotificarePushLib shared] registerUserNotifications];
    
#else
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];

    
    [settings setBool:NO forKey:@"re.notifica.office.prod2"];
    [settings synchronize];
    
    if (self.onboardingManager.completedNotifications) {

        [[NotificarePushLib shared] registerForNotifications];
    }

    
#endif
    
}


-(void)refreshMainController{
//    IIViewDeckController* deckController = [self generateControllerStack];
//    self.leftController = deckController.leftController;
//    self.centerController = deckController.centerController;
//    [self.window setRootViewController:deckController];
}


-(void)handleNavigation:(NSDictionary *)item{
    
    
    [[self deckController] toggleLeftViewAnimated:YES completion:^(IIViewDeckController *controller, BOOL success) {
        
        
        if ([[item objectForKey:@"url"] hasPrefix:@"http://"] || [[item objectForKey:@"url"] hasPrefix:@"https://"]) {
            
            WebViewController * main = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
            
            [main setViewTitle:LSSTRING([item objectForKey:@"label"])];
            [main setTargetUrl:[item objectForKey:@"url"]];
            [main setTitleFont:[UIFont fontWithName:[item objectForKey:@"titleFont"] size:[[item objectForKey:@"titleSize"] doubleValue]]];
            [main setTitleColor:[UIColor colorWithHexString:[item objectForKey:@"titleColor"]]];
            [main setNavigationBackgroundColor:[UIColor colorWithHexString:[item objectForKey:@"navigationBgColor"]]];
            [main setNavigationForegroundColor:[UIColor colorWithHexString:[item objectForKey:@"navigationFgColor"]]];
            [main setLoadingViewColor:[UIColor colorWithHexString:[item objectForKey:@"loadingViewColor"]]];
            [main setToolbarBackgroundColor:[UIColor colorWithHexString:[item objectForKey:@"toolbarBgColor"]]];
            [main setToolbarForegroundColor:[UIColor colorWithHexString:[item objectForKey:@"toolbarFgColor"]]];
            
            [self setCenterController:[[UINavigationController alloc] initWithRootViewController:main]];
            
            [[self deckController] setCenterController:[self centerController]];
            
        } else {
            //Check which Native Action to perform
            
            if ([[item objectForKey:@"url"] hasPrefix:@"IBAction:"]){
                //Call a method in delegate (used for the settings)

                NSString * method = [[item objectForKey:@"url"] stringByReplacingOccurrencesOfString:@"IBAction:" withString:@""];
                SEL mySelector = NSSelectorFromString(method);
                if([self respondsToSelector:mySelector]){
                    Suppressor([self performSelector:mySelector]);
                }
  
            } else if ([[item objectForKey:@"url"] hasPrefix:@"Auth:"]){
                //Call a method in delegate (used for the settings)
                

                if([[NotificarePushLib shared] isLoggedIn]){
                    
                    UserDetailsViewController * userDetails = [[UserDetailsViewController alloc] initWithNibName:@"UserDetailsViewController" bundle:nil];
                    
                    [userDetails setTitleFont:[UIFont fontWithName:[item objectForKey:@"titleFont"] size:[[item objectForKey:@"titleSize"] doubleValue]]];
                    [userDetails setTitleColor:[UIColor colorWithHexString:[item objectForKey:@"titleColor"]]];
                    [userDetails setNavigationBackgroundColor:[UIColor colorWithHexString:[item objectForKey:@"navigationBgColor"]]];
                    [userDetails setNavigationForegroundColor:[UIColor colorWithHexString:[item objectForKey:@"navigationFgColor"]]];
                    [userDetails setViewBackgroundColor:[UIColor colorWithHexString:[item objectForKey:@"backgroundColor"]]];
                    [userDetails setUserDetailsProperties:[item objectForKey:@"userDetails"]];
                  
                    [self setCenterController:[[UINavigationController alloc] initWithRootViewController:userDetails]];
                    
                } else {
#warning Consider using a configuration dictionary
                    SignInViewController *signInVC = [[SignInViewController alloc] init];
                    
                    /*SignInViewController * login = [[SignInViewController alloc] initWithNibName:@"SignInViewController" bundle:nil];
                    
                    [login setTitleFont:[UIFont fontWithName:[item objectForKey:@"titleFont"] size:[[item objectForKey:@"titleSize"] doubleValue]]];
                    [login setTitleColor:[UIColor colorWithHexString:[item objectForKey:@"titleColor"]]];
                    [login setNavigationBackgroundColor:[UIColor colorWithHexString:[item objectForKey:@"navigationBgColor"]]];
                    [login setNavigationForegroundColor:[UIColor colorWithHexString:[item objectForKey:@"navigationFgColor"]]];
                    [login setViewBackgroundColor:[UIColor colorWithHexString:[item objectForKey:@"backgroundColor"]]];
                    [login setSignInProperties:[item objectForKey:@"signIn"]];
                    [login setSignUpProperties:[item objectForKey:@"signUp"]];
                    [login setLostPassProperties:[item objectForKey:@"forgottenPassword"]];*/
                    
                    [self setCenterController:[[UINavigationController alloc] initWithRootViewController:signInVC]];
                }
                
                
                
                [[self deckController] setCenterController:[self centerController]];
                
            } else if ([[item objectForKey:@"url"] hasPrefix:@"MKMapView:"]){
                
                
                LocationViewController * map = [[LocationViewController alloc] initWithNibName:@"LocationViewController" bundle:nil];
                
                /*[map setShowCircles:(BOOL)[item objectForKey:@"showCircles"]];
                [map setViewTitle:LSSTRING([item objectForKey:@"label"])];
                [map setTitleFont:[UIFont fontWithName:[item objectForKey:@"titleFont"] size:[[item objectForKey:@"titleSize"] doubleValue]]];
                [map setTitleColor:[UIColor colorWithHexString:[item objectForKey:@"titleColor"]]];
                [map setNavigationBackgroundColor:[UIColor colorWithHexString:[item objectForKey:@"navigationBgColor"]]];
                [map setNavigationForegroundColor:[UIColor colorWithHexString:[item objectForKey:@"navigationFgColor"]]];
                [map setCircleColor:[UIColor colorWithHexString:[item objectForKey:@"circleColor"]]];*/
                
                [self setCenterController:[[UINavigationController alloc] initWithRootViewController:map]];
                [[self deckController] setCenterController:[self centerController]];
                
            } else if ([[item objectForKey:@"url"] hasPrefix:@"Products:"]){
                
                
                ProductsViewController * prods = [[ProductsViewController alloc] initWithNibName:@"ProductsViewController" bundle:nil];
                
                [self setCenterController:[[UINavigationController alloc] initWithRootViewController:prods]];
                [[self deckController] setCenterController:[self centerController]];
                
                APP_ALERT_DIALOG(LSSTRING(@"disabled_for_demo_in_app_purchases"));
                
            }  else if ([[item objectForKey:@"url"] hasPrefix:@"Log:"]){
                
                
                LogViewController * log = [[LogViewController alloc] initWithNibName:@"LogViewController" bundle:nil];
                
                [self setCenterController:[[UINavigationController alloc] initWithRootViewController:log]];
                [[self deckController] setCenterController:[self centerController]];
                
                
            } else if ([[item objectForKey:@"url"] hasPrefix:@"MainView:"]){
                PageThreeViewController *pageThreeViewController = [[PageThreeViewController alloc] init];
                self.deckController.centerController = [[UINavigationController alloc] initWithRootViewController:pageThreeViewController];
                
            } else if ([[item objectForKey:@"url"] hasPrefix:@"Passes:"]) {
                PassesViewController *passesVC = [[PassesViewController alloc] init];
                self.deckController.centerController = [[UINavigationController alloc] initWithRootViewController:passesVC];
            }
            
        }
        
        
    }];
    

}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	[[NotificarePushLib shared]  handleOpenURL:url];
    return YES;
}


#pragma General Methods

-(void)openPreferences{
    [[NotificarePushLib shared] openUserPreferences];
}

-(void)openInbox{
    [[NotificarePushLib shared] openInbox];
}

-(void)openBeacons{
    [[NotificarePushLib shared] openBeacons];
}

-(void)addToLog:(NSDictionary *)event{
    NSMutableDictionary * tempLog = [NSMutableDictionary dictionaryWithDictionary:event];
    [tempLog setObject:[NSDate new] forKey:@"date"];
    [[self log] addObject:tempLog];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLog" object:nil];
}

#pragma Notificare OAuth2 delegates

- (void)notificarePushLib:(NotificarePushLib *)library didChangeAccountNotification:(NSDictionary *)info{
    NSLog(@"didChangeAccountNotification: %@",info);
    
    /*UserDetailsViewController * userDetailsView = [[UserDetailsViewController alloc] initWithNibName:@"UserDetailsViewController" bundle:nil];
    
    NSDictionary *appSettings = [[Configuration shared] getDictionary:@"appSettings"];
    
    NSDictionary *accountViewProperties = [appSettings objectForKey:@"accountView"];
    
    [userDetailsView setTitleFont:[UIFont fontWithName:[accountViewProperties objectForKey:@"titleFont"] size:[[accountViewProperties objectForKey:@"titleSize"] doubleValue]]];
    [userDetailsView setTitleColor:[UIColor colorWithHexString:[accountViewProperties objectForKey:@"titleColor"]]];
    [userDetailsView setNavigationBackgroundColor:[UIColor colorWithHexString:[accountViewProperties objectForKey:@"navigationBgColor"]]];
    [userDetailsView setNavigationForegroundColor:[UIColor colorWithHexString:[accountViewProperties objectForKey:@"navigationFgColor"]]];
    [userDetailsView setViewBackgroundColor:[UIColor colorWithHexString:[accountViewProperties objectForKey:@"backgroundColor"]]];
    [userDetailsView setUserDetailsProperties:(NSDictionary *)[accountViewProperties objectForKey:@"userDetails"]];
    
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:userDetailsView];
    [self setCenterController:navigationController];
    [[self deckController] setCenterController:[self centerController]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changedAccount" object:nil];*/
    
    [self.onboardingManager update];
    
    NSMutableDictionary * tmpLog = [NSMutableDictionary dictionary];
    [tmpLog setObject:@"didChangeAccountNotification" forKey:@"event"];
    [tmpLog setObject:[NSString stringWithFormat:@"Account: %@",info] forKey:@"data"];
    
    [self addToLog:tmpLog];
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailToRequestAccessNotification:(NSError *)error{
    [self.onboardingManager update];
    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changedAccount" object:nil];
    
    NSMutableDictionary * tmpLog = [NSMutableDictionary dictionary];
    [tmpLog setObject:@"didFailToRequestAccessNotification" forKey:@"event"];
    [tmpLog setObject:[NSString stringWithFormat:@"Error: %@",[error description]] forKey:@"data"];
    
    [self addToLog:tmpLog];
}


- (void)notificarePushLib:(NotificarePushLib *)library didReceiveActivationToken:(NSString *)token{
    
    [[NotificarePushLib shared] validateAccount:token completionHandler:^(NSDictionary *info) {
        
        /*SignInViewController * signInView = [[SignInViewController alloc] initWithNibName:@"SignInViewController" bundle:nil];
        
        NSDictionary *appSettings = [[Configuration shared] getDictionary:@"appSettings"];
        
        NSDictionary *accountViewProperties = [appSettings objectForKey:@"accountView"];
        NSDictionary *signInProperties = [accountViewProperties objectForKey:@"signIn"];
        NSDictionary *signUpProperties = [accountViewProperties objectForKey:@"signUp"];
        NSDictionary *lostPassProperties = [accountViewProperties objectForKey:@"forgottenPassword"];
        
        [signInView setTitleFont:[UIFont fontWithName:[accountViewProperties objectForKey:@"titleFont"] size:[[accountViewProperties objectForKey:@"titleSize"] doubleValue]]];
        [signInView setTitleColor:[UIColor colorWithHexString:[accountViewProperties objectForKey:@"titleColor"]]];
        [signInView setNavigationBackgroundColor:[UIColor colorWithHexString:[accountViewProperties objectForKey:@"navigationBgColor"]]];
        [signInView setNavigationForegroundColor:[UIColor colorWithHexString:[accountViewProperties objectForKey:@"navigationFgColor"]]];
        [signInView setViewBackgroundColor:[UIColor colorWithHexString:[accountViewProperties objectForKey:@"backgroundColor"]]];
        [signInView setSignInProperties:(NSDictionary *)[signInProperties objectForKey:@"signIn"]];
        [signInView setSignUpProperties:[signUpProperties objectForKey:@"signUp"]];
        [signInView setLostPassProperties:[lostPassProperties objectForKey:@"forgottenPassword"]];*/
        
#warning Consider using a configuration dictionary
        SignInViewController *signInVC = [[SignInViewController alloc] init];
        
        UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:signInVC];
        [self setCenterController:navigationController];
        [[self deckController] setCenterController:[self centerController]];
        
        APP_ALERT_DIALOG(LSSTRING(@"success_validate"));
        
    } errorHandler:^(NSError *error) {
        
        APP_ALERT_DIALOG(LSSTRING(@"error_validate"));
        
    }];
    
    NSMutableDictionary * tmpLog = [NSMutableDictionary dictionary];
    [tmpLog setObject:@"didReceiveActivationToken" forKey:@"event"];
    [tmpLog setObject:[NSString stringWithFormat:@"Token: %@",token] forKey:@"data"];

    [self addToLog:tmpLog];
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveResetPasswordToken:(NSString *)token{
    
    /*SignInViewController * login = [[SignInViewController alloc] initWithNibName:@"SignInViewController" bundle:nil];
    
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:login];
    
    NSDictionary *appSettings = [[Configuration shared] getDictionary:@"appSettings"];
    
    NSDictionary *accountViewProperties = [appSettings objectForKey:@"accountView"];
    NSDictionary *signInProperties = [accountViewProperties objectForKey:@"signIn"];
    NSDictionary *signUpProperties = [accountViewProperties objectForKey:@"signUp"];
    NSDictionary *lostPassProperties = [accountViewProperties objectForKey:@"forgottenPassword"];
    
    [login setTitleFont:[UIFont fontWithName:[accountViewProperties objectForKey:@"titleFont"] size:[[accountViewProperties objectForKey:@"titleSize"] doubleValue]]];
    [login setTitleColor:[UIColor colorWithHexString:[accountViewProperties objectForKey:@"titleColor"]]];
    [login setNavigationBackgroundColor:[UIColor colorWithHexString:[accountViewProperties objectForKey:@"navigationBgColor"]]];
    [login setNavigationForegroundColor:[UIColor colorWithHexString:[accountViewProperties objectForKey:@"navigationFgColor"]]];
    [login setViewBackgroundColor:[UIColor colorWithHexString:[accountViewProperties objectForKey:@"backgroundColor"]]];
    [login setSignInProperties:(NSDictionary *)[signInProperties objectForKey:@"signIn"]];
    [login setSignUpProperties:[signUpProperties objectForKey:@"signUp"]];
    [login setLostPassProperties:[lostPassProperties objectForKey:@"forgottenPassword"]];
    
    ResetPassViewController * resetPassView =
    [[ResetPassViewController alloc] initWithNibName:@"ResetPassViewController"
                                              bundle:nil
                                      viewProperties:[appSettings objectForKey:@"resetPasswordView"]
                                    signInProperties:signInProperties
                                    signUpProperties:signUpProperties
                                           titleFont:[UIFont fontWithName:[accountViewProperties objectForKey:@"titleFont"] size:[[accountViewProperties objectForKey:@"titleSize"] doubleValue]]
                                          titleColor:[UIColor colorWithHexString:[accountViewProperties objectForKey:@"titleColor"]]
                                navigationBarBgColor:[UIColor colorWithHexString:[accountViewProperties objectForKey:@"navigationBgColor"]]
                                navigationBarFgColor:[UIColor colorWithHexString:[accountViewProperties objectForKey:@"navigationFgColor"]]
                                         viewBgColor:[UIColor colorWithHexString:[accountViewProperties objectForKey:@"backgroundColor"]]];*/
    
#warning Consider using a configuraton dictionary 2x
    SignInViewController *signInVC = [[SignInViewController alloc] init];
    ResetPassViewController *resetPassVC = [[ResetPassViewController alloc] init];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:signInVC];
    
    [resetPassVC setToken:token];
    [navigationController pushViewController:resetPassVC animated:YES];
    
    [self setCenterController:navigationController];
    [[self deckController] setCenterController:[self centerController]];
    
    NSMutableDictionary * tmpLog = [NSMutableDictionary dictionary];
    [tmpLog setObject:@"didReceiveResetPasswordToken" forKey:@"event"];
    [tmpLog setObject:[NSString stringWithFormat:@"Token: %@",token] forKey:@"data"];
    
    [self addToLog:tmpLog];
}

#pragma APNS Delegates
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    //If you don't identify users you can just use this
    [[NotificarePushLib shared] registerDevice:deviceToken completionHandler:^(NSDictionary *info) {
        
        self.onboardingManager.deviceIsRegistered = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"registeredDevice" object:nil];

        if([[NotificarePushLib shared] checkLocationUpdates]){
            [[NotificarePushLib shared] startLocationUpdates];
        }
    
        [self addTags];

        
    } errorHandler:^(NSError *error) {
        //
      //  [self registerForAPNS];
        
    }];
    
    
    
    
}

#pragma APNS Delegates
- (void)notificarePushLib:(NotificarePushLib *)library didRegisterForWebsocketsNotifications:(NSString *)uuid {
    
    
    //If you don't identify users you can just use this
    [[NotificarePushLib shared] registerDeviceForWebsockets:uuid completionHandler:^(NSDictionary *info) {
        
        if([[NotificarePushLib shared] checkLocationUpdates]){
            [[NotificarePushLib shared] startLocationUpdates];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"startedLocationUpdate" object:nil];
        }
        
        
       // [self addTags];
        
    } errorHandler:^(NSError *error) {
        //
        //  [self registerForAPNS];
        
    }];
    
}


/////////////////////////////////
///New iOS8 delgates
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {

    
#if TARGET_IPHONE_SIMULATOR
    
    //Simulator
    [[NotificarePushLib shared] registerForWebsockets];
    
    
#endif
   
}


- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completion{

    [[NotificarePushLib shared] handleAction:identifier forNotification:userInfo withData:nil completionHandler:^(NSDictionary *info) {
        completion();
    } errorHandler:^(NSError *error) {
        completion();
    }];

    NSMutableDictionary * tmpLog = [NSMutableDictionary dictionary];
    [tmpLog setObject:@"handleActionWithIdentifier" forKey:@"event"];
    [tmpLog setObject:[NSString stringWithFormat:@"Action: %@",identifier] forKey:@"data"];

    
    [self addToLog:tmpLog];
}
#endif
/////////////////////////////////


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
    NSMutableDictionary * tmpLog = [NSMutableDictionary dictionary];
    [tmpLog setObject:@"didFailToRegisterForRemoteNotificationsWithError" forKey:@"event"];
     [tmpLog setObject:[NSString stringWithFormat:@"Error: %@",[error description]] forKey:@"data"];
    
    [self addToLog:tmpLog];
}



//For iOS6 - No inbox
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [[NotificarePushLib shared] openNotification:userInfo];
    
    NSMutableDictionary * tmpLog = [NSMutableDictionary dictionary];
    [tmpLog setObject:@"didReceiveRemoteNotification" forKey:@"event"];
    if([userInfo objectForKey:@"id"]){
        [tmpLog setObject:[userInfo objectForKey:@"id"] forKey:@"data"];
    }
    [self addToLog:tmpLog];
}


- (void)notificarePushLib:(NotificarePushLib *)library didReceiveWebsocketNotification:(NSDictionary *)info {
    NSLog(@"%@", info);
    [self createNotification:info];
    
}



 
// If you implement this delegate please add a remote-notification to your UIBackgroundModes in app's plist
// For iOS7 up - No inbox
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{

     [[NotificarePushLib shared] saveToInbox:userInfo forApplication:application completionHandler:^(NSDictionary *info) {

         completionHandler(UIBackgroundFetchResultNewData);
     } errorHandler:^(NSError *error) {

         completionHandler(UIBackgroundFetchResultNoData);
     }];
    
    NSMutableDictionary * tmpLog = [NSMutableDictionary dictionary];
    [tmpLog setObject:@"didReceiveRemoteNotification" forKey:@"event"];
    if([userInfo objectForKey:@"id"]){
        [tmpLog setObject:[userInfo objectForKey:@"id"] forKey:@"data"];
    }
    
    [self addToLog:tmpLog];
 }

- (void)notificarePushLib:(NotificarePushLib *)library didUpdateBadge:(int)badge{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"incomingNotification" object:nil];
}






-(void)createNotification:(NSDictionary*)notification{
    UIApplication* app = [UIApplication sharedApplication];
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate new];
    localNotification.alertBody = [notification objectForKey:@"alert"];
    localNotification.alertAction = @"OK";
    localNotification.userInfo = @{@"id":[notification objectForKey:@"id"],@"aps":@{@"alert":[notification objectForKey:@"alert"]}};
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [app scheduleLocalNotification:localNotification];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
//    NSMutableDictionary * payload = [NSMutableDictionary dictionaryWithDictionary:[notification userInfo]];
//    [payload setObject:@{@"alert":[[notification userInfo] objectForKey:@"alert"]} forKey:@"aps"];
    [[NotificarePushLib shared] openNotification:[notification userInfo]];
    
}



#pragma Tags
-(void)addTags{
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    

    //One time
    if([settings objectForKey:@"notificareAppInstall"] == nil || ![settings objectForKey:@"notificareAppInstall"]){
        
        [[NotificarePushLib shared] addTags:@[@"tag_press",@"tag_events",@"tag_newsletter"] completionHandler:^(NSDictionary *info) {
            //
        } errorHandler:^(NSError *error) {
            //
        }];
    }
    
    
    
}


#pragma Notificare delegates

- (void)notificarePushLib:(NotificarePushLib *)library willOpenNotification:(NotificareNotification *)notification{

}

- (void)notificarePushLib:(NotificarePushLib *)library didOpenNotification:(NotificareNotification *)notification{
 
    
}

- (void)notificarePushLib:(NotificarePushLib *)library didCloseNotification:(NotificareNotification *)notification{

    [[NSNotificationCenter defaultCenter] postNotificationName:@"closedNotification" object:nil];
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailToOpenNotification:(NotificareNotification *)notification{

    [[NSNotificationCenter defaultCenter] postNotificationName:@"closedNotification" object:nil];
}


- (void)notificarePushLib:(NotificarePushLib *)library willExecuteAction:(NotificareNotification *)notification{

}

- (void)notificarePushLib:(NotificarePushLib *)library didExecuteAction:(NSDictionary *)info{
    //NSLog(@"%@",info);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closedNotification" object:nil];
}

-(void)notificarePushLib:(NotificarePushLib *)library shouldPerformSelector:(NSString *)selector{
    SEL mySelector = NSSelectorFromString(selector);
    if([self respondsToSelector:mySelector]){
        Suppressor([self performSelector:mySelector]);
    }
    
}

-(void)notificarePushLib:(NotificarePushLib *)library shouldPerformSelectorWithURL:(NSURL *)url{

    NSLog(@"%@ %@ %@ %@",[url host], [url path], [url query], [url pathComponents]);
}

- (void)notificarePushLib:(NotificarePushLib *)library didNotExecuteAction:(NSDictionary *)info{
    //NSLog(@"%@",info);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closedNotification" object:nil];
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailToExecuteAction:(NSError *)error{
    //NSLog(@"%@",error);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closedNotification" object:nil];
}


#pragma Notificare Location delegates
- (void)notificarePushLib:(NotificarePushLib *)library didReceiveLocationServiceAuthorizationStatus:(NSDictionary *)status{
    
    NSLog(@"didReceiveLocationServiceAuthorizationStatus = %@",status);
    
    if([[NotificarePushLib shared] checkLocationUpdates]){
        NSLog(@"checkLocationUpdates");
    }
    

}

- (void)notificarePushLib:(NotificarePushLib *)library didFailToStartLocationServiceWithError:(NSError *)error{
    
    NSMutableDictionary * tmpLog = [NSMutableDictionary dictionary];
    [tmpLog setObject:@"didFailToStartLocationServiceWithError" forKey:@"event"];
    [tmpLog setObject:[NSString stringWithFormat:@"Error: %@",[error description]] forKey:@"data"];
    
    [self addToLog:tmpLog];
    
    
}

- (void)notificarePushLib:(NotificarePushLib *)library didUpdateLocations:(NSArray *)locations {

    
    
    NSMutableDictionary * tmpLog = [NSMutableDictionary dictionary];
    [tmpLog setObject:@"didUpdateLocations" forKey:@"event"];
    if([locations count] > 0){
        [tmpLog setObject:[NSString stringWithFormat:@"%lu locations",(unsigned long)[locations count]] forKey:@"data"];
    }
    [self addToLog:tmpLog];
    
    
    
}

//Use this delegate to know if any region failed to be monitored
- (void)notificarePushLib:(NotificarePushLib *)library monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error{
    
    NSMutableDictionary * tmpLog = [NSMutableDictionary dictionary];
    [tmpLog setObject:@"monitoringDidFailForRegion" forKey:@"event"];
    [tmpLog setObject:[NSString stringWithFormat:@"Region: %@ - Error: %@", [region identifier],[error description]] forKey:@"data"];
    
    [self addToLog:tmpLog];
}

//iOS 7 only delegate. When on iOS7 this delegate will give a status of a monitored region
// You can request a state of a region by doing [[[NotificarePushLib shared] locationManager] requestStateForRegion:(CLRegion *) region];

- (void)notificarePushLib:(NotificarePushLib *)library didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
   // NSLog(@"didDetermineState: %i %@", state, region);
    
    if([region isKindOfClass:[CLBeaconRegion class]]){
        [self setSupportsBeacons:YES];
    }
    
    NSMutableDictionary * regionObj = [NSMutableDictionary dictionary];
    
    [regionObj setObject:[NSString stringWithFormat:@"Region: %@", [region identifier]] forKey:@"region"];
    
    switch (state) {
        case CLRegionStateInside:
            
            
            [regionObj setObject:@"CLRegionStateInside" forKey:@"state"];
            break;
            
        case CLRegionStateOutside:
            
            
            [regionObj setObject:@"CLRegionStateOutside" forKey:@"state"];
            break;
        case CLRegionStateUnknown:
            [regionObj setObject:@"CLRegionStateUnknown" forKey:@"state"];
            break;
        default:
            break;
    }
    
    NSMutableDictionary * tmpLog = [NSMutableDictionary dictionary];
    [tmpLog setObject:@"didDetermineState" forKey:@"event"];
    [tmpLog setObject:regionObj forKey:@"data"];
    [self addToLog:tmpLog];
    
}

//Use this delegate to know when a user entered a region. Notificare will automatically handle the triggers.
//According to the triggers created through the dashboard or API.
- (void)notificarePushLib:(NotificarePushLib *)library didEnterRegion:(CLRegion *)region{
    
    
    NSMutableDictionary * regionObj = [NSMutableDictionary dictionary];
    NSMutableDictionary * tmpLog = [NSMutableDictionary dictionary];
    [tmpLog setObject:@"didEnterRegion" forKey:@"event"];
    [tmpLog setObject:regionObj forKey:@"data"];
    [self addToLog:tmpLog];
    
    

}



//Use this delegate to know when a user exited a region. Notificare will automatically handle the triggers.
//According to the triggers created through the dashboard or API.
- (void)notificarePushLib:(NotificarePushLib *)library didExitRegion:(CLRegion *)region{

    NSMutableDictionary * regionObj = [NSMutableDictionary dictionary];
    
   [regionObj setObject:[NSString stringWithFormat:@"Region: %@", [region identifier]] forKey:@"region"];
    
    NSMutableDictionary * tmpLog = [NSMutableDictionary dictionary];
    [tmpLog setObject:@"didExitRegion" forKey:@"event"];
    [tmpLog setObject:regionObj forKey:@"data"];
    [self addToLog:tmpLog];

}


- (void)notificarePushLib:(NotificarePushLib *)library didStartMonitoringForRegion:(CLRegion *)region{

    
    
    if(![region isKindOfClass:[CLBeaconRegion class]]){
        
        [[self regions] removeAllObjects];
        
        for (NSDictionary * fence in [[NotificarePushLib shared] geofences]) {
            [[self regions] addObject:fence];
        }
        
    }
    
    NSMutableDictionary * regionObj = [NSMutableDictionary dictionary];
    [regionObj setObject:[NSString stringWithFormat:@"Region: %@", [region identifier]] forKey:@"region"];
    
    NSMutableDictionary * tmpLog = [NSMutableDictionary dictionary];
    [tmpLog setObject:@"didStartMonitoringForRegion" forKey:@"event"];
    [tmpLog setObject:regionObj forKey:@"data"];
    [self addToLog:tmpLog];
}


//iOS 7 only delegate. Use this delegate to know when ranging beacons for a CLBeaconRegion failed.
- (void)notificarePushLib:(NotificarePushLib *)library rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error{
    
    NSMutableDictionary * regionObj = [NSMutableDictionary dictionary];
    
    [regionObj setObject:[NSString stringWithFormat:@"Region: %@ - Error: %@", [region identifier], [error description]] forKey:@"region"];
    
    NSMutableDictionary * tmpLog = [NSMutableDictionary dictionary];
    [tmpLog setObject:@"rangingBeaconsDidFailForRegion" forKey:@"event"];
    [tmpLog setObject:regionObj forKey:@"data"];
    [self addToLog:tmpLog];
    
}

//iOS 7 only delegate. Use this delegate to know when beacons have been found according to the proximity you set in the dashboard or API.
//When found a beacon it will be included in the array as a NSDictionary with a root property called info
//This will hold all the information of the beacon that is passed by Notificare like settings, content, etc.
//With this object you can alays open the beacon content by doing:
//[[NotificarePushLib shared] openNotification:[beacon objectForKey:@"info"]];

- (void)notificarePushLib:(NotificarePushLib *)library didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{
    
    [self setBeacons:[NSMutableArray arrayWithArray:beacons]];
    
    NSMutableDictionary * regionObj = [NSMutableDictionary dictionary];
    
    [regionObj setObject:[NSString stringWithFormat:@"Region: %@", [region identifier]] forKey:@"region"];
    
    NSMutableDictionary * tmpLog = [NSMutableDictionary dictionary];
    [tmpLog setObject:@"didRangeBeacons" forKey:@"event"];
    [tmpLog setObject:regionObj forKey:@"data"];
    [self addToLog:tmpLog];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"rangingBeacons" object:nil];
    

}

- (void)notificarePushLib:(NotificarePushLib *)library didFailProductTransaction:(SKPaymentTransaction *)transaction withError:(NSError *)error{

    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadProducts" object:nil];
}

- (void)notificarePushLib:(NotificarePushLib *)library didCompleteProductTransaction:(SKPaymentTransaction *)transaction{

    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadProducts" object:nil];
}

- (void)notificarePushLib:(NotificarePushLib *)library didRestoreProductTransaction:(SKPaymentTransaction *)transaction{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadProducts" object:nil];
    
}

- (void)notificarePushLib:(NotificarePushLib *)library didLoadStore:(NSArray *)products{

    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadProducts" object:nil];
}


- (void)notificarePushLib:(NotificarePushLib *)library didFailToLoadStore:(NSError *)error{

    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadProducts" object:nil];
}


- (void)notificarePushLib:(NotificarePushLib *)library didStartDownloadContent:(SKPaymentTransaction *)transaction{

     [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadProducts" object:nil];
}
- (void)notificarePushLib:(NotificarePushLib *)library didPauseDownloadContent:(SKDownload *)download{

     [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadProducts" object:nil];
}
- (void)notificarePushLib:(NotificarePushLib *)library didCancelDownloadContent:(SKDownload *)download{

     [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadProducts" object:nil];
}
- (void)notificarePushLib:(NotificarePushLib *)library didReceiveProgressDownloadContent:(SKDownload *)download{

     [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadProducts" object:nil];
}
- (void)notificarePushLib:(NotificarePushLib *)library didFailDownloadContent:(SKDownload *)download{

     [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadProducts" object:nil];
}
- (void)notificarePushLib:(NotificarePushLib *)library didFinishDownloadContent:(SKDownload *)download{

     [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadProducts" object:nil];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - OnboardingManager delegate -

- (void)onboardingWillShow:(OnboardingManager *)onboardingManager {
    
}

- (void)onboardingDidShow:(OnboardingManager *)onboardingManager {
    
}

- (void)onboardingWillHide:(OnboardingManager *)onboardingManager {
    
}

- (void)onboardingDidHide:(OnboardingManager *)onboardingManager {
    
}

- (void)onboardingManager:(OnboardingManager *)onboardingManager didUpdateStatus:(OnboardingStatus)status {
    
}

@end
