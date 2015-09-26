//
//  UserDetailsViewController.m
//  app
//
//  Created by Joel Oliveira on 18/05/14.
//  Copyright (c) 2014 Notificare. All rights reserved.
//

#import "UserDetailsViewController.h"
#import "AppDelegate.h"
#import "NotificarePushLib.h"
#import "IIViewDeckController.h"
#import "UserCell.h"
#import "SegmentCell.h"
#import "GravatarHelper.h"
#import "NotificareUser.h"
#import "NotificareUserPreference.h"
#import "NotificareSegment.h"
#import "UIColor+NSDictionary.h"

@interface UserDetailsViewController ()

@end

@implementation UserDetailsViewController


- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (NotificarePushLib *)notificare {
    return (NotificarePushLib *)[[self appDelegate] notificarePushLib];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNavigationBarWithTitle:LSSTRING(@"title_user_profile")];
    [self resetForm];
    [[self view] setBackgroundColor:[self viewBackgroundColor]];
    
    [self setNavSections:[NSMutableArray array]];
    [self setSectionTitles:[NSMutableArray array]];
    
    [[self sectionTitles] addObject:LSSTRING(@"title_section_user")];
    [[self sectionTitles] addObject:LSSTRING(@"title_section_segments")];

    [self resetForm];
    [[self password] setPlaceholder:LSSTRING(@"placeholder_newpass")];
    [[self password] setDelegate:self];
    [[self password] setSecureTextEntry:YES];
    [[self passwordConfirm] setSecureTextEntry:YES];
    [[self passwordConfirm] setDelegate:self];
    [[self passwordConfirm] setPlaceholder:LSSTRING(@"placeholder_confirm_newpass")];
    
    [[self changePassButton] setTitle:LSSTRING(@"button_changepass") forState:UIControlStateNormal];
    [[self generateTokenButton] setTitle:LSSTRING(@"button_generatetoken") forState:UIControlStateNormal];
    [[self logoutButton] setTitle:LSSTRING(@"button_logout") forState:UIControlStateNormal];
    [[self logoutButton] setBackgroundColor:[UIColor redColor]];

    [self setOptionsView:[[UserDetailsOptionsViewController alloc] initWithNibName:@"UserDetailsOptionsViewController" bundle:nil]];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBadge) name:@"incomingNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBadge) name:@"rangingBeacons" object:nil];
    
    [self loadAccount];
    [[self activityIndicatorView] setHidden:NO];
    [[self activityIndicatorView] startAnimating];
    
    [[self loadingView] setBackgroundColor:[UIColor whiteColor]];
    [[self loadingView] addSubview:[self activityIndicatorView]];
    [[self view] addSubview:[self loadingView]];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"incomingNotification"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"rangingBeacons"
                                                  object:nil];
    
}



-(void)loadAccount{
    
    [[self notificare] fetchAccountDetails:^(NSDictionary *info) {
        //

        NotificareUser * tmpUser = [NotificareUser new];
        
        [tmpUser setUserID:[[info objectForKey:@"user"] objectForKey:@"userID"]];
        [tmpUser setUserName:[[info objectForKey:@"user"] objectForKey:@"userName"]];
        [tmpUser setSegments:[[info objectForKey:@"user"] objectForKey:@"segments"]];
        [tmpUser setAccessToken:[[info objectForKey:@"user"] objectForKey:@"accessToken"]];
        [tmpUser setAccount:[[info objectForKey:@"user"] objectForKey:@"account"]];
        [tmpUser setApplication:[[info objectForKey:@"user"] objectForKey:@"application"]];
        [tmpUser setValidated:[[[info objectForKey:@"user"] objectForKey:@"validated"] boolValue]];
        [tmpUser setActive:[[[info objectForKey:@"user"] objectForKey:@"active"] boolValue]];
        [self setUser:tmpUser];

        [self loadSegments];
    } errorHandler:^(NSError *error) {
        
    }];
    
    

}

