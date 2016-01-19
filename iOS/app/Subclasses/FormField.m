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

- (void)setup:(NSDictionary *)configuration {
    self.font = [UIFont fontWithName:configuration[@"font"] size:[configuration[@"fontSize"] doubleValue]];
    self.textColor = [UIColor colorWithHexString:configuration[@"textColor"]];
    self.backgroundColor = [UIColor colorWithHexString:configuration[@"backgroundColor"]];
    self.tintColor = [UIColor colorWithHexString:configuration[@"tintColor"]];
    self.secureTextEntry = [configuration[@"secureTextEntry"] boolValue];
    [self setPlaceholder:LSSTRING(configuration[@"placeholder"][@"text"]) withColor:[UIColor colorWithHexString:configuration[@"placeholder"][@"color"]]];
    
    self.layer.cornerRadius = [configuration[@"cornerRadius"] doubleValue];
    self.layer.borderColor = [[UIColor colorWithHexString:configuration[@"borderColor"]] CGColor];
    self.layer.borderWidth = [configuration[@"borderWidth"] doubleValue];
}

- (void)setPlaceholder:(NSString *)placeHolder withColor:(UIColor *)color {
    
    if ([self respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeHolder attributes:@{NSForegroundColorAttributeName: color}];
        
    }
    else {
        self.placeholder = placeHolder;
    }
}

@end
