//
//  FormField.m
//  app
//
//  Created by Joel Oliveira on 17/05/14.
//  Copyright (c) 2014 Notificare. All rights reserved.
//

#import "FormField.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Hex.h"

@implementation FormField


- (id)initWithCoder:(NSCoder *)decoder{
    if(self = [super initWithCoder:decoder]) {

        [self setFont:FIELD_TEXT];
        [self setBackgroundColor:FIELD_BACKGROUND_COLOR];
        [self setTextColor:FIELD_TEXT_COLOR];
        [self setBorderStyle:UITextBorderStyleNone];

        self.layer.cornerRadius= FIELD_CORNER_RADIUS;
        self.layer.masksToBounds= YES;
        self.layer.borderColor= [FIELD_BORDER_COLOR CGColor];
        self.layer.borderWidth= FIELD_BORDER_WIDTH;

        CGRect frameRect = self.frame;
        frameRect.size.height = 60;
        self.frame = frameRect;
        
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 17, 20)];
        [self setLeftView:paddingView];
        [self setLeftViewMode:UITextFieldViewModeAlways];
    }
    return self;
}

- (void) configureWithDelegate:(id) delegate
               secureTextEntry:(BOOL) secureText
                    properties:(NSDictionary *) formProperties
               placeHolderText:(NSString *) placeholderText {
    
    [self setDelegate:delegate];
    [self setSecureTextEntry:secureText];
    [self setFont:[UIFont fontWithName:[formProperties objectForKey:@"textFont"] size:[[formProperties objectForKey:@"textSize"] doubleValue]]];
    [self setBackgroundColor:[UIColor colorWithHexString:[formProperties objectForKey:@"backgroundColor"]]];
    [self setTextColor:[UIColor colorWithHexString:[formProperties objectForKey:@"textColor"]]];
    [self setTintColor:[UIColor colorWithHexString:[formProperties objectForKey:@"tintColor"]]];
    self.layer.cornerRadius = [[formProperties objectForKey:@"cornerRadius"] doubleValue];
    self.layer.borderColor = [[UIColor colorWithHexString:[formProperties objectForKey:@"borderColor"]] CGColor];
    self.layer.borderWidth = [[formProperties objectForKey:@"borderWidth"] doubleValue];
    [self setPlaceholderText:placeholderText
          withColorHexString:[formProperties objectForKey:@"placeholderColor"]];
}

- (void) setPlaceholderText:(NSString *)placeholderString
         withColorHexString:(NSString *)colorHexString {
    
    if ([self respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholderString attributes:@{NSForegroundColorAttributeName: [UIColor colorWithHexString:colorHexString]}];
        
    } else {
        
        [self setPlaceholder:placeholderString];
    }
}

@end
