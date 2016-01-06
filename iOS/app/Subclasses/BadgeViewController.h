//
//  BadgeViewController.h
//
//  Created by Aernout Peeters on 20-11-2015.
//  Copyright © 2015 Notificare. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BadgeLabel.h"

@interface BadgeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *buttonIcon;
@property (weak, nonatomic) IBOutlet BadgeLabel *badgeNr;
@property (weak, nonatomic) IBOutlet UIButton *badgeButton;

@end
