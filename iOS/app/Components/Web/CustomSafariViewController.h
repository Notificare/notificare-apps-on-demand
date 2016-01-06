//
//  CustomSafariViewController.h
//
//  Created by Aernout Peeters on 21-09-2015.
//  Copyright © 2015 Notificare. All rights reserved.
//

#import <SafariServices/SafariServices.h>

@interface CustomSafariViewController : SFSafariViewController

@property (nonatomic, strong) NSString *viewTitle;
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicatorView;
@property (nonatomic, strong) UIView * loadingView;

@end
