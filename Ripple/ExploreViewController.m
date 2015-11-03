//
//  ExploreViewController.m
//  Bellow
//
//  Created by Paul Stavropoulos on 5/23/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import "ExploreViewController.h"
#import "BellowService.h"
#import "SwipeableCell.h"
#import "UserSearchCell.h"
#import "Bellow.h"
#import "TTTTimeIntervalFormatter.h"
#import "ImageViewerViewController.h"
#import "WebViewViewController.h"
#import "ProfilePageViewController.h"
#import "Flurry.h"
#import "MapView.h"
#import "AGPushNoteView.h"
#import "ShareRippleSheet.h"
#import "SearchViewController.h"
#import "TrendingCollectionViewCell.h"
#import "HeaderCollectionReusableView.h"


@interface ExploreViewController ()

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorFooter;
@property (strong, nonatomic) TTTTimeIntervalFormatter *timeIntervalFormatter;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) UITapGestureRecognizer *whileEditing;
@property (nonatomic) BOOL finishedFirstRun;
@property (strong, nonatomic) UIBarButtonItem *barButton;

@property (weak, nonatomic) IBOutlet UITextView *noContentTextView;

@property (strong, nonatomic) UISearchBar *searchField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topNoContentConstraint;

@property (nonatomic) BOOL isSearching;
@property (nonatomic) BOOL isTyping;
@property (nonatomic) CGFloat contentOffset;
@property (nonatomic) BOOL segueWithCommentsUp;

@end

@implementation ExploreViewController

// int PARSE_PAGE_SIZE = 25;


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MapViewSegue"]) {
        
        self.navigationItem.title = @"";
        
        // log event
        [PFAnalytics trackEvent:@"ViewCommentsAndMap" dimensions:@{@"Cell Type" : @"Trending"}];
        [Flurry logEvent:@"View_Comments_And_Map" withParameters:[NSDictionary dictionaryWithObject:@"trending" forKey:@"page"]];
        
        if ([segue.destinationViewController isKindOfClass:[MapView class]])
        {
            MapView *rmv = (MapView *) segue.destinationViewController;
            
            if ([sender isKindOfClass:[Bellow class]])
            {
                Bellow *ripple = (Bellow *)sender;
                rmv.ripple = ripple;

                if (self.segueWithCommentsUp)
                    rmv.commentsUp = YES;
            }
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.finishedFirstRun = NO;
    self.isSearching = NO;
    self.isTyping = NO;
    self.isAllTopRipples = NO;
    [self.noContentTextView setHidden:YES];
    
    if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [self.navigationController setHidesBarsOnSwipe:YES];
    
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
    
    // delegates and table setup
    self.searchField.delegate = self;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    // set up table refreshing
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshList) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    [self.collectionView setAlwaysBounceVertical:YES];
    
    // setup footer refreshcontrol
    self.indicatorFooter = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.collectionView.frame.size.width, 44)];
    [self.indicatorFooter setColor:[UIColor grayColor]];
    //[self.collectionView setTableFooterView:self.indicatorFooter];

    
    // call updateView
    [self updateView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // unhide button
    for(UIView *view in self.tabBarController.view.subviews)
    {
        if ([view isKindOfClass:[UIButton class]] && view.tag == 100)
        {
            [view setHidden:NO];
            break;
        }
    }
    
    self.finishedFirstRun = YES;
    self.navigationItem.hidesBackButton = NO;
    [self.tabBarController.tabBar setHidden:NO];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showTabBar" object:nil];
    
    // log stuff
    [PFAnalytics trackEvent:@"goToTrendingTab" dimensions:nil];
    [Flurry logEvent:@"Go_To_Trending_Tab" withParameters:nil];
    
}

- (void) hideComposeButton
{
    for(UIView *view in self.tabBarController.view.subviews)
    {
        if ([view isKindOfClass:[UIButton class]] && view.tag ==100)
        {
            [view setHidden:YES];
        }
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


- (void)updateView
{
    [self.activityIndicator startAnimating];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.trendingRipples= [BellowService getTopRipples:0];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            // self.selectedDataSource = self.followingUsers;
            [self.activityIndicator stopAnimating];
            [self.activityIndicator setHidden:YES];
        
        
            if (self.trendingRipples != nil && [self.trendingRipples count] > 0)
            {
                [self.indicatorFooter setHidden:NO];
                [self.indicatorFooter stopAnimating];
                
                [self.noContentTextView setHidden:YES];
            }
            
            else
            {
                [self.noContentTextView setHidden:NO];
                [self setTextNoContentTextView];
            }
            
            if ([self.trendingRipples count] <26) // PARSE_PAGE_SIZE)
                self.isAllTopRipples = YES;
            else
                self.isAllTopRipples = NO;

        
            [self.collectionView reloadData];
        });
    });
}