-(void)loadSegments{
    
    [self setSegments:[NSMutableArray array]];
    
    [[self notificare] fetchUserPreferences:^(NSArray *info) {
        
        for (NotificareUserPreference * preference in info){
            
            [[self segments] addObject:preference];
        }
        
        [self setupTable];
        
    } errorHandler:^(NSError *error) {
        
        [self loadSegments];
    }];
}


-(void)setupTable{
    
    [[self activityIndicatorView] setHidden:YES];
    [[self loadingView] removeFromSuperview];
    
    [self setNavSections:[NSMutableArray array]];
    
    NSMutableArray * userCell = [NSMutableArray array];

    if([self user] && [[self user] userName] && [[self user] userID]){
        [userCell addObject:@{
                              @"name":[[self user] userName],
                              @"email":[[self user] userID],
                              @"token":([[self user] accessToken]) ? [[self user] accessToken] : @"",
                              @"label":LSSTRING(@"avatar"),
                              @"action":@""}];
        
        [userCell addObject:@{@"name":[[self user] userName],
                              @"email":[[self user] userID],
                              @"token":([[self user] accessToken]) ? [[self user] accessToken] : @"",
                              @"label":LSSTRING(@"button_resetpass"),
                              @"action":@""}];
        
        [userCell addObject:@{@"name":[[self user] userName],
                              @"email":[[self user] userID],
                              @"token":([[self user] accessToken]) ? [[self user] accessToken] : @"",
                              @"label":LSSTRING(@"button_generatetoken"),
                              @"action":@""}];
        
        [userCell addObject:@{@"name":[[self user] userName],
                              @"email":[[self user] userID],
                              @"token":([[self user] accessToken]) ? [[self user] accessToken] : @"",
                              @"label":LSSTRING(@"button_logout"),
                              @"action":@""}];
    }
    
    
    [[self navSections] addObject:userCell];
    [[self navSections] addObject:[self segments]];
    
    [[self tableView] reloadData];
}

- (void) setupNavigationBarWithTitle:(NSString *) titleText {
    
    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    [title setText:titleText];
    [title setFont:[self titleFont]];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setTextColor:[self titleColor]];
    [[self navigationItem] setTitleView:title];
    
    int count = [[[self appDelegate] notificarePushLib] myBadge];
    
    if(count > 0){
        [[self buttonIcon] setTintColor:[self navigationForegroundColor]];
        [[self badgeButton] addTarget:[self viewDeckController] action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        NSString * badge = [NSString stringWithFormat:@"%i", count];
        [[self badgeNr] setText:badge];
        
        UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithCustomView:[self badge]];
        [leftButton setTarget:[self viewDeckController]];
        [leftButton setAction:@selector(toggleLeftView)];
        [leftButton setTintColor:[self navigationForegroundColor]];
        [[self navigationItem] setLeftBarButtonItem:leftButton];
    } else {
        
        UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"LeftMenuIcon"] style:UIBarButtonItemStylePlain target:[self viewDeckController] action:@selector(toggleLeftView)];
        [leftButton setTintColor:[self navigationForegroundColor]];
        [[self navigationItem] setLeftBarButtonItem:leftButton];
        
    }
    
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"RightMenuIcon"] style:UIBarButtonItemStylePlain target:[self viewDeckController] action:@selector(toggleRightView)];
    
    [rightButton setTintColor:[self navigationForegroundColor]];
    
    if([[[self appDelegate] beacons] count] > 0){
        [[self navigationItem] setRightBarButtonItem:rightButton];
    } else {
        [[self navigationItem] setRightBarButtonItem:nil];
    }
    
    //For iOS6
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        
        [[[self navigationController] navigationBar] setTintColor:[self navigationBackgroundColor]];
        
        [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"Transparent"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"Transparent"] forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
        
    } else {
        
        [[[self navigationController] navigationBar] setBarTintColor:[self navigationBackgroundColor]];
    }
}

-(void)changeBadge{
    
    [self setupNavigationBarWithTitle:LSSTRING(@"title_user_profile")];
    
}


