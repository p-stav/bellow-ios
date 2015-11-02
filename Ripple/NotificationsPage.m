//
//  NotificationsPage.m
//  Ripple
//
//  Created by Gal Oshri on 4/26/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import "NotificationsPage.h"
#import "BellowService.h"
#import "Notification.h"
#import "Ripple.h"
#import "MapView.h"
#import "NotificationTableViewCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "Flurry.h"

@interface NotificationsPage ()
@property (strong, nonatomic) TTTTimeIntervalFormatter *timeIntervalFormatter;
@property (strong, nonatomic) Ripple *selectedRipple;
@end

@implementation NotificationsPage

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.selectedRipple = nil;
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        self.notificationArray = [BellowService getNotifications];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
    
    // set up table refreshing
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshList) forControlEvents:UIControlEventValueChanged];
    
    // setup navigation title
    UIView *titleView = [[UIView alloc] initWithFrame: CGRectMake(0,40,[UIScreen mainScreen].bounds.size.width - 100, 44)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleView.frame.size.width/2 - 110,0,220, 44)];
    
    [titleLabel setFont:[UIFont fontWithName:@"Avenir" size:22.0]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:@"Notifications"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleView addSubview:titleLabel];
    self.navigationItem.titleView = titleView;
    [self.navigationItem.titleView setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2, self.navigationController.navigationBar.frame.size.height/2)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    // unhide nav bar
    if ([self.tabBarController.tabBar isHidden])
    {
        [self.tabBarController.tabBar setHidden:NO];
        
        // unhide button
        for(UIView *view in self.tabBarController.view.subviews)
        {
            if ([view isKindOfClass:[UIButton class]] && view.tag == 100)
            {
                [view setHidden:NO];
                break;
            }
        }
    }
    
    // set all isSeento True
    UITabBarItem *tbi = [self.tabBarController.tabBar.items objectAtIndex:3];
    if (tbi.badgeValue !=nil)
    {
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [BellowService sawAllNotifications];
        });

        tbi.badgeValue= nil;
        [self refreshList];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        [tbi setBadgeValue:nil];
    }
}

- (TTTTimeIntervalFormatter *)timeIntervalFormatter
{
    if (!_timeIntervalFormatter)
    {
        _timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        _timeIntervalFormatter.usesAbbreviatedCalendarUnits = YES;
    }
    return _timeIntervalFormatter;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.notificationArray count];
}


- (NotificationTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell" forIndexPath:indexPath];
    cell.notification = [self.notificationArray objectAtIndex:[indexPath row]];
    
    
    // get and center text vertically
    cell.notificationText.text = cell.notification.text;
    CGFloat topCorrect = ([cell.notificationText bounds].size.height - [cell.notificationText contentSize].height * [cell.notificationText zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    cell.notificationText.contentOffset = (CGPoint){ .x = 0, .y = -topCorrect };
    
    // put zeh right image, my friend!
    if ([cell.notification.type isEqualToString:@"Ripple"])
        cell.notificationImage.image = [UIImage imageNamed:@"rippleNotification.png"];
    else if ([cell.notification.type isEqualToString:@"User"])
        cell.notificationImage.image = [UIImage imageNamed:@"userNotification.png"];
    else if ([cell.notification.type isEqualToString:@"Comment"])
        cell.notificationImage.image = [UIImage imageNamed:@"commentNotification.png"];
    
    if (!cell.notification.isRead)
    {
        [cell.notificationText setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:14.0]];
    }
    else
    {
        [cell.notificationText setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:14.0]];
    }
    
    NSTimeInterval timeInterval = [cell.notification.createdAt timeIntervalSinceNow];
    cell.createdAtLabel.text = [NSString stringWithFormat:@"%@", [self.timeIntervalFormatter stringForTimeInterval:timeInterval]];
    

    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 105.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Notification *notification = [self.notificationArray objectAtIndex:[indexPath row]];
    
    // Act based on the notification type
    if ([notification.type isEqualToString:@"Ripple"] || [notification.type isEqualToString:@"Comment"])
    {
        [self notificationClickMyRipple:notification.rippleId];
        
    }
    
    if ([notification.type isEqualToString:@"User"])
    {
        [self.tabBarController setSelectedIndex:4];
    }
    
    // update cell
    if (notification.isRead == NO)
    {
        [BellowService completeNotification:notification.notificationId];
        
        notification.isRead = YES;
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
}

- (void)notificationClickMyRipple:(NSString *)rippleId
{
    
    // Get appropriate ripple
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        Ripple *ripple = [BellowService getRipple:rippleId];
        self.selectedRipple = ripple;
        
        dispatch_async( dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"NotificationToRippleSegue" sender:self.selectedRipple];
            self.selectedRipple = nil;
        });
    });
}


#pragma mark - refresh list
- (void)refreshList
{
    // call service and update table
    [self.refreshControl endRefreshing];
    
    // [self.noRipplesTextView setHidden:YES];
    // [self.tableView setAlpha:1.0];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        self.notificationArray = [BellowService getNotifications];

        dispatch_async( dispatch_get_main_queue(), ^{
           /* if ([self.selectedRippleArray count] > 0)
                [self.noRipplesTextView setHidden:YES];
            else
            {
                [self displayNoRipplesViewForSort];
            }
            */
            [self.tableView reloadData];
        });
    });
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.navigationItem.title = @"";
    if ([segue.identifier isEqualToString:@"NotificationToRippleSegue"]) {
        
        if ([segue.destinationViewController isKindOfClass:[MapView class]])
        {
            MapView *rmv = (MapView *) segue.destinationViewController;
            
            if ([sender isKindOfClass:[Ripple class]])
            {
                Ripple *ripple = (Ripple *)sender;
                rmv.ripple = ripple;
            }
            
            // log data
            [PFAnalytics trackEvent:@"ViewCommentsAndMap" dimensions:@{@"Cell Type" : @"Notification Cell"}];
            [Flurry logEvent:@"View_Comments_And_Map" withParameters:[NSDictionary dictionaryWithObject:@"notification" forKey:@"page"]];
        }
    }
}



@end
