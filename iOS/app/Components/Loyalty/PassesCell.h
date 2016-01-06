//
//  PassesCell.h
//  rcd
//
//  Created by Aernout Peeters on 23-09-2015.
//  Copyright © 2015 Notificare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PassesCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *issuerLabel;
@property (weak, nonatomic) IBOutlet UILabel *templateNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *passImage;


@end