#pragma mark - collectionview methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return [self.trendingRipples count];
}

/*
-(UIView *)CollectionView
{
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(10, 5, [UIScreen mainScreen].bounds.size.width-40, 20);
    myLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:14];
    
    // text
    if (self.isSearching)
        myLabel.text = [NSString stringWithFormat:@"search results for \"%@\"",self.searchField.text];
    
    else
    {
        if ([[PFUser currentUser][@"following"] count] != 1)
            myLabel.text = [NSString stringWithFormat:@"following %u people", [[PFUser currentUser][@"following"] count]];
        else
            myLabel.text = [NSString stringWithFormat:@"following %u person", [[PFUser currentUser][@"following"] count]];
    }

    
    UIView *headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1.0]];
    [headerView addSubview:myLabel];
    
    
    return headerView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}
 */

- (TrendingCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TrendingCollectionViewCell *cell = (TrendingCollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"trendingCollectionCell" forIndexPath:indexPath];
    
    cell.ripple = [self.trendingRipples objectAtIndex:[indexPath row]];
    
    // if text, create view
    if (cell.ripple.imageFile)
    {
        // image work!
        [cell.rippleImageView setHidden:NO];
        [cell.rippleTextView setHidden:YES];
        cell.rippleImageView.image = [UIImage imageNamed:@"grayBox.png"];
    
        
        cell.rippleImageView.file = (PFFile *)cell.ripple.imageFile;
        [cell.rippleImageView loadInBackground];
        
        // size for ios7
        if ( [[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
        {
            CGFloat heightRatio = (float) cell.ripple.imageHeight / cell.ripple.imageWidth;
            if (cell.ripple.imageHeight > cell.ripple.imageWidth)
            {
                cell.imageWidthConstraint.constant = [UIScreen mainScreen].bounds.size.width - 1;
                //trendingCell.masterView.frame.size.width;
                cell.imageHeightConstraint.constant = ([UIScreen mainScreen].bounds.size.width - 1) * heightRatio;
                //trendingCell.masterView.frame.size.width * heightRatio;
            }
            else
            {
                cell.imageHeightConstraint.constant = cell.frame.size.height;
                cell.imageWidthConstraint.constant = cell.frame.size.height / heightRatio;
            }
            
            [cell layoutIfNeeded];
            [cell updateConstraintsIfNeeded];
        }
    }
    
    else
    {
        [cell.rippleTextView setHidden:NO];
        [cell.rippleImageView setHidden:YES];
        
        // grab text and display it
        [cell.rippleTextView setEditable:YES];
        [cell.rippleTextView setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:18.0]];
        [cell.rippleTextView setTextAlignment:NSTextAlignmentCenter];
        [cell.rippleTextView setEditable:NO];
        [cell.rippleTextView setSelectable:NO];
        [cell.rippleTextView setUserInteractionEnabled:NO];
        [cell.rippleTextView setText:cell.ripple.text];
    }
    
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake([UIScreen mainScreen].bounds.size.width - 1 , [UIScreen mainScreen].bounds.size.width - 1);
    // return CGSizeMake([UIScreen mainScreen].bounds.size.width - 0.5 , [UIScreen mainScreen].bounds.size.width - 0.5);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // grab the item from trending array
    Bellow *selectedRipple = [self.trendingRipples objectAtIndex:[indexPath row]];
    
    // segue
    [self performSegueWithIdentifier:@"MapViewSegue" sender:selectedRipple];
    
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    // set cell height accordingly.
    TrendingCollectionViewCell *trendingCell = (TrendingCollectionViewCell *)cell;
    if (trendingCell.ripple.imageFile)
    {
        // set text top constraint if  have image
        CGFloat heightRatio = (float) trendingCell.ripple.imageHeight / trendingCell.ripple.imageWidth;
        if (trendingCell.ripple.imageHeight > trendingCell.ripple.imageWidth)
        {
            trendingCell.imageWidthConstraint.constant = [UIScreen mainScreen].bounds.size.width - 1;
            //trendingCell.masterView.frame.size.width;
            trendingCell.imageHeightConstraint.constant = ([UIScreen mainScreen].bounds.size.width - 1) * heightRatio;
            //trendingCell.masterView.frame.size.width * heightRatio;
        }
        else
        {
            trendingCell.imageHeightConstraint.constant = trendingCell.frame.size.height;
            trendingCell.imageWidthConstraint.constant = trendingCell.frame.size.height / heightRatio;
        }
        
        [cell layoutIfNeeded];
        [cell updateConstraintsIfNeeded];
    }
    if ([indexPath row] == [self.trendingRipples count] - 8)
    {
        //[self.indicatorFooter startAnimating];
            
        // call method to create ripples with block to reload
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *newTrendingRipples = [BellowService getTopRipples:(int)[self.trendingRipples count]];
            
            if (newTrendingRipples.count < 26)
                self.isAllTopRipples = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.trendingRipples addObjectsFromArray:newTrendingRipples];
                //[self.indicatorFooter stopAnimating];
                [self.collectionView reloadData];
            });
        });
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader)
    {
        HeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"sectionHeader" forIndexPath:indexPath];
        
        [headerView.headerLabel setText:@"Trending Ripples:"];
       
        reusableview = headerView;
    }
    
    return reusableview;
}

