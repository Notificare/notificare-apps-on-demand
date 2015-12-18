//
//  NSDictionary+Merge.m
//  app
//
//  Created by Aernout Peeters on 18-12-2015.
//  Copyright © 2015 Notificare. All rights reserved.
//

#import "NSDictionary+Merge.h"

@implementation NSDictionary (Merge)

- (NSDictionary *)merge:(NSDictionary * _Nonnull)dictionary {
    NSMutableDictionary *mergedDictionary = [NSMutableDictionary dictionaryWithDictionary:self];
    
    for (NSString *key in dictionary) {
        if (self[key]) {
            
            // Check if value classes match
            if ([self[key] class] == [dictionary[key] class]) {
                
                if ([self[key] class] == [self class]) {
                    
                    // Merge dictionary value
                    mergedDictionary[key] = [self[key] merge:dictionary[key]];
                }
                else {
                    
                    // Overwrite existing value
                    mergedDictionary[key] = dictionary[key];
                }
            }
            else {
                NSLog(@"Could not merge dictionaries because of a class mismatch: %@ %@", self, dictionary);
            }
        }
        else {
            // Insert new value
            mergedDictionary[key] = dictionary[key];
        }
    }
    
    return [mergedDictionary copy];
}

@end
