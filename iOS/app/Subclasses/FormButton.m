//
//  FormButton.m
//  app
//
//  Created by Joel Oliveira on 17/05/14.
//  Copyright (c) 2014 Notificare. All rights reserved.
//

#import "FormButton.h"
#import "UIColor+Hex.h"

@implementation FormButton

- (id)initWithCoder:(NSCoder *)decoder{
    if(self = [super initWithCoder:decoder]) {
        
        [[self titleLabel] setFont:BUTTON_TEXT];
        [[self titleLabel] setTextColor:BUTTON_TEXT_COLOR];
        [self setBackgroundColor:BUTTON_BACKGROUND_COLOR];
        [[self titleLabel] setShadowColor:[UIColor blackColor]];
        
        self.layer.cornerRadius= BUTTON_CORNER_RADIUS;
        self.layer.masksToBounds= YES;
        self.layer.borderColor= [BUTTON_BORDER_COLOR CGColor];
        self.layer.borderWidth= BUTTON_BORDER_WIDTH;
    }
    
    return self;
}

- (void)setup:(NSDictionary *)configuration {
#warning Should really have a configuration validation
    [self setTitle:LSSTRING(configuration[@"title"][@"text"]) forState:UIControlStateNormal];
    
    self.titleLabel.font = [UIFont fontWithName:configuration[@"title"][@"font"] size:[configuration[@"title"][@"fontSize"] doubleValue]];
    [self setTitleColor:[UIColor colorWithHexString:configuration[@"title"][@"color"]] forState:UIControlStateNormal];
    self.titleLabel.shadowColor = [UIColor blackColor];
    
    self.backgroundColor = [UIColor colorWithHexString:configuration[@"backgroundColor"]];
    
    self.layer.cornerRadius = [configuration[@"cornerRadius"] doubleValue];
    self.layer.borderColor = [[UIColor colorWithHexString:configuration[@"borderColor"]] CGColor];
    self.layer.borderWidth = [configuration[@"borderWidth"] doubleValue];
}

@end
