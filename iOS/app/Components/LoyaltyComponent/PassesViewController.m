//
//  PassesViewController.m
//  rcd
//
//  Created by Aernout Peeters on 17-08-2015.
//  Copyright (c) 2015 Notificare. All rights reserved.
//

#import "PassesViewController.h"
#import "IIViewDeckController.h"
#import "NotificarePushLib.h"
#import <PassKit/PassKit.h>
#import "PassesCell.h"
#import "AppDelegate.h"

@interface PassesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *passes;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *noCouponsYetView;


@end

@implementation PassesViewController

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)setPasses:(NSArray *)passes {
    NSSortDescriptor *descriptionDescriptor = [[NSSortDescriptor alloc] initWithKey:@"localizedDescription"
                                                                          ascending:YES
                                                                           selector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"localizedName"
                                                                   ascending:YES
                                                                    selector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSSortDescriptor *dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"relevantDate" ascending:NO];
    
    NSArray *descriptors = @[descriptionDescriptor, nameDescriptor, dateDescriptor];
    _passes = [passes sortedArrayUsingDescriptors:descriptors];
    
    if (passes.count > 0) {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        self.noCouponsYetView.hidden = YES;
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
        self.noCouponsYetView.hidden = NO;
    }
    
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.editButtonItem.tintColor = [UIColor whiteColor];
    [self.editButtonItem setTitleTextAttributes:@{NSFontAttributeName: AVENIR_NEXT_REGULAR(15)} forState:UIControlStateNormal];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    [title setText:LSSTRING(@"title_passes")];
    [title setFont:AVENIR_NEXT_REGULAR(18)];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setTextColor:ICONS_COLOR];
    self.navigationItem.titleView = title;
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"LeftMenuIcon"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self.viewDeckController
                                                                  action:@selector(toggleLeftView)];
    
    [leftButton setTintColor:[UIColor whiteColor]];
    
    [[self navigationItem] setLeftBarButtonItem:leftButton];
    
    self.navigationController.navigationBar.barTintColor = MAIN_COLOR;
    self.navigationController.navigationBar.translucent = NO;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PassesCell" bundle:nil] forCellReuseIdentifier:@"PassesCell"];
}

- (void)getPasses {
    NSMutableArray *tempPasses = [NSMutableArray array];
    
    for (PKPass *pass in [[NotificarePushLib shared] myPasses]) {
        if (![[self appDelegate] isMembershipCard:pass]) {
            [tempPasses addObject:pass];
        }
    }
    
    self.passes = [tempPasses copy];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self getPasses];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.passes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PKPass *pass = self.passes[indexPath.row];
    
    PassesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PassesCell" forIndexPath:indexPath];
    
    cell.issuerLabel.text = pass.localizedDescription;
    cell.templateNameLabel.text = pass.localizedName;
    cell.passImage.image = pass.icon;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PKPass *pass = self.passes[indexPath.row];
    
    [[UIApplication sharedApplication] openURL:pass.passURL];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 128;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    PKPass *pass = self.passes[indexPath.row];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PKPassLibrary *passLib = [[PKPassLibrary alloc] init];
        [passLib removePass:pass];
        
        NSMutableArray *tempPasses = [NSMutableArray arrayWithArray:self.passes];
        [tempPasses removeObject:pass];
        self.passes = [tempPasses copy];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    if (editing) {
        [self.editButtonItem setTitleTextAttributes:@{NSFontAttributeName: AVENIR_NEXT_DEMIBOLD(15)} forState:UIControlStateNormal];
    }
    else {
        [self.editButtonItem setTitleTextAttributes:@{NSFontAttributeName: AVENIR_NEXT_REGULAR(15)} forState:UIControlStateNormal];
    }
    
    self.tableView.editing = editing;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return USER_HEADER_HEIGHT;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HeaderCouponsIcon"]];
    imageView.backgroundColor = MAIN_COLOR;
    imageView.contentMode = UIViewContentModeCenter;
    
    return imageView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}


@end