-(IBAction)generateToken:(id)sender{
    [[self generateTokenButton] setEnabled:NO];
    [[self notificare] generateAccessToken:^(NSDictionary *info) {
        //
        NSDictionary * user = [info objectForKey:@"user"];
        [[self userToken] setText:[NSString stringWithFormat:@"%@@pushmail.notifica.re",[user objectForKey:@"accessToken"]]];
        [[self generateTokenButton] setEnabled:YES];
        APP_ALERT_DIALOG(LSSTRING(@"success_message_generate_token"));
    } errorHandler:^(NSError *error) {
        //
        [[self generateTokenButton] setEnabled:YES];
        APP_ALERT_DIALOG(LSSTRING(@"error_message_generate_token"));
    }];
}


-(void)generateNewToken{

    [[self notificare] generateAccessToken:^(NSDictionary *info) {
        [self loadAccount];
        APP_ALERT_DIALOG(LSSTRING(@"success_message_generate_token"));
    } errorHandler:^(NSError *error) {
        APP_ALERT_DIALOG(LSSTRING(@"error_message_generate_token"));
    }];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if([alertView cancelButtonIndex] != buttonIndex){
        if([[[alertView textFieldAtIndex:0] text] length] == 0 || [[[alertView textFieldAtIndex:1] text] length] == 0){
            APP_ALERT_DIALOG(LSSTRING(@"error_password_changepass"));
        } else if (![[[alertView textFieldAtIndex:0] text] isEqualToString:[[alertView textFieldAtIndex:1] text]]) {
            APP_ALERT_DIALOG(LSSTRING(@"error_create_account_passwords_match"));
        } else if ([[[alertView textFieldAtIndex:0] text] length] <= 4) {
            APP_ALERT_DIALOG(LSSTRING(@"error_create_account_small_password"));
        } else {
            [[self notificare] changePassword:[NSString stringWithFormat:@"%@", [[alertView textFieldAtIndex:0] text]] completionHandler:^(NSDictionary *info) {
                
                APP_ALERT_DIALOG(LSSTRING(@"success_message_changepass"));
            } errorHandler:^(NSError *error) {
                //
                APP_ALERT_DIALOG( LSSTRING(@"error_message_changepass"));
            }];
        }
    }
    

}


-(IBAction)changePass:(id)sender{
    
    [[self changePassButton] setEnabled:NO];
    
    if(![self password] && ![self passwordConfirm]){
        
        [[self changePassButton] setEnabled:YES];
         APP_ALERT_DIALOG(LSSTRING(@"error_password_changepass"));
        
    }else if (![[[self password] text] isEqualToString:[[self passwordConfirm] text]]) {
        
        [[self changePassButton] setEnabled:YES];
        APP_ALERT_DIALOG(LSSTRING(@"error_create_account_passwords_match"));
        
    }else if ([[[self passwordConfirm] text] length] < 5) {

        [[self changePassButton] setEnabled:YES];
        APP_ALERT_DIALOG(LSSTRING(@"error_create_account_small_password"));
        
    } else {
        
        [[self notificare] changePassword:[[self password] text]  completionHandler:^(NSDictionary *info) {
            //
            [self resetForm];
            [[self changePassButton] setEnabled:YES];
            APP_ALERT_DIALOG(LSSTRING(@"success_message_changepass"));
        } errorHandler:^(NSError *error) {
            //
            NSLog(@"%@",error);
            [[self changePassButton] setEnabled:YES];
            [self resetForm];
            APP_ALERT_DIALOG( LSSTRING(@"error_message_changepass"));
        }];
        
    }
   
}

-(IBAction)logout:(id)sender{
    [[self loadingView] addSubview:[self activityIndicatorView]];
    [[self view] addSubview:[self loadingView]];
    [[self notificare] logoutAccount];
}


-(void)logout{
    [[self loadingView] addSubview:[self activityIndicatorView]];
    [[self view] addSubview:[self loadingView]];
    [[self notificare] logoutAccount];
}

-(void)resetForm{
    
    [[self password] setText:@""];
    [[self passwordConfirm] setText:@""];
    
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO;
}



