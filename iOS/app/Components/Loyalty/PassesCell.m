//
//  PassesCell.m
//  rcd
//
//  Created by Aernout Peeters on 23-09-2015.
//  Copyright © 2015 Notificare. All rights reserved.
//

#import "PassesCell.h"

@interface PassesCell ()

@property (weak, nonatomic) IBOutlet UIView *frameView;

@end

@implementation PassesCell

- (void)awakeFromNib {
    // Initialization code
    
    self.frameView.layer.masksToBounds = YES;
    self.frameView.layer.cornerRadius = 8;
    self.frameView.layer.borderWidth = 1;
    self.frameView.layer.borderColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1] CGColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
