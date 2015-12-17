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

@interface NotificareComponentViewController ()

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

- (instancetype)init {
    self = [super init];
    
    if (self) {
        // set configuration to empty dictionary first
        _configuration = [NSDictionary dictionary];
        
        //try to get default configuration
        NSString *configurationKey = [[self class] configurationKey];
        
        if (configurationKey && configurationKey.length > 0) {
            NSDictionary *componentConfigurations = [[Configuration shared] getDictionary:@"components"];
            if (componentConfigurations[configurationKey]) {
                _configuration = componentConfigurations[configurationKey];
            }
            else {
                NSLog(@"Could not load default configuration for component: %@", configurationKey);
            }
        }
        else {
            NSLog(@"Missing component configuration key");
        }
    }
    
    return self;
}

- (instancetype)initWithConfiguration:(NSDictionary * _Nonnull)configuration {
    // sets default configuration
    self = [self init];
    
    if (self) {
        // create a mutable copy of the current configuration first
        NSMutableDictionary *configurationCopy = [NSMutableDictionary dictionaryWithDictionary:self.configuration];
        
        for (NSString *key in configuration) {
            // overwrite existing entries
            configurationCopy[key] = configuration[key];
        }
        
        // set configuration to non-mutable copy of configurationCopy
        _configuration = [configurationCopy copy];
    }
    
    return self;
}


@end