#pragma mark - Table delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return [[self navSections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[[self navSections] objectAtIndex:section] count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if([indexPath section] == 0){
        
        if([indexPath row] == 0){
            
            static NSString* cellType = @"UserCell";
            UserCell * cell = (UserCell *)[tableView dequeueReusableCellWithIdentifier:cellType];
            
            if (cell == nil) {
                
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellType owner:nil options:nil];
                cell = (UserCell*)[nib objectAtIndex:0];
            }
            
            NSDictionary * item = (NSDictionary *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
            NSDictionary * nameProperties = [[self userDetailsProperties] objectForKey:@"profileName"];
            
            UILabel * name = (UILabel *)[cell viewWithTag:100];
            [name setText:[item objectForKey:@"name"]];
            [name setFont:[UIFont fontWithName:[nameProperties objectForKey:@"textFont"] size:[[nameProperties objectForKey:@"textSize"] doubleValue]]];
            [name setTextColor:[UIColor colorFromRgbaDictionary:[nameProperties objectForKey:@"textColor"]]];
            
            NSDictionary * emailProperties = [[self userDetailsProperties] objectForKey:@"profileEmail"];
            
            UILabel * email = (UILabel *)[cell viewWithTag:101];
            [email setText:[item objectForKey:@"email"]];
            [email setFont:[UIFont fontWithName:[emailProperties objectForKey:@"textFont"] size:[[emailProperties objectForKey:@"textSize"] doubleValue]]];
            [email setTextColor:[UIColor colorFromRgbaDictionary:[emailProperties objectForKey:@"textColor"]]];
            
            NSDictionary * tokenProperties = [[self userDetailsProperties] objectForKey:@"profileToken"];
            UILabel * token = (UILabel *)[cell viewWithTag:102];
            if([item objectForKey:@"token"] && [NSNull class] != [[item objectForKey:@"token"] class]){
                
                [token setText:[NSString stringWithFormat:@"%@@pushmail.notifica.re", [item objectForKey:@"token"]]];
                
            } else {
                
                [token setText:@""];
            }
            [token setFont:[UIFont fontWithName:[tokenProperties objectForKey:@"textFont"] size:[[tokenProperties objectForKey:@"textSize"] doubleValue]]];
            [token setTextColor:[UIColor colorFromRgbaDictionary:[tokenProperties objectForKey:@"textColor"]]];
            
            UIImageView * image = (UIImageView *)[cell viewWithTag:103];
            [image setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[GravatarHelper getGravatarURL:[item objectForKey:@"email"]]]]];
            
            image.layer.cornerRadius = 5.0;
            image.layer.masksToBounds = YES;
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell setBackgroundColor:[UIColor colorFromRgbaDictionary:[[self userDetailsProperties] objectForKey:@"profileBackgroundColor"]]];
            return cell;
            
        } else {
            
            static NSString* cellType = @"SegmentCell";
            SegmentCell * cell = (SegmentCell *)[tableView dequeueReusableCellWithIdentifier:cellType];
            
            if (cell == nil) {
                
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellType owner:nil options:nil];
                cell = (SegmentCell*)[nib objectAtIndex:0];
            }
            
            NSDictionary * item = (NSDictionary *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
            NSDictionary * properties = [[self userDetailsProperties] objectForKey:@"profileOptions"];
            
            [[cell textLabel] setText:[item objectForKey:@"label"]];
            [[cell textLabel] setFont:[UIFont fontWithName:[properties objectForKey:@"textFont"] size:[[properties objectForKey:@"textSize"] doubleValue]]];
            [[cell textLabel] setTextColor:[UIColor colorFromRgbaDictionary:[properties objectForKey:@"textColor"]]];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell setBackgroundColor:[UIColor colorFromRgbaDictionary:[properties objectForKey:@"backgroundColor"]]];
            return cell;
        }
        
    } else {
        
        static NSString* cellType = @"SegmentCell";
        SegmentCell * cell = (SegmentCell *)[tableView dequeueReusableCellWithIdentifier:cellType];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellType owner:nil options:nil];
            cell = (SegmentCell*)[nib objectAtIndex:0];
        }
        
        NotificareUserPreference * item = (NotificareUserPreference *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
        NSDictionary *profilePreferences = [[self userDetailsProperties] objectForKey:@"infoOptions"];
        
        [[cell textLabel] setText:[item preferenceLabel]];
        [[cell textLabel] setFont:[UIFont fontWithName:[profilePreferences objectForKey:@"textFont"] size:[[profilePreferences objectForKey:@"textSize"] doubleValue]]];
        [[cell textLabel] setTextColor:[UIColor colorFromRgbaDictionary:[profilePreferences objectForKey:@"textColor"]]];
        
        
        if([[item preferenceType] isEqualToString:@"single"]){
            
            NotificareSegment * seg = (NotificareSegment *)[[item preferenceOptions] firstObject];
            [[cell detailTextLabel] setText:[seg segmentLabel]];
            [[cell detailTextLabel] setFont:LATO_FONT(14)];
            UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            [cell setAccessoryView:mySwitch];
            [mySwitch setTag:(([indexPath section] * 100) + [indexPath row])];
            [mySwitch setOnTintColor:[UIColor colorFromRgbaDictionary:[profilePreferences objectForKey:@"selectionColor"]]];
            
            if([seg selected]){
                
                [mySwitch setOn:YES];
            }
            
            [mySwitch addTarget:self action:@selector(OnSegmentsChanged:) forControlEvents:UIControlEventValueChanged];
        }
        
        if([[item preferenceType] isEqualToString:@"choice"]){

            UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width /2, cell.frame.size.height /2)];
            
            for (NotificareSegment * seg in [item preferenceOptions]) {
                //
                if([seg selected]){
                    [label setText:[seg segmentLabel]];
                    [label setTextAlignment:NSTextAlignmentRight];
                    [label setTextColor:[UIColor grayColor]];
                    [label setFont:LATO_LIGHT_FONT(14)];
                    [cell setAccessoryView:label];
                }
            }

        }
        
        if([[item preferenceType] isEqualToString:@"select"]){

            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            
        }

        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }

}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([indexPath section] == 0){
        if([indexPath row] == 0){
            return USER_CELLHEIGHT;
        }else{
            return SEGMENT_CELLHEIGHT;
        }
    } else {
        
        return SEGMENT_CELLHEIGHT;
        
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if(section == 0){
        return USER_HEADER_HEIGHT;
    } else {
        return SEGMENT_HEADER_HEIGHT;
    }
    
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section {
    
    return 2.0;
}

- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section {
    
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    NSDictionary* sectionProperties = [[self userDetailsProperties] objectForKey:@"sectionHeader"];
    
    if(section == 0){
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, USER_HEADER_HEIGHT)];
        headerView.backgroundColor = [UIColor colorFromRgbaDictionary:[sectionProperties objectForKey:@"backgroundColor"]];
        
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 10, USER_HEADER_HEIGHT)];
        [label setText:[[self sectionTitles] objectAtIndex:section]];
        [label setFont:[UIFont fontWithName:[sectionProperties objectForKey:@"textFont"] size:[[sectionProperties objectForKey:@"textSize"] doubleValue]]];
        [label setTextColor:[UIColor colorFromRgbaDictionary:[sectionProperties objectForKey:@"textColor"]]];
        [label setBackgroundColor:[UIColor clearColor]];
        label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        
        [headerView addSubview:label];
        return headerView;
        
    } else {
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SEGMENT_HEADER_HEIGHT)];
        headerView.backgroundColor = [UIColor colorFromRgbaDictionary:[sectionProperties objectForKey:@"backgroundColor"]];
        
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 10, SEGMENT_HEADER_HEIGHT)];
        [label setText:[[self sectionTitles] objectAtIndex:section]];
        [label setFont:[UIFont fontWithName:[sectionProperties objectForKey:@"textFont"] size:[[sectionProperties objectForKey:@"textSize"] doubleValue]]];
        [label setTextColor:[UIColor colorFromRgbaDictionary:[sectionProperties objectForKey:@"textColor"]]];
        [label setBackgroundColor:[UIColor clearColor]];
        label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        
        [headerView addSubview:label];
        return headerView;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return [[self sectionTitles] objectAtIndex:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]] isKindOfClass:[NotificareUserPreference class]]){
        
        NotificareUserPreference * item = (NotificareUserPreference *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
        
        if(![[item preferenceType] isEqualToString:@"single"]){
            [[self optionsView] setPreference:item];
            [[self navigationController] pushViewController:[self optionsView] animated:YES];
        }
        
        
    } else {
        
        
        NSDictionary * item = (NSDictionary *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
        
        if([[item objectForKey:@"label"] isEqualToString:LSSTRING(@"button_resetpass")]){
            
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"] message:LSSTRING(@"button_resetpass") delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            [av setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
            
            [[av textFieldAtIndex:1] setSecureTextEntry:YES];
            [[av textFieldAtIndex:0] setSecureTextEntry:YES];
            [[av textFieldAtIndex:0] setPlaceholder:@"new password"];
            [[av textFieldAtIndex:1] setPlaceholder:@"confirm password"];
            [av show];
            
        } else if([[item objectForKey:@"label"] isEqualToString:LSSTRING(@"button_generatetoken")]){
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            UIActivityIndicatorView * activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [cell setAccessoryView:activityView];
            [activityView startAnimating];
            
            [cell setUserInteractionEnabled:NO];
            [self generateNewToken];
            
        } else if([[item objectForKey:@"label"] isEqualToString:LSSTRING(@"button_logout")]){
            
            [self logout];
            
        }  else if([[item objectForKey:@"label"] isEqualToString:LSSTRING(@"avatar")]){
            
            if([item objectForKey:@"token"] && [NSNull class] != [[item objectForKey:@"token"] class]){

                if([MFMailComposeViewController canSendMail]){
                    NSArray* recipients = [[NSString stringWithFormat:@"%@@pushmail.notifica.re", [item objectForKey:@"token"]] componentsSeparatedByString: @","];
                    [self setMailComposer:[[MFMailComposeViewController alloc] init]];
                    [[self mailComposer] setMailComposeDelegate:self];
                    [[self mailComposer] setToRecipients:recipients];
                    [[self mailComposer] setSubject:LSSTRING(@"mail_subject_text")];
                    [[self mailComposer] setMessageBody:LSSTRING(@"mail_body_text") isHTML:NO];
                    [self presentViewController:[self mailComposer] animated:YES completion:^{
                        
                    }];
                    
                }
            }
            
            
        }
        
    }

}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    switch (result){
        case MFMailComposeResultSent:
            
            [self becomeFirstResponder];
            [self dismissViewControllerAnimated:YES completion:^{
                //
                APP_ALERT_DIALOG(LSSTRING(@"mail_success_text"));
            }];

            break;
        case MFMailComposeResultFailed:
            
            APP_ALERT_DIALOG(LSSTRING(@"mail_error_text"));
            
            break;
        default:
            [self becomeFirstResponder];
            [self dismissViewControllerAnimated:YES completion:^{
                //
            }];
            break;
    }
    
}


