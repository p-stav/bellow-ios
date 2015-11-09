    //
//  SearchViewController.m
//  Bellow
//
//  Created by Paul Stavropoulos on 10/4/15.
//  Copyright © 2015 Kefi Labs. All rights reserved.
//

#import <Parse/Parse.h>
#import "BellowService.h"
#import "SearchViewController.h"
#import "Flurry.h"
#import "ShareRippleSheet.h"
#import "UserSearchCell.h"
#import "ProfilePageViewController.h"

@interface SearchViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITextView *noContentTextView;
@property (weak, nonatomic) IBOutlet UIButton *inviteButton;
@property (strong, nonatomic) NSMutableArray *searchResults;

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UITapGestureRecognizer *whileEditing;
@property (strong, nonatomic) UIBarButtonItem *barButton;
@property (strong, nonatomic) UISearchBar *searchField;

@property (nonatomic) BOOL isTyping;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // controls and bools
    self.isTyping = NO;
    [self.activityIndicator stopAnimating];
    [self.activityIndicator setHidden:YES];
    self.navigationController.hidesBarsOnSwipe = NO;
    self.navigationItem.hidesBackButton = YES;
    //self.view
    
    // setup navigation title
    UIView *titleView = [[UIView alloc] initWithFrame: CGRectMake(0,40,[UIScreen mainScreen].bounds.size.width - 80, 44)];
    self.searchField = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, titleView.frame.size.width, titleView.frame.size.height)];
    [self.searchField setBackgroundImage:[UIImage new]];
    [self.searchField setTranslucent:YES];
    [self.searchField setPlaceholder:@"search for a user..."];
    [self.searchField setTintColor:[UIColor whiteColor]];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:[UIColor colorWithRed:3.0/255.0f green:123.0f/255 blue:255.0f/255 alpha:1.0]];
    
    [self.searchDisplayController.searchBar setSearchBarStyle:UISearchBarStyleMinimal];
    [titleView addSubview:self.searchField];
    self.navigationItem.titleView = titleView;
    
    // set up bar button
    UIButton *barBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 25)];
    [barBtn.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:14.0]];
    [barBtn setTitle:@"cancel" forState:UIControlStateNormal];
    [barBtn addTarget:self action:@selector(didPressCancel) forControlEvents:UIControlEventTouchUpInside];
    self.barButton = [[UIBarButtonItem alloc] initWithCustomView:barBtn];

    // uitapgesture
    UITapGestureRecognizer *tapRecognizerTextField = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchEventOnView:)];
    [tapRecognizerTextField setNumberOfTapsRequired:1];
    [tapRecognizerTextField setDelegate:self];
    self.whileEditing = tapRecognizerTextField;
    
    // delegates and table setup
    self.searchField.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // set up table refreshing
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshList) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
    
    // show textview and say search
    [self.noContentTextView setText:@"search for a user"];
    [self.noContentTextView setHidden:NO];
    [self.inviteButton setHidden:NO];
    [self.tableView setHidden:YES];
    [self.noContentTextView setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:17.0]];
    [self.noContentTextView setTextAlignment:NSTextAlignmentCenter];
    
    // logging items
    [PFAnalytics trackEvent:@"goToSearchView" dimensions:nil];
    [Flurry logEvent:@"Go_To_Search_View" withParameters:nil];
    
    // make searchbar first responder
    [self.searchField becomeFirstResponder];
    
    // add observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatefollowingNotification:) name:@"updateFollowing" object:nil];
    
    // if we searched from previous view
    if (self.searchString)
        [self performSearch:self.searchString];
        
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // hide tab bar, show nav bar
    [self.tabBarController.tabBar setHidden:YES];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideTabBar" object:nil];
    
    
}

- (void) updateView
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![self.searchField.text isEqualToString:@""] && ![self.searchField.text isEqualToString:@" "])
            self.searchResults = [BellowService getSearchResults:self.searchField.text];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            [self.activityIndicator stopAnimating];
            [self.activityIndicator setHidden:YES];
                
            if (self.searchResults != nil && [self.searchResults count] > 0)
            {
                [self.noContentTextView setHidden:YES];
                [self.inviteButton setHidden:YES];
                [self.tableView setHidden:NO];
            }
            
            else
            {
                [self.noContentTextView setHidden:NO];
                [self setTextNoContentTextView];
                [self.inviteButton setHidden:NO];
                [self.tableView setHidden:YES];
            }
            
            [self.tableView reloadData];
        });
    });
}


#pragma mark - searchbar methods
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    // switch data source
    [self beginEditing];
    self.navigationItem.rightBarButtonItem = self.barButton;
}

- (void) beginEditing
{
    //self.searchField.clearButtonMode = UITextFieldViewModeAlways;
    if (self.searchResults == nil)
        self.searchResults = [[NSMutableArray alloc]init];
    
    //call selector to dismiss keyboard code if it is present
    [self.view addGestureRecognizer:self.whileEditing];
    self.isTyping = YES;
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self.view removeGestureRecognizer:self.whileEditing];
    [searchBar setShowsCancelButton:NO animated:YES];
    self.isTyping = NO;
}


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([searchBar.text isEqualToString:@""] || [searchBar.text isEqualToString:@" "] )
        return;
    
    [self.view endEditing:YES];
    [searchBar resignFirstResponder];
    [self.view removeGestureRecognizer:self.whileEditing];
    
    // find results from cloud service
    [self performSearch:searchBar.text];
}

