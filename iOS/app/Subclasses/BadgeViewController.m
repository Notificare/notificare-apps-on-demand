//
//  BadgeViewController.m
//
//  Created by Aernout Peeters on 20-11-2015.
//  Copyright © 2015 Notificare. All rights reserved.
//

#import "BadgeViewController.h"

#import "IIViewDeckController.h"
#import "NotificarePushLib.h"

@interface BadgeViewController ()

@end

@implementation BadgeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self buttonIcon] setTintColor:ICONS_COLOR];
    [[self badgeButton] addTarget:[self viewDeckController] action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
    
    int count = [[NotificarePushLib shared] myBadge];
    self.badgeNr.text = [NSString stringWithFormat:@"%i", count];
    
    /*UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithCustomView:[self badgeView]];
    [leftButton setTarget:[self viewDeckController]];
    [leftButton setAction:@selector(toggleLeftView)];
    [leftButton setTintColor:ICONS_COLOR];
    [[self navigationItem] setLeftBarButtonItem:leftButton];*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