-(NSDictionary *)checkIfActivePicker:(NSIndexPath *)indexPath{
    
    for (NSDictionary * row in [[self navSections] objectAtIndex:[indexPath section]]) {

        if([row objectForKey:@"activePicker"]){
            return row;
        }
    }
    
    return nil;
}


-(void)OnSegmentsChanged:(id)sender{
    
    UISwitch *tempSwitch = (UISwitch *)sender;
    NotificareUserPreference * item = [[[self navSections] objectAtIndex:[tempSwitch tag] / 100] objectAtIndex:[tempSwitch tag] % 100];

    
    if([[item preferenceType] isEqualToString:@"single"]){
        
            
        NotificareSegment * seg = [[item preferenceOptions] objectAtIndex:0];
        
        if([tempSwitch isOn]){
            
            [[self notificare] addSegment:seg toPreference:item completionHandler:^(NSDictionary *info) {
                //
                NSLog(@"%@", info);
            } errorHandler:^(NSError *error) {
                //
                NSLog(@"%@", error);
            }];
            
        }else{
            
            [[self notificare] removeSegment:seg fromPreference:item completionHandler:^(NSDictionary *info) {
                //
                NSLog(@"%@", info);
            } errorHandler:^(NSError *error) {
                //
                NSLog(@"%@", error);
            }];
            
        }
        
    }
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