- (void)performSearch:(NSString *)search
{
    // find results from cloud service
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.searchResults = [BellowService getSearchResults:search];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            
            if ([self.searchResults count] > 0)
            {
                [self.noContentTextView setHidden:YES];
                [self.inviteButton setHidden:YES];
                [self.tableView setHidden:NO];
            }
            else
            {
                [self.noContentTextView setHidden:NO];
                [self setTextNoContentTextView];
                [self.inviteButton setHidden:NO];
                [self.tableView setHidden:YES];
            }
            
            [self.activityIndicator setHidden:YES];
            [self.activityIndicator stopAnimating];
            [self.tableView reloadData];
        });
    });

}

- (void)touchEventOnView: (id) sender
{
    // remove gesture
    UITapGestureRecognizer *gestureRecognizer = sender;
    [self.view removeGestureRecognizer:gestureRecognizer];
    
    [self.view endEditing:YES];
}

#pragma mark - table methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self setSearchCell:tableView withIndexPath:indexPath];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(10, 5, [UIScreen mainScreen].bounds.size.width-40, 20);
    myLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:14];
    
    // text
    if ([self.searchResults count] != 0)
    {
        if (self.searchString)
        {
            myLabel.text = [NSString stringWithFormat:@"search results for \"%@\"",self.searchString];
            self.searchString = nil;
        }
        else
            myLabel.text = [NSString stringWithFormat:@"search results for \"%@\"",self.searchField.text];
    }
    else
        myLabel.text = @"No search results";
        
    UIView *headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1.0]];
    [headerView addSubview:myLabel];
    
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UserSearchCell *)setSearchCell:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath
{
    [tableView registerNib:[UINib nibWithNibName:@"UserSearchCell" bundle:nil] forCellReuseIdentifier: @"SearchResultCell"];
    
    UserSearchCell *cell = (UserSearchCell *)[tableView dequeueReusableCellWithIdentifier:@"SearchResultCell" forIndexPath:indexPath];
    
    NSDictionary *user = [self.searchResults objectAtIndex:[indexPath row]];
    
    
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


#pragma mark - cell methods
- (void)pushUserProfile: (NSString *)userId
{
    // push same view controller
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ProfilePageViewController *sameView = [storyboard instantiateViewControllerWithIdentifier:@"Me"];
    sameView.userId = userId;
    [Flurry logEvent:@"Profile_Open_Explore"];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:sameView animated:YES];
}

- (void)updateFollowing: (NSString *)userId;
{
    // find userId in data source
    NSInteger followingPosition = [self.searchResults indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[(NSDictionary *)obj objectForKey:@"objectId"] isEqualToString:userId])
        {
            *stop = YES;
            return YES;
        }
        
        return NO;
    }];
    
    if (followingPosition != NSNotFound)
    {
        NSMutableDictionary *dict = [self.searchResults objectAtIndex:followingPosition];
        
        if([dict[@"isFollowing"] boolValue] == YES)
            dict[@"isFollowing"] = [NSNumber numberWithBool:NO];
        else
            dict[@"isFollowing"] = [NSNumber numberWithBool:YES];
        
        [self.searchResults replaceObjectAtIndex:followingPosition withObject:dict];
        [self.tableView reloadData];
    }
}

- (void) updatefollowingNotification: (NSNotification *)notification {
    NSString *userId = (NSString *)[notification object];
    
    [self updateFollowing:userId];
}


#pragma mark - housekeeping
- (void)refreshList
{
    [self updateView];
    
    // call service and update table
    [self.refreshControl endRefreshing];
}

- (void)didPressCancel
{
    self.navigationItem.rightBarButtonItem = nil;
    [self.view removeGestureRecognizer:self.whileEditing];
    [self.searchField resignFirstResponder];
    [self.view endEditing:YES];
    self.isTyping = NO;
    
    // pop view controller
    [self.navigationController popViewControllerAnimated:NO];
}
- (IBAction)didPressInviteButton:(id)sender
{
    NSString *shareText = [NSString stringWithFormat:@"Hey, I just downloaded the app Bellow and you should also try it out! Use my referral code \"%@\" to get 200 points when you sign in. Download it on the iOS or Google Play store, or at www.getRipple.io" , [PFUser currentUser][@"username"]];
    
    UIActivityViewController *shareController = [ShareRippleSheet shareRippleSheet:shareText];
    [self presentViewController:shareController animated:YES completion:nil];
}

-(void)setTextNoContentTextView
{
    // setup noContentViewText
    [self.noContentTextView setEditable:YES];
    [self.noContentTextView setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:17.0]];
    [self.noContentTextView setTextAlignment:NSTextAlignmentCenter];
    [self.noContentTextView setText:@"There are no results for this search."];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"Invite your friends!"])
    {
        if (buttonIndex == 1)
        {
            NSString *shareText = [NSString stringWithFormat:@"Hey, I just downloaded the app Bellow. You should also try it out! Use my referral code \"%@\" to get 200 points when you sign in. Download it on the iOS or Google Play store, or at www.getRipple.io" , [PFUser currentUser][@"username"]];
            
            UIActivityViewController *shareController = [ShareRippleSheet shareRippleSheet:shareText];
            [self presentViewController:shareController animated:YES completion:nil];
        }
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
    
    if (self.isTyping)
    {
        [self.searchField resignFirstResponder];
        self.isTyping = NO;
    }
}
@end