- (void)refreshList
{
    [self updateView];
    
    // call service and update table
    [self.refreshControl endRefreshing];
}

- (void) goToImageView: (Bellow *)ripple
{
    // modal image view
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ImageViewerViewController *imageView = [storyboard instantiateViewControllerWithIdentifier:@"ImageView"];

    imageView.rippleImageFile = ripple.imageFile;
    imageView.imageHeight = ripple.imageHeight;
    imageView.imageWidth = ripple.imageWidth;
    
    [self presentViewController:imageView animated:YES completion:nil];
    
    [Flurry logEvent:@"Image_Open_Explore"];
}


#pragma mark - searchbar methods
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    SearchViewController *svc = [storyboard instantiateViewControllerWithIdentifier:@"SearchView"];
    
    self.navigationItem.title = @"";
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:svc animated:NO];
}

-(void)setTextNoContentTextView
{
    // setup noContentViewText
    [self.noContentTextView setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0]];
    [self.noContentTextView setTextAlignment:NSTextAlignmentCenter];

    if (self.isSearching)
        [self.noContentTextView setText:@"There are no results for this search."];
    else
        [self.noContentTextView setText:@"You are not following anyone. Search for people to follow."];
    
    [self.noContentTextView setTextAlignment:NSTextAlignmentCenter];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"Invite your friends!"])
    {
        if (buttonIndex == 1)
        {
            NSString *shareText = [NSString stringWithFormat:@"Hey, I just downloaded the app Bellow and you should also try it out! Use my referral code \"%@\" to get 200 points when you sign in. Download it on the iOS or Google Play store, or at www.getRipple.io" , [PFUser currentUser][@"username"]];
            
            UIActivityViewController *shareController = [ShareRippleSheet shareRippleSheet:shareText];
            [self presentViewController:shareController animated:YES completion:nil];
        }
    }
    
}

#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
    
    if (self.isTyping)
    {
        [self.searchField resignFirstResponder];
        self.isTyping = NO;
    }

    
    if (scrollView.contentOffset.y <60)
    {
        [[self navigationController] setNavigationBarHidden:NO animated:NO];
        if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
            [self.navigationController setHidesBarsOnSwipe:NO];
    }
    
    else if(scrollView.contentOffset.y > self.contentOffset + 5)
    {
        if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
            [self.navigationController setHidesBarsOnSwipe:YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideTabBar" object:nil];
    }
    
    else if (scrollView.contentOffset.y < self.contentOffset - 5)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showTabBar" object:nil];
        [self.tabBarController.tabBar setHidden:NO];
        [[self navigationController] setNavigationBarHidden:NO animated:YES];
    }
    
    self.contentOffset = scrollView.contentOffset.y;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
@end