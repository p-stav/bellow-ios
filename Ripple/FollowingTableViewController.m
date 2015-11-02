//
//  FollowingTableViewController.m
//  Ripple
//
//  Created by Paul Stavropoulos on 8/25/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import "FollowingTableViewController.h"
#import "ProfilePageViewController.h"
#import "RippleService.h"
#import "UserSearchCell.h"
#import "Flurry.h"

@interface FollowingTableViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation FollowingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set up navigation
    self.extendedLayoutIncludesOpaqueBars = YES;
    [self.tabBarController.tabBar setHidden:NO];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideTabBar" object:nil];
    
    // setup title view
    UIView *titleView = [[UIView alloc] initWithFrame: CGRectMake(0,40,[UIScreen mainScreen].bounds.size.width - 100, 44)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleView.frame.size.width/2 - 110,0,220, 44)];
    [titleLabel setFont:[UIFont fontWithName:@"Avenir" size:22.0]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    titleLabel.text= @"Following";
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleView addSubview:titleLabel];
    self.navigationItem.titleView = titleView;
    [self.navigationItem.titleView setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2, self.navigationController.navigationBar.frame.size.height/2)];
    

    
    // set up table refreshing
    [self.refreshControl addTarget:self action:@selector(refreshList) forControlEvents:UIControlEventValueChanged];
    
    [self updateView];
    
    // add observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatefollowingNotification:) name:@"updateFollowing" object:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void) updateView
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.followingUsers = [RippleService getFollowingUsers];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.followingUsers count];
}


- (UserSearchCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView registerNib:[UINib nibWithNibName:@"UserSearchCell" bundle:nil] forCellReuseIdentifier: @"SearchResultCell"];
    
    UserSearchCell *cell = (UserSearchCell *)[tableView dequeueReusableCellWithIdentifier:@"SearchResultCell" forIndexPath:indexPath];
    
    NSDictionary *user = [self.followingUsers objectAtIndex:[indexPath row]];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    
    cell.isFollowing =[user[@"isFollowing"] boolValue];
    cell.objectId = user[@"objectId"];
    cell.username.text = user[@"username"];
    cell.level.text = user[@"level"];
    
    if ((BOOL) cell.isFollowing == YES)
        [cell.followerImage setImage:[UIImage imageNamed:@"following.png"] forState:UIControlStateNormal];
    else
        [cell.followerImage setImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)pushUserProfile: (NSString *)userId
{
    // push same view controller
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ProfilePageViewController *sameView = [storyboard instantiateViewControllerWithIdentifier:@"Me"];
    sameView.userId = userId;
    [Flurry logEvent:@"Profile_Open_Following"];
    
    [self.navigationController pushViewController:sameView animated:YES];
}

- (void)updateFollowing: (NSString *)userId;
{
    // find userId in data source
    NSInteger followingPosition = [self.followingUsers indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[(NSDictionary *)obj objectForKey:@"objectId"] isEqualToString:userId])
        {
            *stop = YES;
            return YES;
        }
        
        return NO;
    }];
    
    if (followingPosition != NSNotFound)
    {
        NSMutableDictionary *dict = [self.followingUsers objectAtIndex:followingPosition];
        
        if([dict[@"isFollowing"] boolValue] == YES)
            dict[@"isFollowing"] = [NSNumber numberWithBool:NO];
        else
            dict[@"isFollowing"] = [NSNumber numberWithBool:YES];
        
        [self.followingUsers replaceObjectAtIndex:followingPosition withObject:dict];
        [self.tableView reloadData];
    }
}

- (void) updatefollowingNotification: (NSNotification *)notification {
    NSString *userId = (NSString *)[notification object];
    
    [self updateFollowing:userId];
}


- (void)refreshList
{
    [self updateView];
    
    // call service and update table
    [self.refreshControl endRefreshing];
}

@end
