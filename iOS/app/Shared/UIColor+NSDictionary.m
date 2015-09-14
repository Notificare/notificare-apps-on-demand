//
//  UIColor+NSDictionary.m
//  app
//
//  Created by Bruno Tavares on 14/09/15.
//  Copyright © 2015 Notificare. All rights reserved.
//

#import "UIColor+NSDictionary.h"

@implementation UIColor (NSDictionary)

+(UIColor *) colorFromRgbaDictionary: (NSDictionary *) dictionary {
    
    if (dictionary &&
        [dictionary objectForKey:@"red"] &&
        [dictionary objectForKey:@"green"] &&
        [dictionary objectForKey:@"blue"] &&
        [dictionary objectForKey:@"alpha"]) {
        
        return RGBA([[dictionary objectForKey:@"red"] doubleValue],
                    [[dictionary objectForKey:@"green"] doubleValue],
                    [[dictionary objectForKey:@"blue"] doubleValue],
                    [[dictionary objectForKey:@"alpha"] doubleValue]);
        
    } else {
        
        NSLog(@"An invalid color has been parsed. Please check the plist file.");
        
        return [UIColor grayColor];
    }
}

@end
