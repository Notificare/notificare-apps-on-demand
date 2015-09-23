//
//  FormField.m
//  app
//
//  Created by Joel Oliveira on 17/05/14.
//  Copyright (c) 2014 Notificare. All rights reserved.
//

#import "FormField.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+NSDictionary.h"

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

- (void) setPlaceholderText:(NSString *) placeholderString
         withRGBaDictionary:(NSDictionary *) colorDictionary {
    
    if ([self respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholderString attributes:@{NSForegroundColorAttributeName: [UIColor colorFromRgbaDictionary:colorDictionary]}];
        
    } else {
        
        [self setPlaceholder:placeholderString];
    }
}

@end
