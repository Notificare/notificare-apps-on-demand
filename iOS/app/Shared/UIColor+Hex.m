//
//  UIColor+Hex.m
//  app
//
//  Created by Aernout Peeters on 14-12-2015.
//  Copyright © 2015 Notificare. All rights reserved.
//

#import "UIColor+Hex.h"


@implementation UIColor (Hex)

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    if (hexString.length == 0) {
        return nil;
    }
    
    // Check for hash and add the missing hash
    if('#' != [hexString characterAtIndex:0]) {
        hexString = [NSString stringWithFormat:@"#%@", hexString];
    }
    
    CGFloat red     = 0.0;
    CGFloat green   = 0.0;
    CGFloat blue    = 0.0;
    CGFloat alpha   = 1.0;
    
    if (hexString.length == 4) {
        // Format #RGB
        red     = [self valueFromHexString:hexString withRange:NSMakeRange(1, 1)];
        green   = [self valueFromHexString:hexString withRange:NSMakeRange(2, 1)];
        blue    = [self valueFromHexString:hexString withRange:NSMakeRange(3, 1)];
    }
    else if (hexString.length == 5) {
        // Format #RGBA
        red     = [self valueFromHexString:hexString withRange:NSMakeRange(1, 1)];
        green   = [self valueFromHexString:hexString withRange:NSMakeRange(2, 1)];
        blue    = [self valueFromHexString:hexString withRange:NSMakeRange(3, 1)];
        alpha   = [self valueFromHexString:hexString withRange:NSMakeRange(4, 1)];
    }
    else if (hexString.length == 7) {
        // Format #RRGGBB
        red     = [self valueFromHexString:hexString withRange:NSMakeRange(1, 2)];
        green   = [self valueFromHexString:hexString withRange:NSMakeRange(3, 2)];
        blue    = [self valueFromHexString:hexString withRange:NSMakeRange(5, 2)];
    }
    else if (hexString.length == 9) {
        // Format #RRGGBBAA
        red     = [self valueFromHexString:hexString withRange:NSMakeRange(1, 2)];
        green   = [self valueFromHexString:hexString withRange:NSMakeRange(3, 2)];
        blue    = [self valueFromHexString:hexString withRange:NSMakeRange(5, 2)];
        alpha   = [self valueFromHexString:hexString withRange:NSMakeRange(7, 2)];
    }
    else {
        [NSException raise:@"HexStringIncorrectLength" format:@"HexString provided has an incorrect length"];
    }
    
    
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    
    return color;
}

+ (float)valueFromHexString:(NSString *)hexString withRange:(NSRange)range {
    NSString *valueString;
    
    if (range.length == 1) {
        valueString = [NSString stringWithFormat:@"0x%1$@%1$@", [hexString substringWithRange:range]];
    }
    else if (range.length == 2) {
        valueString = [NSString stringWithFormat:@"0x%@", [hexString substringWithRange:range]];
    }
    else {
        [NSException raise:@"RangeIncorrectLength" format:@"Range provided must have a length of either 1 or 2."];
    }
    
    unsigned intValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:valueString];
    [scanner scanHexInt:&intValue];
    
    return intValue / 255.0;
}

@end
