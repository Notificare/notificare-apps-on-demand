//
//  NotificareComponentViewController.h
//  app
//
//  Created by Aernout Peeters on 16-12-2015.
//  Copyright © 2015 Notificare. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;
@class NotificarePushLib;

@interface NotificareComponentViewController : UIViewController

@property (nonatomic, readonly) AppDelegate *appDelegate;
@property (nonatomic, readonly) NotificarePushLib *notificarePushLib;

+ (NSString *)configurationKey;

- (instancetype)initWithConfiguration:(NSDictionary *)configuration;

@end
