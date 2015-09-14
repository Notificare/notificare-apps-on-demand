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
    
    return RGBA([[dictionary objectForKey:@"red"] doubleValue],
                [[dictionary objectForKey:@"green"] doubleValue],
                [[dictionary objectForKey:@"blue"] doubleValue],
                [[dictionary objectForKey:@"alpha"] doubleValue]);
}

@end
