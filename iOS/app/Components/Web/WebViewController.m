//
//  WebViewController.m
//  app
//
//  Created by Joel Oliveira on 02/12/14.
//  Copyright (c) 2014 Notificare. All rights reserved.
//

#import "WebViewController.h"
#import "IIViewDeckController.h"
#import "AppDelegate.h"
#import "Configuration.h"

@interface WebViewController ()

@end

@implementation WebViewController

+ (NSString *)configurationKey {
    return @"web";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    [title setText:[self viewTitle]];
    [title setFont:[self titleFont]];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setTextColor:[self titleColor]];
    [[self navigationItem] setTitleView:title];
    
    [[self loadingView] setBackgroundColor:[self loadingViewColor]];
    
    [self setupNavigationBar];
    
    [[self activityIndicatorView] setHidden:YES];
    
    [[self backButton] setImage:[UIImage imageNamed: @"BackButton"]];
    [[self forwardButton] setImage:[UIImage imageNamed: @"ForwardButton"]];
    [[self refreshButton] setImage:[UIImage imageNamed: @"RefreshButton"]];
    
    [[self backButton] setEnabled:NO];
    [[self forwardButton] setEnabled:NO];
    [[self refreshButton] setEnabled:YES];
    
    [[self toolbar] setBackgroundColor:[self toolbarBackgroundColor]];
    [[self toolbar] setTintColor:[self toolbarForegroundColor]];
    [[self toolbar] setTranslucent:NO];
    
    //For iOS6
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        
        [[[self navigationController] navigationBar] setTintColor:[self navigationBackgroundColor]];
        
        [[self toolbar] setTintColor:[self toolbarForegroundColor]];
        
        [[self backButton] setTintColor:[self toolbarForegroundColor]];
        [[self forwardButton] setTintColor:[self toolbarForegroundColor]];
        [[self refreshButton] setTintColor:[self toolbarForegroundColor]];
        
        [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"Transparent"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"Transparent"] forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
        
    } else {
        
        [[[self navigationController] navigationBar] setBarTintColor:[self navigationBackgroundColor]];
    }
    
    [self goToUrl];
}

-(void)setupNavigationBar{
    int count = [[[self appDelegate] notificarePushLib] myBadge];
    
    if(count > 0){
        [[self buttonIcon] setTintColor:[self navigationForegroundColor]];
        [[self badgeButton] addTarget:[self viewDeckController] action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
        
        NSString * badge = [NSString stringWithFormat:@"%i", count];
        [[self badgeNr] setText:badge];
        
        UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithCustomView:[self badge]];
        [leftButton setTarget:[self viewDeckController]];
        [leftButton setAction:@selector(toggleLeftView)];
        [leftButton setTintColor:[self navigationForegroundColor]];
        [[self navigationItem] setLeftBarButtonItem:leftButton];
    } else {
        
        UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"LeftMenuIcon"] style:UIBarButtonItemStylePlain target:[self viewDeckController] action:@selector(toggleLeftView)];
        [leftButton setTintColor:[self navigationForegroundColor]];
        [[self navigationItem] setLeftBarButtonItem:leftButton];
        
    }
    
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"RightMenuIcon"] style:UIBarButtonItemStylePlain target:[self viewDeckController] action:@selector(toggleRightView)];
    
    [rightButton setTintColor:[self navigationForegroundColor]];
    
    if([[[self appDelegate] beacons] count] > 0){
        
        [[self navigationItem] setRightBarButtonItem:rightButton];
        
    } else {
        
        [[self navigationItem] setRightBarButtonItem:nil];
    }
}

-(void)changeBadge{
    
    [self setupNavigationBar];
    
}

-(void)goToUrl{
    
    NSURL *nsUrl=[NSURL URLWithString:[self targetUrl]];
    NSURLRequest *nsRequest=[NSURLRequest requestWithURL:nsUrl];
    [[self webView] loadRequest:nsRequest];
    
    [self setTitle:LSSTRING([self viewTitle])];
    
    [[self activityIndicatorView]  startAnimating];
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    
    [[self activityIndicatorView] setHidden:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    
    //[self performSelector:@selector(animateDidLoad) withObject:nil afterDelay:2.0];
    
    [self animateDidLoad];
    //[[self webView] stringByEvaluatingJavaScriptFromString:@"window.scrollTo(0.0, 110.0)"];
    
}

-(void)animateDidLoad{
    [UIView animateWithDuration:1.f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [[self loadingView] setAlpha:0.f];
    } completion:^(BOOL finished) {
        
        [[self activityIndicatorView] setHidden:YES];
        
        if([[self webView] canGoBack]){
            [[self backButton] setEnabled:YES];
        } else {
            [[self backButton] setEnabled:NO];
        }
        
        if([[self webView] canGoForward]){
            [[self forwardButton] setEnabled:YES];
        } else {
            [[self forwardButton] setEnabled:NO];
        }
        
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[self activityIndicatorView] setHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBadge) name:@"incomingNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupNavigationBar) name:@"rangingBeacons" object:nil];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"incomingNotification"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"rangingBeacons"
                                                  object:nil];
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    [[self activityIndicatorView] setHidden:YES];
    
    if([error code] != NSURLErrorCancelled){
        
        [self goToUrl];
        //ALERT_DIALOG(LSSTRING(@"title_webview_load_fail"), LSSTRING(@"message_webview_load_fail"));
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
