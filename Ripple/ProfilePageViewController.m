//
//  ProfilePageTableViewController.m
//  Ripple
//
//  Created by Paul Stavropoulos on 4/21/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import "ProfilePageViewController.h"
#import "MyRippleCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "Flurry.h"
#import "MapView.h"
#import "RippleLogInView.h"
#import "RippleSignUpView.h"
#import "BellowService.h"
#import "ImageCropping.h"
#import "BellowLevel.h"
#import "HeaderTableViewCell.h"
#import "ImageViewerViewController.h"
#import "WebViewViewController.h"
#import "ShareRippleSheet.h"
#import "AGPushNoteView.h"

@interface ProfilePageViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicatorFooter;
@property (weak, nonatomic) IBOutlet UITextView *noRipplesTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noTextTopConstraint;

@property (strong, nonatomic) NSArray *sortButtons;
@property (strong, nonatomic) NSMutableArray *sortImages;
@property (strong, nonatomic) UITapGestureRecognizer *dismissSort;
@property (nonatomic) int sortMethod;
@property (nonatomic) int filterMethod;
@property (nonatomic) CGFloat contentOffset;


@property (strong, nonatomic) IBOutlet UIView *tableHeader;
@property (weak, nonatomic) IBOutlet UIButton *loginSignupProfileButton;
@property (weak, nonatomic) IBOutlet UILabel *highestPropagatedLabel;
@property (strong, nonatomic) IBOutlet UIView *progressBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressBarWidthConstraint;
@property (strong, nonatomic) IBOutlet UIView *progressBackground;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *rippleLevel;
@property (weak, nonatomic) IBOutlet UIButton *pointsToNextLevel;
@property (weak, nonatomic) IBOutlet UITextView *firstLevelTextView;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIButton *followingLabel;
@property (strong, nonatomic) IBOutlet UIButton *followingNum;
@property (weak, nonatomic) IBOutlet UIButton *followersLabel;
@property (weak, nonatomic) IBOutlet UIButton *followersNum;


@property (nonatomic) BOOL isStartedCompleted;
@property (nonatomic) BOOL isSpreadCompleted;
@property (nonatomic) BOOL newRippleCreated;
@property (nonatomic) BOOL segueWithCommentsUp;
@property (nonatomic) float isChoosingSort;
@property (nonatomic) int headerHeight;


@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) TTTTimeIntervalFormatter *timeIntervalFormatter;
@property (strong, nonatomic) NSArray *selectedRippleArray;
@property (strong, nonatomic) NSString *defaultNoPendingRippleString;
@property (nonatomic) BOOL viewDidLoadJustRan;
@property (strong, nonatomic) NSURL *url;
@property (nonatomic) int referralNum;

@property (strong, nonatomic) NSMutableDictionary *profileToHandle;


@end

@implementation ProfilePageViewController

NSString *defaultNoRipplesString;
NSDictionary *socialMediaIconToName;
// int PARSE_PAGE_SIZE = 25;

+ (void) initialize {
    socialMediaIconToName = [NSDictionary dictionaryWithObjectsAndKeys:
    @"instagram.png",@"Instagram",
    @"website.png", @"Website",
    @"twitter.png", @"Twitter",
     nil];
}

- (NSDictionary *) getSocialMediaIconToName {
    return socialMediaIconToName;
}

-(void) saveSocialMediaProfile:(NSString *) profileType withHandle:(NSString *) handle {
    NSMutableDictionary *profileToHandle = self.currentUser[@"accessibleProfiles"];
    if(profileToHandle == nil) {
        profileToHandle = [NSMutableDictionary dictionary];
        for(NSString *key in socialMediaIconToName) {
            // The values of the socialMediaIconToName dictionary are the social media types (Facebook, Twitter, etc...). They will be the keys in the profileToHandle dictionary.
            NSString *profileType = key;
            [profileToHandle setObject:@"" forKey:profileType];
        }
    }
    
    [profileToHandle setObject:handle forKey:profileType];
    
    self.currentUser[@"accessibleProfiles"] = profileToHandle;
    [self.currentUser saveInBackground];
}

-(BOOL) isCurrentUserProfile {
    return self.userId == nil;
}

-(NSString *) getUserIdString {
    return self.userId;
}

-(void) goToMapView:(Ripple *)ripple withComments:(BOOL)commentsUp
{
    if (commentsUp)
        self.segueWithCommentsUp = YES;
    else
        self.segueWithCommentsUp = NO;
    
    if (!self.isChoosingSort)
        [self performSegueWithIdentifier:@"MapViewSegue" sender:ripple];

}

- (void) goToImageView: (Ripple *)ripple
{
    if (!self.isChoosingSort)
    {
        
        if (ripple.imageFile)
        {
            [self performSegueWithIdentifier:@"RippleImageView" sender:ripple];
            [Flurry logEvent:@"Image_Open_Profile"];
        }
    }
}

- (void) goToUserProfile: (Ripple *)ripple
{
    if (ripple)
    {
        if (self.userId && ![self.currentUser.objectId isEqualToString:ripple.creatorId])
        {
            [self pushUserProfile:ripple.creatorId];
        }
        else if (!self.userId && ![ripple.creatorId isEqualToString: [PFUser currentUser].objectId])
        {
            [self pushUserProfile:ripple.creatorId];
        }
        
        else
        {
            // shake it
            CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
            [shake setDuration:0.1];
            [shake setRepeatCount:1];
            [shake setAutoreverses:YES];
            [shake setFromValue:[NSValue valueWithCGPoint:
                                     CGPointMake([self.tableView center].x - 5.0f, [self.tableView center].y)]];
            [shake setToValue:[NSValue valueWithCGPoint:
                                   CGPointMake([self.tableView center].x + 5.0f, [self.tableView center].y)]];
            [[self.tableView layer] addAnimation:shake forKey:@"position"];
        }
    }
}

- (void)pushUserProfile: (NSString *)creatorId
{
    // push same view controller
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ProfilePageViewController *sameView = [storyboard instantiateViewControllerWithIdentifier:@"Me"];
    sameView.userId = creatorId;
    [self.navigationController setNavigationBarHidden:NO];
    
    [self.navigationController pushViewController:sameView animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embededIconSegue"]) {
        SocialMediaCollectionViewController * tableViewController = (SocialMediaCollectionViewController *) [segue destinationViewController];
        tableViewController.delegate = self;
    }
    
    if ([segue.identifier isEqualToString:@"WebViewSegue"]) {
        [Flurry logEvent:@"Web_Open_MapView"];
        [PFAnalytics trackEvent:@"SegueToWebView" dimensions:nil];
        WebViewViewController *wvc = (WebViewViewController *)segue.destinationViewController;
        wvc.url = self.url;
    }
    
    if ([segue.identifier isEqualToString:@"MapViewSegue"]) {
        
        self.navigationItem.title = @"";
        
        // log event
        [PFAnalytics trackEvent:@"ViewCommentsAndMap" dimensions:@{@"Cell Type" : @"Profile"}];
        
        if ([segue.destinationViewController isKindOfClass:[MapView class]])
        {
            MapView *mv = (MapView *) segue.destinationViewController;
            
            if ([sender isKindOfClass:[Ripple class]])
            {
                Ripple *ripple = (Ripple *)sender;
                mv.ripple = ripple;
                
                if (self.segueWithCommentsUp)
                    mv.commentsUp = YES;
            }
        }
    }
    
    
    if ([segue.identifier isEqualToString:@"RippleImageView"])
    {
        if ([sender isKindOfClass:[Ripple class]])
        {
            Ripple *ripple = (Ripple *)sender;
            
            ImageViewerViewController *ivvc = (ImageViewerViewController *)segue.destinationViewController;
            ivvc.rippleImageFile = ripple.imageFile;
            ivvc.imageHeight = ripple.imageHeight;
            ivvc.imageWidth = ripple.imageWidth;
        }
    }
    
    if ([segue.identifier isEqualToString:@"SegueToWebViewFromHome"])
    {
        if ([sender isKindOfClass:[NSURL class]])
        {
            WebViewViewController *wvc = (WebViewViewController *)segue.destinationViewController;
            wvc.url = (NSURL *)sender;
        }
    }
    
    if ([segue.identifier isEqualToString:@"SegueToFollowingUsers"]) {
        self.navigationItem.title = @"";
    }
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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.profileToHandle = nil;
    self.contentOffset = 0;
    
    // navigtion bar stuff
    self.navigationItem.hidesBackButton = NO;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    if (!self.userId)
    {
        // set up bar button
        UIButton *barBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
        [barBtn setImage:[UIImage imageNamed:@"settingGear.png"] forState:UIControlStateNormal];
        [barBtn addTarget:self action:@selector(didPressSettings) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:barBtn];
        self.navigationItem.rightBarButtonItem = barButton;
        
        // Set up notification for when a ripple is create
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyNewRipple:) name:@"NewRippleStart" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyNewRippleEnd:) name:@"NewRippleEnd" object:nil];
        
        // make swipeable dissappear and stuff
    }
    else
    {
        // tab bar hidden
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(swipedRippleUpdateUserProfile:) name:@"swipedRippleUpdateUserProfile" object:nil];
        
        if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
            [self.navigationController setHidesBarsOnSwipe:NO];
    }

    
    
    self.currentUser = [[PFUser alloc] init];
    // assign delegates
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    
    // setup refreshcontrol
    // set up table refreshing
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshList) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
    
    // setup footer refreshcontrol
    self.indicatorFooter = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    [self.indicatorFooter setColor:[UIColor grayColor]];
    [self.tableView setTableFooterView:self.indicatorFooter];
    
    
    // hide things
    [self.highestPropagatedLabel setHidden:YES];
    [self.pointsLabel setHidden:YES];
    [self.followersNum setHidden:YES];
    [self.followingNum setHidden:YES];
    [self.followingLabel setHidden:YES];
    [self.followersLabel setHidden:YES];
    // [self.reachImage setHidden:YES];
    [self.firstLevelTextView setHidden:YES];
    [self.loginSignupProfileButton setHidden:YES];
    [self.pointsToNextLevel setHidden:YES];
    [self.progressBackground setHidden:YES];
    [self.rippleLevel setHidden:YES];
    
    
    // bools and original values
    self.viewDidLoadJustRan = YES;
    self.newRippleCreated = NO;
    self.sortMethod = 0;
    self.filterMethod = 0;
    self.isChoosingSort = NO;
    self.headerHeight = 75;
    self.profileToHandle = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self hideTabBar];
    if (self.viewDidLoadJustRan)
    {
        self.viewDidLoadJustRan = NO;            
        
        if (self.userId)
        {
            // this is someone else's profile page
            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                self.user = [BellowService getUser:self.userId];
                self.userLevels = [BellowService getRippleLevels];
                
                if ([self.myRipples count] < 25) //PARSE_PAGE_SIZE)
                {
                    self.isAllMyRipples = YES;
                }
                else
                {
                    self.isAllMyRipples = NO;
                }
                
                dispatch_async( dispatch_get_main_queue(), ^{
                    self.currentUser = self.user;
                    [self updateView];
                    [self setupHeaderView];
                    [self showExperienceBar];
                    
                
                });
            });
        }

        else
        {
            self.currentUser = [PFUser currentUser];
            
            // Get My ripples
            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                // Add code here to do background processing
                self.userLevels = [BellowService getRippleLevels];
                self.selectedRippleArray = self.myRipples;
                if ([self.myRipples count] < 25) //PARSE_PAGE_SIZE)
                {
                    self.isAllMyRipples = YES;
                }
                else
                {
                    self.isAllMyRipples = NO;
                }
                
                dispatch_async( dispatch_get_main_queue(), ^{
                    [self updateView];
                    [self setupHeaderView];
                    [self showExperienceBar];
                });
            });
        }
    }
    
    else
    {
        [self setupHeaderView];
        [self showExperienceBar];
    }
            
    [self.activityIndicator stopAnimating];
    [self.activityIndicator setHidden:YES];
    
    
    [self.navigationController.navigationBar setHidden:NO];
    
    if (self.userId)
    {
        [self.tabBarController.tabBar setHidden:YES];
        [self.navigationController.navigationBar setHidden:NO];
    }
    else
    {
        [self.tabBarController.tabBar setHidden:NO];
        [[self navigationController] setNavigationBarHidden:NO animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showTabBar" object:nil];
    }

}

- (void)hideTabBar
{
    if (self.userId)
    {
        if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
            [self.tabBarController.tabBar setHidden:YES];
        [self hideComposeButton];
    }
    else
    {
        // unhide nav bar
        [self.tabBarController.tabBar setHidden:NO];
        
        for(UIView *view in self.tabBarController.view.subviews)
            if ([view isKindOfClass:[UIButton class]] && view.tag == 100)
                [view setHidden:NO];
    }
    
}

#pragma mark - setup
- (void) updateView
{
    // Get My ripples
    self.selectedRippleArray = self.myRipples;
    if (!self.user)
    {
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Add code here to do background processing
            self.myRipples = [BellowService getMyRipples:0 withSortMethod:0];
            if ([self.myRipples count] < 25) //PARSE_PAGE_SIZE)
            {
                self.isAllMyRipples = YES;
            }
            else
            {
                self.isAllMyRipples = NO;
            }
            
            dispatch_async( dispatch_get_main_queue(), ^{
                self.isStartedCompleted = YES;
                [self checkBarrier];
                
                // sign up for listener
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addRippleToPropagated:) name:@"RipplePropagated" object:nil];
            });
        });
        
        // Get spread ripples
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Add code here to do background processing
            self.propagatedRipples = [BellowService getPropagatedRipples:0 withSortMethod:0];
            
            if ([self.propagatedRipples count] < 25)// PARSE_PAGE_SIZE)
            {
                self.isAllPropagatedRipples = YES;
            }
            else
            {
                self.isAllPropagatedRipples = NO;
            }
            
            dispatch_async( dispatch_get_main_queue(), ^{
                
            });
        });
    }
    
    else
    {
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Add code here to do background processing
            self.myRipples = [BellowService getUserRipples:0 forUser:self.userId];
            
            if ([self.myRipples count] < 25) //PARSE_PAGE_SIZE)
            {
                self.isAllMyRipples = YES;
            }
            else
            {
                self.isAllMyRipples = NO;
            }
            
            dispatch_async( dispatch_get_main_queue(), ^{
                self.isStartedCompleted = YES;
                [self checkBarrier];
            });
        });
        
        [self.followingNum.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:18.0]];
        //[self.followingLabel.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:11.0]];
        [self.followersNum.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:18.0]];
        
    }
}

- (void)checkBarrier
{
    if (self.isSpreadCompleted)
    {
        // allow to click 'spread'
    }
    
    if (self.isStartedCompleted)
    {
        self.selectedRippleArray = self.myRipples;
        [self.tableView reloadData];
    }
}

- (void) setupHeaderView
{
    // hide all elements
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    
    if (self.userId)
    {
        [self.followButton setHidden:NO];
        
        // check if user is following
        if ([PFUser currentUser][@"following"] !=nil && [[PFUser currentUser][@"following"] indexOfObject:self.userId] != NSNotFound)
        {
            [self.followButton setImage:[UIImage imageNamed:@"following.png"] forState:UIControlStateNormal];
        }
        else
        {
            [self.followButton setImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
        }
        
        
    }
    
    // initiate user refresh. Alot of data we show depends on the user.
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!self.user)
        {
            [[PFUser currentUser] fetch];
            self.currentUser = [PFUser currentUser];
        }
        
        dispatch_async( dispatch_get_main_queue(), ^{
            // post notification
            
            if(!self.user)
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateBarBtn" object:nil];
            
            [self.rippleLevel setText:[NSString stringWithFormat:@"%@", self.currentUser[@"reachLevel"]]];

            // setup navigation title
            UIView *titleView = [[UIView alloc] initWithFrame: CGRectMake(0,40,[UIScreen mainScreen].bounds.size.width - 100, 44)];
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleView.frame.size.width/2 - 110,0,220, 44)];
            
            [titleLabel setFont:[UIFont fontWithName:@"Avenir" size:22.0]];
            [titleLabel setTextColor:[UIColor whiteColor]];
            
            if([PFAnonymousUtils isLinkedWithUser:self.currentUser])
                titleLabel.text = @"Profile";
            else
                titleLabel.text= [NSString stringWithFormat:@"%@", self.currentUser.username];
            
            [titleLabel setTextAlignment:NSTextAlignmentCenter];
            [titleView addSubview:titleLabel];
            self.navigationItem.titleView = titleView;
            [self.navigationItem.titleView setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2, self.navigationController.navigationBar.frame.size.height/2)];
            
            
            // set up followers and following
            if (self.currentUser[@"followingNumber"] == nil)
                [self.followingNum setTitle:@"0" forState:UIControlStateNormal];
            else
                [self.followingNum setTitle:[NSString stringWithFormat:@"%u",[self.currentUser[@"followingNumber"] integerValue]] forState:UIControlStateNormal];
            
            [self.followingLabel setTitle:@"following" forState:UIControlStateNormal];
            
            NSArray *followers = [NSArray arrayWithArray:self.currentUser[@"following"]];
            int followerscount = [followers count];
            [self.followersNum setTitle:[NSString stringWithFormat:@"%d", followerscount] forState :UIControlStateNormal];
            
            if ([self.followingNum.titleLabel.text isEqualToString:@"1"])
                [self.followingLabel setTitle:@"follower" forState:UIControlStateNormal];
            else
                [self.followingLabel setTitle:@"followers" forState:UIControlStateNormal];
            
            
            
            // hide or show first level text
            if (!self.user &&[self.currentUser[@"reachLevel"] isEqualToString:@"Sea Serpent"])
            {
                [self.highestPropagatedLabel setHidden:YES];
                [self.firstLevelTextView setHidden:NO];
                
                [self.firstLevelTextView setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:13.0]];
                 
                // add gesture recognizer
                UITapGestureRecognizer *goToMoreTab = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressFirstLevel)];
                [goToMoreTab setNumberOfTapsRequired:1];
                [goToMoreTab setDelegate:self];
                [self.firstLevelTextView addGestureRecognizer:goToMoreTab];
                
                self.tableHeader.frame = CGRectMake(self.tableHeader.frame.origin.x, self.tableHeader.frame.origin.y, self.tableHeader.frame.size.width, 320);
                [self.tableView setTableHeaderView:self.tableHeader];

            }
            else
            {
                
                [self.firstLevelTextView setHidden:YES];
                [self.highestPropagatedLabel setHidden:YES];
                
                // find height of tableHeader
                int accessibleProfilesNumber = 0;
                if(self.userId)
                {
                    
                    for(NSString *key in self.user[@"accessibleProfiles"])
                    {
                        if(![self.user[@"accessibleProfiles"][key] isEqualToString:@""])
                            accessibleProfilesNumber +=1;
                    }
                    
                    self.containerViewHeightConstraint.constant = 36*accessibleProfilesNumber;
                    self.tableHeader.frame = CGRectMake(self.tableHeader.frame.origin.x, self.tableHeader.frame.origin.y, self.tableHeader.frame.size.width, 170+self.containerViewHeightConstraint.constant);
                }
                
                else
                {
                    self.tableHeader.frame = CGRectMake(self.tableHeader.frame.origin.x, self.tableHeader.frame.origin.y, self.tableHeader.frame.size.width, 276);
                }
                
                
                [self.tableView setTableHeaderView:self.tableHeader];
            }
            
            // points
            BellowLevel *nextLevel = [self findLevel:1];
            
            
            // setup following Label
            //TODO
            
            
            self.pointsLabel.text = [NSString stringWithFormat:@"%d reach  |  %d points", [self.currentUser[@"reach"] intValue], [self.currentUser[@"score"] intValue]];
            
            // user or nah?
            if ([PFAnonymousUtils isLinkedWithUser:self.currentUser])
            {
                [self.loginSignupProfileButton setHidden:NO];
                [self.pointsLabel setHidden:YES];

            }
            else
            {
                // put level number
                [self.loginSignupProfileButton setHidden:YES];
                [self.pointsLabel setHidden:NO];
            }
            
            
    
            int nextLevelScore;
            
            if (!self.user)
                nextLevelScore = nextLevel.minScore - [[PFUser currentUser][@"score"] intValue];
            else
                nextLevelScore = nextLevel.minScore - [[self.user objectForKey:@"score"] intValue];

            if (nextLevelScore == 1)
                [self.pointsToNextLevel setTitle:[NSString stringWithFormat:@"%d point to become %@", nextLevelScore, nextLevel.name] forState:UIControlStateNormal];
            else
                [self.pointsToNextLevel setTitle:[NSString stringWithFormat:@"%d points to become %@", nextLevelScore, nextLevel.name] forState:UIControlStateNormal];
            
            // Allow the text in the button to be resized
            self.pointsToNextLevel.titleLabel.adjustsFontSizeToFitWidth = YES;
            self.pointsToNextLevel.titleLabel.minimumScaleFactor = 0.7;
            
            [self.view setNeedsUpdateConstraints];
            [self.view layoutIfNeeded];
            
            // unhide elements
            [self.activityIndicator stopAnimating];
            [self.activityIndicator setHidden:YES];
            [self.followingLabel setHidden:NO];
            [self.followingNum setHidden:NO];
            [self.followersLabel setHidden:NO];
            [self.followersNum setHidden:NO];
            [self.pointsToNextLevel setHidden:NO];
            [self.progressBackground setHidden:NO];
            [self.rippleLevel setHidden:NO];
        });
    });
}

- (void)showExperienceBar
{
    self.progressBackground.hidden = NO;
    // set ripple reach level text width, progress bar width, and update constraints

    
    // calculate progress bar width
    double score = [self.currentUser[@"score"] doubleValue];
    BellowLevel *nextLevel = [self findLevel:1];
    BellowLevel *currentLevel = [self findLevel:0];
    double minScore = currentLevel.minScore;
    double maxScore = nextLevel.minScore;
    
    
    double ratio = (score - minScore) / (maxScore - minScore);
    CGFloat xCoordinate = (self.progressBackground.frame.size.width) * ratio;
    if (ratio == 0)
        xCoordinate = self.progressBackground.frame.size.width * 0.01;
    
    [self.progressBackground setHidden:NO];
    
    // animate
    [UIView animateWithDuration:1 animations:^{
        self.progressBarWidthConstraint.constant = xCoordinate;
        
        self.progressBar.frame = CGRectMake(self.progressBar.frame.origin.x, self.progressBar.frame.origin.y, xCoordinate, self.progressBar.frame.size.height);
    }];
    
}

- (BellowLevel *)findLevel: (int)whichLevel
{
    
    double score;
    
    if (!self.user)
        score = [self.currentUser[@"score"] doubleValue];
    else
        score = [self.user[@"score"] doubleValue];
    
    BellowLevel *returnLevel;
    
    for (int i = 0; i < [self.userLevels count]; i++)
    {
        BellowLevel *level = self.userLevels[i];
        if (level.minScore > score)
        {
            if (whichLevel == 1)
                level = self.userLevels[i];
            else
                level = self.userLevels[i - 1];
            
            returnLevel = level;
            break;
        }
    }
    
    return returnLevel;
}

- (IBAction)didPressNextLevelButton:(id)sender {
    
    if ([PFAnonymousUtils isLinkedWithUser:self.currentUser])
        [self showLogInAndSignUpView];
    else
        [self performSegueWithIdentifier:@"SegueToPointsFromProfile" sender:nil];
}


- (void)didPressFirstLevel
{
    [self performSegueWithIdentifier:@"SegueToPointsFromProfile" sender:nil];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.selectedRippleArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.userId)
        return [self setSwipeableCell:tableView withIndexPath:indexPath];
    else
        return [self setMyRippleCell:tableView withIndexPath:indexPath];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!self.userId)
        return 75;
        
    else
        return 30;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // 1. Dequeue the custom header cell
    HeaderTableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    headerCell.selectionStyle = UITableViewCellSelectionStyleNone;
    [headerCell setUserInteractionEnabled:YES];
    headerCell.delegate = self;

    if (!self.userId)
    {
        [headerCell.filterView setHidden:NO];
        [headerCell.UserRecentLabel setHidden:YES];
        if (self.newRippleCreated)
        {
            headerCell.filterMethod = 1; //MAKE IT OPPOSITE
            headerCell.sortMethod = 0;
            
            self.newRippleCreated = NO;
        }
        
        [headerCell changeColorOfFilterMethods:self.filterMethod];
        [headerCell changeColorOfSortOptions:self.sortMethod];
        
    }
    
    else
    {
        [headerCell.filterView setHidden:YES];
        
        if (self.currentUser == self.user) {
            [headerCell.UserRecentLabel setText: [NSString stringWithFormat:@"%@'s ripples", self.user.username]];
            [headerCell.UserRecentLabel setHidden:NO];
        }
    }
    
    
    [headerCell setHidden:NO];
    
    return headerCell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.user)
        return [NSString stringWithFormat:@"%@'s ripples", self.user.username];
    else
        return nil;
}

- (SwipeableCell *)setSwipeableCell:(UITableView *)tableView withIndexPath:(NSIndexPath *) indexPath
{
    [tableView registerNib:[UINib nibWithNibName:@"SwipeableCell" bundle:nil] forCellReuseIdentifier:@"SwipeableCell"];
    
    SwipeableCell *cell = (SwipeableCell *)[tableView dequeueReusableCellWithIdentifier:@"SwipeableCell" forIndexPath:indexPath];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    Ripple *ripple = [self.selectedRippleArray objectAtIndex:[indexPath row]];
    
    // nil stuff
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.ripple = nil;
    cell.ripple = ripple;
    cell.delegate = self;
    cell.rippleTextView.delegate = self;
    cell.rippleTextView.text = [NSString stringWithString:ripple.text];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    // username preparation
    UIFont *myFont = [UIFont fontWithName:@"AvenirNext-Regular" size:18.0];
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:myFont, NSFontAttributeName,nil];
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize stringSize = [cell.ripple.creatorName sizeWithAttributes:attributesDictionary];
    cell.userLabelWidthConstraint.constant = stringSize.width + 3;
    [cell.userLabel setTitle:cell.ripple.creatorName forState:UIControlStateNormal];
    
    
    // set time and city
    NSTimeInterval timeInterval = [cell.ripple.createdAt timeIntervalSinceNow];
    
    if (cell.ripple.city)
    {
        // set city label hidden
        [cell.cityLabel setHidden:NO];
        cell.cityLabel.text = cell.ripple.city;
     
        cell.timeLabel.text = [NSString stringWithFormat:@"%@", [self.timeIntervalFormatter stringForTimeInterval:timeInterval]];
        [cell.timeLabel setHidden:NO];
    }
    else
    {
        // switch purpose
        cell.cityLabel.text = [NSString stringWithFormat:@"%@", [self.timeIntervalFormatter stringForTimeInterval:timeInterval]];
        
        [cell.timeLabel setHidden:YES];
    }
    
    // spread count
    NSDictionary *boldAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"AvenirNext-Bold" size:13], NSFontAttributeName, nil];
    NSAttributedString *rippledText;
    
    if (cell.ripple.numberPropagated == -1)
        rippledText = [[NSAttributedString alloc] initWithString:@"0x"];
    else
        rippledText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%dx", cell.ripple.numberPropagated] attributes:boldAttributes];
    [cell.numPropagatedLabel setAttributedText:rippledText];
    
    
    [cell.numberOfCommentsButton setTitle:[NSString stringWithFormat:@"%d", ripple.numberComments] forState:UIControlStateNormal];
    
    // set colors of dismiss and propagate views
    cell.propagateView.backgroundColor = [UIColor colorWithRed:3.0/255.0f green:123.0f/255 blue:255.0f/255 alpha:1.0];
    cell.dismissView.backgroundColor = [UIColor colorWithRed:255/255.0f green:92.0f/255 blue:122.0f/255 alpha:1.0];
    cell.propagateImageView.alpha = 0.2;
    cell.dismissImageView.alpha = 0.2;
    
    // spread comment view
    [cell.spreadCommentView setBackgroundColor:[UIColor colorWithRed:238.0/255.0f green:238.0f/255 blue:255.0f/255 alpha:1.0]];
    [cell.numPropagatedLabel setTextColor:[UIColor colorWithRed:3.0/255.0f green:123.0f/255 blue:255.0f/255 alpha:1.0]];
    [cell.numberOfCommentsButton setTitleColor:[UIColor colorWithRed:3.0/255.0f green:123.0f/255 blue:255.0f/255 alpha:1.0] forState:UIControlStateNormal];
    [cell.commentsButton setImage:[UIImage imageNamed:@"commentsBlue.png"] forState:UIControlStateNormal];

    
    // set text top constraint if  have image
    if (cell.ripple.imageFile)
    {
        // image work!
        [cell.outerImageView setHidden:NO];
        [cell.rippleImageView setHidden:NO];
        cell.rippleImageView.image = [UIImage imageNamed:@"grayBox.png"];
        [cell.outerImageView setBackgroundColor:[UIColor colorWithWhite:232/255.0 alpha:1.0]];
        
        cell.rippleImageView.file = (PFFile *)cell.ripple.imageFile;
        
        // determine set to 100% width, ratio for height. (if smaller than...350px)
        CGFloat heightRatio = (float) cell.ripple.imageHeight / cell.ripple.imageWidth;
        
        CGFloat cellImageHeight;
        if (cell.rippleImageViewWidthConstraint.constant*heightRatio <=350)
        {
            cell.outerImageViewHeightConstraint.constant = ([UIScreen mainScreen].bounds.size.width - 28) * heightRatio;
            cellImageHeight = cell.outerImageViewHeightConstraint.constant;
        }
        
        else
        {
            cell.outerImageViewHeightConstraint.constant = 350;
            cellImageHeight = 350;
        }
        
        [cell.rippleImageView loadInBackground];
        
        cell.topTextViewConstraint.constant = cellImageHeight + cell.spreadCommentView.frame.size.height + cell.outerImageView.frame.origin.y + 5;
        
        // place spreadCommentView on image
        cell.spreadCommentViewTopConstraint.constant = cellImageHeight + cell.outerImageView.frame.origin.y;;
        
        // find textview height// find textview height
        [cell.rippleTextView setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0]];
        CGSize maximumSize = CGSizeMake(self.tableView.frame.size.width- 12.0, 9999);
        CGRect textSize =  [cell.ripple.text boundingRectWithSize:maximumSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:context];
        cell.textViewHeightConstraint.constant = textSize.size.height + 30;
        
        // borders
        [cell.rippleTextView.layer setBorderWidth:0.0];
        [cell.outerImageView.layer setBorderColor:[[UIColor colorWithRed:220.0/255.0f green:220.0f/255 blue:220.0f/255 alpha:1.0] CGColor]];
        [cell.outerImageView.layer setBorderWidth:1.0];
        
        cell.rightSpreadCommentViewConstraint.constant = 0;
        cell.leftSpreadCommentViewConStraint.constant = 0;
        cell.textViewWidthConstraint.constant = [UIScreen mainScreen].bounds.size.width - 8;
    }
    
    // we don't have an image
    else
    {
        cell.rippleImageView.hidden = YES;
        cell.rippleImageView.image = nil;
        [cell.outerImageView setHidden:YES];
        cell.topTextViewConstraint.constant = cell.outerImageView.frame.origin.y;
        
        // find textview height
        [cell.rippleTextView setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:20.0]];
        CGSize maximumSize = CGSizeMake(self.tableView.frame.size.width- 12.0, 9999);
        UIFont *myFont = [UIFont fontWithName:@"AvenirNext-Regular" size:21.0];
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:myFont, NSFontAttributeName,nil];
        NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
        
        CGRect textSize =  [cell.ripple.text boundingRectWithSize:maximumSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:context];
        
        cell.textViewHeightConstraint.constant = textSize.size.height + 53;
        // place spreadCommentView there
        cell.spreadCommentViewTopConstraint.constant = textSize.size.height + cell.outerImageView.frame.origin.y + 20;
        
        // add small border to this
        [cell.rippleTextView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
        [cell.rippleTextView.layer setBorderWidth:1.0];
        cell.rippleTextView.layer.cornerRadius = 5.0;
        
        cell.rightSpreadCommentViewConstraint.constant = 6;
        cell.leftSpreadCommentViewConStraint.constant = 6;
        cell.textViewWidthConstraint.constant = [UIScreen mainScreen].bounds.size.width - 12;
    }
    
    // update constraints
    [cell setNeedsUpdateConstraints];
    [cell layoutIfNeeded];
    
    // give it arrow accessory
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // determine if acted upon or not
    [cell.spreadButton setAlpha:1.0];
    [cell.dismissButton setAlpha:1.0];
    [cell.propagateImageView setHidden:NO];
    [cell.dismissImageView setHidden:NO];
    
    [cell.alreadyActedLabel setHidden:YES];
    if (cell.ripple.actedUponState == 1)
    {
        // not acted upon
        [cell.dismissButton setHidden:YES];
        [cell.spreadButton setHidden:YES];
        
        [cell.alreadyActedButton setImage:[UIImage imageNamed:@"alreadySpread.png"] forState:UIControlStateNormal];
        [cell.alreadyActedButton setHidden:NO];

        
    }
    
    else if(cell.ripple.actedUponState == 2)
    {
        // not acted upon
        [cell.dismissButton setHidden:YES];
        [cell.spreadButton setHidden:YES];
        
        [cell.alreadyActedButton setImage:[UIImage imageNamed:@"alreadyDismissed.png"] forState:UIControlStateNormal];
        [cell.alreadyActedButton setHidden:NO];

    }
    
    else
    {
        // not acted upon
        [cell.dismissButton setHidden:NO];
        [cell.spreadButton setHidden:NO];
        [cell.alreadyActedButton setHidden:YES];
        [cell.spreadButton setUserInteractionEnabled:YES];
        [cell.dismissButton setUserInteractionEnabled:YES];
        cell.dismissButtonRightConstaint.constant = -5;
        cell.spreadButtonLeftConstraint.constant =-5;
        
        [cell.spreadButton setImage:[UIImage imageNamed:@"propagateButtonUnselected"] forState:UIControlStateNormal];
        [cell.dismissButton setImage:[UIImage imageNamed:@"dismissRippleIconUnselected"] forState:UIControlStateNormal];
        
    }
    
    return cell;
}

- (MyRippleCell *)setMyRippleCell:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath
{
    [tableView registerNib:[UINib nibWithNibName:@"MyRippleCell" bundle:nil] forCellReuseIdentifier:@"MyRippleCell"];
    MyRippleCell *cell = (MyRippleCell *)[tableView dequeueReusableCellWithIdentifier:@"MyRippleCell" forIndexPath:indexPath];
    cell.rippleMainView.layer.cornerRadius = 5.0;
    
    Ripple *ripple = [self.selectedRippleArray objectAtIndex:[indexPath row]];
    
    // nil stuff
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.ripple = nil;
    cell.ripple = ripple;
    cell.delegate = self;
    cell.rippleTextView.delegate = self;
    cell.rippleTextView.text = [NSString stringWithString:ripple.text];
    cell.ripple.actedUponState = -1;
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    // user label work
    UIFont *myFont = [UIFont fontWithName:@"AvenirNext-Regular" size:18.0];
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:myFont, NSFontAttributeName,nil];
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    
    [cell.usernameLabel setTitle:cell.ripple.creatorName forState:UIControlStateNormal];
    CGSize stringSize = [cell.ripple.creatorName sizeWithAttributes:attributesDictionary];
    cell.usernameLabelWidthConstraint.constant = stringSize.width + 3;
    
    
    // set username and city
    NSTimeInterval timeInterval = [cell.ripple.createdAt timeIntervalSinceNow];
    if (cell.ripple.city)
    {
        // set city label hidden
        [cell.cityLabel setHidden:NO];
        cell.cityLabel.text = cell.ripple.city;
        [cell.timestamp setHidden:NO];
        cell.timestamp.text = [NSString stringWithFormat:@"%@", [self.timeIntervalFormatter stringForTimeInterval:timeInterval]];
        
        // size citylabel
        UIFont *labelFont = [UIFont fontWithName:@"AvenirNext-Regular" size:12.0];
        NSDictionary *labelDictionary = [NSDictionary dictionaryWithObjectsAndKeys:labelFont, NSFontAttributeName,nil];
        CGSize citySize = [cell.ripple.city sizeWithAttributes:labelDictionary];
        cell.cityLabelWidthConstraint.constant = citySize.width;
    }
    else
    {
        [cell.timestamp setHidden:YES];
        cell.cityLabel.text = [NSString stringWithFormat:@"%@", [self.timeIntervalFormatter stringForTimeInterval:timeInterval]];
        cell.cityLabelWidthConstraint.constant = 200;
    }
    
    // spread count
    NSDictionary *boldAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"AvenirNext-Bold" size:13], NSFontAttributeName, nil];
    NSAttributedString *rippledText;
    
    if (cell.ripple.numberPropagated != -1)
        rippledText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%dx", cell.ripple.numberPropagated] attributes:boldAttributes];
    else
        rippledText = [[NSAttributedString alloc] initWithString:@"0x" attributes:boldAttributes];
       [cell.numberPropagatedLabel setAttributedText:rippledText];
    
    [cell.numberOfCommentsButton setTitle:[NSString stringWithFormat:@"%d", ripple.numberComments] forState:UIControlStateNormal];
    
    
    // change color of spreadCommentView items
    [cell.spreadCommentView setBackgroundColor:[UIColor colorWithRed:238.0/255.0f green:238.0f/255 blue:238.0f/255 alpha:1.0]];
    [cell.numberPropagatedLabel setTextColor:[UIColor colorWithRed:3.0/255.0f green:123.0f/255 blue:255.0f/255 alpha:1.0]];
    [cell.numberOfCommentsButton setTitleColor:[UIColor colorWithRed:3.0/255.0f green:123.0f/255 blue:255.0f/255 alpha:1.0] forState:UIControlStateNormal];
    [cell.commentsButton setImage:[UIImage imageNamed:@"commentsBlue.png"] forState:UIControlStateNormal];
    
    // set text top constraint if  have image
    if (cell.ripple.imageFile)
    {
        // image work!
        [cell.outerImageView setHidden:NO];
        [cell.outerImageViewWidthConstraint setConstant:[UIScreen mainScreen].bounds.size.width - 12];
        [cell.rippleImageView setHidden:NO];
        cell.rippleImageView.image = [UIImage imageNamed:@"grayBox.png"];
        [cell.outerImageView setBackgroundColor:[UIColor colorWithWhite:232/255.0 alpha:1.0]];
        
        
        cell.rippleImageView.file = (PFFile *)cell.ripple.imageFile;
        
        // determine set to 100% width, ratio for height. (if smaller than...350px)
        CGFloat heightRatio = (float) cell.ripple.imageHeight / cell.ripple.imageWidth;
        cell.rippleImageViewWidthConstraint.constant = [UIScreen mainScreen].bounds.size.width - 6;
    
        CGFloat cellImageHeight;
        if (cell.outerImageViewWidthConstraint.constant*heightRatio <= 350)
        {
            cell.outerImageViewHeightConstraint.constant = cell.outerImageViewWidthConstraint.constant*heightRatio;
            cellImageHeight = cell.outerImageViewHeightConstraint.constant;
        }
        
        else
        {
            cell.outerImageViewHeightConstraint.constant = 350;
            cellImageHeight = 350;
        }
        
        // load image + set position from top for image
        cell.rippleImageViewHeightConstraint.constant = cell.outerImageView.frame.size.width*heightRatio;
        [cell.rippleImageView loadInBackground];

        cell.topTextViewConstraint.constant = cellImageHeight + cell.spreadCommentView.frame.size.height + cell.outerImageView.frame.origin.y;
        
        // place spreadCommentView on image
        cell.spreadCommentViewTopConstraint.constant = cellImageHeight + cell.outerImageView.frame.origin.y;
        
        // find textview height// find textview height
        [cell.rippleTextView setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0]];
        CGSize maximumSize = CGSizeMake(self.tableView.frame.size.width- 12.0, 9999);
        CGRect textSize =  [cell.ripple.text boundingRectWithSize:maximumSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:context];
        cell.textViewHeightConstraint.constant = textSize.size.height + 30;
        
        // borders borders
        [cell.rippleTextView.layer setBorderWidth:0.0];
        [cell.outerImageView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
        [cell.outerImageView.layer setBorderWidth:1.0];
        // cell.outerImageView.layer.cornerRadius = 5.0;
        
        cell.rightSpreadCommentViewConstraint.constant = 6;
        cell.leftSpreadCommentViewConStraint.constant = 6;

    }
    
    // we don't have an image
    else
    {
        cell.rippleImageView.hidden = YES;
        cell.outerImageView.hidden = YES;
        cell.rippleImageView.image = nil;
        cell.topTextViewConstraint.constant = cell.outerImageView.frame.origin.y;
        
        // find textview height
        [cell.rippleTextView setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:20.0]];
        CGSize maximumSize = CGSizeMake(self.tableView.frame.size.width- 20.0, 9999);
        UIFont *myFont = [UIFont fontWithName:@"AvenirNext-Regular" size:20.0];
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:myFont, NSFontAttributeName,nil];
        NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
        
        CGRect textSize =  [cell.ripple.text boundingRectWithSize:maximumSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:context];
        
        cell.textViewHeightConstraint.constant = textSize.size.height + 45;
        // place spreadCommentView there
        cell.spreadCommentViewTopConstraint.constant = textSize.size.height + cell.outerImageView.frame.origin.y + 35;
        
        // add small border to this 
        [cell.rippleTextView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
        [cell.rippleTextView.layer setBorderWidth:1.0];
        cell.rippleTextView.layer.cornerRadius = 5.0;
        
        cell.rightSpreadCommentViewConstraint.constant = 10;
        cell.leftSpreadCommentViewConStraint.constant = 10;
    }

    // update constraints
    [cell setNeedsUpdateConstraints];
    [cell layoutIfNeeded];
    
    // give it arrow accessory
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // add shadow
    cell.rippleMainView.layer.shadowOffset = CGSizeMake(0,0);
    cell.rippleMainView.layer.shadowRadius = 2;
    cell.rippleMainView.layer.shadowOpacity = 0.1;
    cell.rippleMainView.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.rippleMainView.bounds].CGPath;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.userId)
    {
        // set current ripple
        Ripple *currentRipple = [self.selectedRippleArray objectAtIndex:indexPath.row];
        
        // size text and images
        CGFloat imageHeight = 0;
        NSDictionary *attributesDictionary = [[NSDictionary alloc]init];
        NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
        CGSize maximumSize = CGSizeMake(self.view.frame.size.width - 20, 9999);
        
        if (currentRipple.imageFile)
        {
            // find height ratio
            CGFloat heightRatio = (float) currentRipple.imageHeight / currentRipple.imageWidth;
            CGFloat height = ([UIScreen mainScreen].bounds.size.width - 28) * heightRatio;
            
            if (height > 350)
                imageHeight = 350;
            else
                imageHeight = height + 10;
            
            imageHeight += 60;
            
            UIFont *myFont = [UIFont fontWithName:@"AvenirNext-Regular" size:16.0];
            attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:myFont, NSFontAttributeName,nil];
        }
        else
        {
            imageHeight = 90; // account for the spreadCommentView
            
            UIFont *myFont = [UIFont fontWithName:@"AvenirNext-Regular" size:20.0];
            attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:myFont, NSFontAttributeName,nil];
        }
        
        CGRect stringsize =  [currentRipple.text boundingRectWithSize:maximumSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:context];
        
        CGFloat swipeableCellHeight = 0;
        if (self.userId)
            swipeableCellHeight = 60;
        
        return stringsize.size.height + imageHeight + swipeableCellHeight + 75;
    }
    
    else
    {
        // set current ripple
        Ripple *currentRipple = [self.selectedRippleArray objectAtIndex:indexPath.row];
        
        // size text and images
        CGFloat imageHeight = 0;
        NSDictionary *attributesDictionary = [[NSDictionary alloc]init];
        NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
        CGSize maximumSize = CGSizeMake(self.view.frame.size.width - 20, 9999);
        if (currentRipple.imageFile)
        {
            // find height ratio
            CGFloat heightRatio = (float) currentRipple.imageHeight / currentRipple.imageWidth;
            CGFloat height = ([UIScreen mainScreen].bounds.size.width - 28) * heightRatio;
            
            if (height > 350)
                imageHeight = 350;
            else
                imageHeight = height;
            
            // include height of spreadViewComment
            imageHeight += 25;
            
            UIFont *myFont = [UIFont fontWithName:@"AvenirNext-Regular" size:16.0];
            attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:myFont, NSFontAttributeName,nil];
        }
        else
        {
            imageHeight = 25;
            UIFont *myFont = [UIFont fontWithName:@"AvenirNext-Regular" size:21.0];
            attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:myFont, NSFontAttributeName,nil];
        }
        
        CGRect stringsize =  [currentRipple.text boundingRectWithSize:maximumSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:context];
        
        CGFloat dismissSpreadView = 60;
        
        return stringsize.size.height + imageHeight + 75 + dismissSpreadView;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[SwipeableCell class]])
    {
        SwipeableCell *swipeableCell = (SwipeableCell *)cell;
        // set up height of dismiss and propagate views
        swipeableCell.dismissViewHeightConstraint.constant = swipeableCell.rippleMainView.frame.size.height;
        swipeableCell.propagateViewHeightConstraint.constant = swipeableCell.rippleMainView.frame.size.height;
        [swipeableCell setNeedsUpdateConstraints];
        [swipeableCell layoutIfNeeded];
        
        
        if (swipeableCell.ripple.imageFile)
        {
            // set text top constraint if  have image
            CGFloat heightRatio = (float) swipeableCell.ripple.imageHeight / swipeableCell.ripple.imageWidth;
            CGFloat height = swipeableCell.outerImageView.frame.size.width * heightRatio;
            swipeableCell.rippleImageViewWidthConstraint.constant = swipeableCell.outerImageView.frame.size.width;
            
            swipeableCell.rippleImageViewHeightConstraint.constant = height;
        }
        
        [cell layoutIfNeeded];
        [cell updateConstraintsIfNeeded];
        
        // work to add circles to propagate view
        swipeableCell.rippleCircles = [[NSMutableArray alloc] init];
        for (int i = 0; i < 3; i ++)
        {
            UIView *outerCircle = [[UIView alloc] initWithFrame:CGRectMake(swipeableCell.propagateView.frame.size.width - 30.0 - swipeableCell.propagateImageView.frame.size.width/2 - 1.1, swipeableCell.rippleMainView.frame.size.height/2.0 - 1.1, 2.2, 2.2)];
            outerCircle.alpha = 0.3;
            outerCircle.layer.cornerRadius = 1.1;
            
            UIView *innerCircle = [[UIView alloc] initWithFrame:CGRectMake(swipeableCell.propagateView.frame.size.width - 30.0 - swipeableCell.propagateImageView.frame.size.width/2 - 1, swipeableCell.rippleMainView.frame.size.height/2.0 - 1, 2, 2)];
            innerCircle.alpha = 0.3;
            innerCircle.layer.cornerRadius = 1;
            
            [swipeableCell.propagateView addSubview:outerCircle];
            [swipeableCell.propagateView addSubview:innerCircle];
            
            [swipeableCell.rippleCircles addObject:outerCircle];
            [swipeableCell.rippleCircles addObject:innerCircle];
            
            
            // add shadow and unhide propagateimage
            swipeableCell.rippleMainView.layer.shadowOffset = CGSizeMake(0,0);
            swipeableCell.rippleMainView.layer.shadowRadius = 2;
            swipeableCell.rippleMainView.layer.shadowOpacity = 0.5;
            swipeableCell.rippleMainView.layer.shadowPath = [UIBezierPath bezierPathWithRect:swipeableCell.rippleMainView.bounds].CGPath;
            swipeableCell.propagateView.layer.shadowOffset = CGSizeMake(0,0);
            swipeableCell.propagateView.layer.shadowRadius = 2;
            swipeableCell.propagateView.layer.shadowOpacity = 0.3;
            swipeableCell.propagateView.layer.shadowPath = [UIBezierPath bezierPathWithRect:swipeableCell.propagateView.bounds].CGPath;
            swipeableCell.dismissView.layer.shadowOffset = CGSizeMake(0,0);
            swipeableCell.dismissView.layer.shadowRadius = 2;
            swipeableCell.dismissView.layer.shadowOpacity = 0.3;
            swipeableCell.dismissView.layer.shadowPath = [UIBezierPath bezierPathWithRect:swipeableCell.dismissView.bounds].CGPath;
        }
    }
    
    if ([cell isKindOfClass:[MyRippleCell class]] || [cell isKindOfClass:[SwipeableCell class]])
    {
        if ([indexPath row] == [self.selectedRippleArray count] - 2)
        {
            if ((self.filterMethod == 0) && (self.sortMethod == 0) && !self.isAllMyRipples)
            {
                
                // call method to create ripples with block to reload
                [self.indicatorFooter startAnimating];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSArray *newMyRipples;
                    if (!self.userId)
                        newMyRipples = [BellowService getMyRipples:(int)[self.selectedRippleArray count]  withSortMethod:self.sortMethod];
                    else
                        newMyRipples = [BellowService getUserRipples:(int)[self.selectedRippleArray count] forUser:self.userId];
                    
                    if (newMyRipples.count < 25) // PARSE_PAGE_SIZE)
                        self.isAllMyRipples = YES;
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.myRipples addObjectsFromArray:newMyRipples];
                        [self.tableView reloadData];
                        [self.indicatorFooter stopAnimating];
                    });
                });
            }
            else if ((self.filterMethod == 0) && (self.sortMethod == 1) && !self.isAllMyRipplesMostPopular)
            {
                
                // call method to create ripples with block to reload
                [self.indicatorFooter startAnimating];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    NSArray *newMyRipplesMostPopular = [BellowService getMyRipples:(int)[self.selectedRippleArray count]  withSortMethod:self.sortMethod];
                    
                    if (newMyRipplesMostPopular.count < 25) //PARSE_PAGE_SIZE)
                        self.isAllMyRipples = YES;
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.myRipplesMostPopular addObjectsFromArray:newMyRipplesMostPopular];
                        [self.tableView reloadData];
                        [self.indicatorFooter stopAnimating];
                    });
                });
            }
            else if ((self.filterMethod == 1) && (self.sortMethod == 0) && !self.isAllPropagatedRipples)
            {
                
                // call method to create ripples with block to reload
                [self.indicatorFooter startAnimating];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    NSArray *newPropagatedRipples = [BellowService getPropagatedRipples:(int)[self.selectedRippleArray count]  withSortMethod:self.sortMethod];
                    
                    if (newPropagatedRipples.count < 25) //PARSE_PAGE_SIZE)
                        self.isAllPropagatedRipples = YES;
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.propagatedRipples addObjectsFromArray:newPropagatedRipples];
                        [self.tableView reloadData];
                        [self.indicatorFooter stopAnimating];
                    });
                });
            }
            else if ((self.filterMethod == 1) && (self.sortMethod == 1) && !self.isAllPropagatedRipplesMostPopular)
            {
                
                // call method to create ripples with block to reload
                [self.indicatorFooter startAnimating];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    NSArray *newPropagatedRipplesMostPopular = [BellowService getPropagatedRipples:(int)[self.selectedRippleArray count]  withSortMethod:self.sortMethod];
                    
                    if (newPropagatedRipplesMostPopular.count < 25) //PARSE_PAGE_SIZE)
                        self.isAllPropagatedRipplesMostPopular = YES;
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.propagatedRipplesMostPopular addObjectsFromArray:newPropagatedRipplesMostPopular];
                        [self.tableView reloadData];
                        [self.indicatorFooter startAnimating];
                    });
                });
            }
        }
    }
}


- (void)refreshList
{
    if (!self.userId)
    {
        [self.noRipplesTextView setHidden:YES];
        [self.tableView setAlpha:1.0];
        [self setupHeaderView];
        [self showExperienceBar];
        
        // my ripples
        if (self.filterMethod == 0)
        {
            // most recent
            if (self.sortMethod == 0)
            {
                dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    // Add code here to do background processing
                    self.myRipples = [BellowService getMyRipples:0 withSortMethod:0];
                    self.selectedRippleArray = self.myRipples;
                    
                    if ([self.selectedRippleArray count] <25) // PARSE_PAGE_SIZE)
                    {
                        self.isAllMyRipples = YES;
                    }
                    else
                    {
                        self.isAllMyRipples = NO;
                    }
                    
                    dispatch_async( dispatch_get_main_queue(), ^{
                        if ([self.selectedRippleArray count] > 0)
                            [self.noRipplesTextView setHidden:YES];
                        else
                        {
                            [self displayNoRipplesViewForSort];
                        }
                        
                        [self.tableView reloadData];
                    });
                });
            }
            
            // most popular
            else
            {
                dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    // Add code here to do background processing
                    self.myRipplesMostPopular = [BellowService getMyRipples:0 withSortMethod:1];
                    self.selectedRippleArray = self.myRipplesMostPopular;
                    
                    if ([self.myRipplesMostPopular count] < 25) // PARSE_PAGE_SIZE)
                    {
                        self.isAllMyRipplesMostPopular = YES;
                    }
                    else
                    {
                        self.isAllMyRipplesMostPopular = NO;
                    }
                    
                    dispatch_async( dispatch_get_main_queue(), ^{
                        
                        if ([self.selectedRippleArray count] > 0)
                            [self.noRipplesTextView setHidden:YES];
                        else
                        {
                            [self displayNoRipplesViewForSort];
                        }
                        
                        [self.tableView reloadData];
                    });
                });
            }
        }
        
        // spread ripples
        else
        {
            // most recent
            if (self.sortMethod == 0)
            {
                // Get spread ripples
                dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    // Add code here to do background processing
                    self.propagatedRipples = [BellowService getPropagatedRipples:0 withSortMethod:0];
                    self.selectedRippleArray = self.propagatedRipples;
                    
                    if ([self.propagatedRipples count] < 25) // PARSE_PAGE_SIZE)
                    {
                        self.isAllPropagatedRipples = YES;
                    }
                    else
                    {
                        self.isAllPropagatedRipples = NO;
                    }
                    
                    dispatch_async( dispatch_get_main_queue(), ^{
                        
                        if ([self.selectedRippleArray count] > 0)
                            [self.noRipplesTextView setHidden:YES];
                        else
                        {
                            [self displayNoRipplesViewForSort];
                        }
                        
                        [self.tableView reloadData];
                    });
                });
            }
            
            // most popular
            else
            {
                // Get spread ripples
                dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    // Add code here to do background processing
                    self.propagatedRipplesMostPopular = [BellowService getPropagatedRipples:0 withSortMethod:1];
                    self.selectedRippleArray = self.propagatedRipplesMostPopular;
                    
                    if ([self.propagatedRipplesMostPopular count] < 25) // PARSE_PAGE_SIZE)
                    {
                        self.isAllPropagatedRipplesMostPopular = YES;
                    }
                    else
                    {
                        self.isAllPropagatedRipplesMostPopular = NO;
                    }
                    
                    dispatch_async( dispatch_get_main_queue(), ^{
                        if ([self.selectedRippleArray count] > 0)
                            [self.noRipplesTextView setHidden:YES];
                        else
                        {
                            [self displayNoRipplesViewForSort];
                        }
                        
                        [self.tableView reloadData];
                    });
                });
            }
        }
    }
    
    else
    {
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Add code here to do background processing
            self.myRipples = [BellowService getUserRipples:0 forUser:self.userId];
            
            if ([self.myRipples count] < 25) //PARSE_PAGE_SIZE)
            {
                self.isAllMyRipples = YES;
            }
            else
            {
                self.isAllMyRipples = NO;
            }
            
            dispatch_async( dispatch_get_main_queue(), ^{
                self.isStartedCompleted = YES;
                [self checkBarrier];
            });
        });
    }
    
    // call service and update table
    [self.refreshControl endRefreshing];
}


- (void) displayNoRipplesViewForSort
{
    if (self.filterMethod == 0)
        self.noRipplesTextView.text = @"You haven't started a ripple. Tap the pencil to create one!";
    else
        self.noRipplesTextView.text = @"You haven't spread a ripple yet. Swipe a ripple on the feed to spread it!";
    
    self.noTextTopConstraint.constant = 80;
    [self.noRipplesTextView setHidden:NO];
    
}


#pragma mark - filter/sort options
- (void)dismissTableUnderlay
{
    //self.isChoosingSort = NO;
}

- (void) showTableUnderlay
{
    //self.isChoosingSort = YES;
}


- (void) passSortMethod:(int)sortMethod passFilterMethod: (int)filterMethod
{
    [self.activityIndicator setHidden:YES];
    [self.activityIndicator startAnimating];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        if (filterMethod == 0)
        {
            if (sortMethod == 0)
            {
                self.selectedRippleArray = self.myRipples;
            }
            else if (self.myRipplesMostPopular == nil)
            {
                self.myRipplesMostPopular = [BellowService getMyRipples:0 withSortMethod:sortMethod];
                self.selectedRippleArray = self.myRipplesMostPopular;
                
                
                if ([self.myRipplesMostPopular count] < 25)//PARSE_PAGE_SIZE)
                {
                    self.isAllMyRipplesMostPopular = YES;
                }
            }
            else
            {
                self.selectedRippleArray = self.myRipplesMostPopular;
            }
        }
        else
        {
            if (sortMethod == 0)
            {
                self.selectedRippleArray = self.propagatedRipples;
            }
            else if (self.propagatedRipplesMostPopular == nil)
            {
                self.propagatedRipplesMostPopular = [BellowService getPropagatedRipples:0 withSortMethod:sortMethod];
                self.selectedRippleArray = self.propagatedRipplesMostPopular;
                
                
                if ([self.propagatedRipplesMostPopular count] < 25)//PARSE_PAGE_SIZE)
                {
                    self.isAllPropagatedRipplesMostPopular = YES;
                }
            }
            else
            {
                self.selectedRippleArray = self.propagatedRipplesMostPopular;
            }
            
        }
        
        dispatch_async( dispatch_get_main_queue(), ^{
            // reload table and check if pending ripples
            [self.tableView reloadData];
            
            if (self.selectedRippleArray.count > 0)
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
            
            [self.activityIndicator stopAnimating];
            [self.activityIndicator setHidden:YES];
            
            if ([self.selectedRippleArray count] > 0)
                [self.noRipplesTextView setHidden:YES];
            else
            {
                if (filterMethod == 0)
                    self.noRipplesTextView.text = @"You haven't started a ripple. Tap the pencil to create one";
                else
                    self.noRipplesTextView.text = @"You haven't spread a ripple yet. Swipe a ripple on the feed to spread it";
                self.noTextTopConstraint.constant = 80;
                [self.noRipplesTextView setHidden:NO];
            }
        });
    });
    
    self.sortMethod = sortMethod;
    self.filterMethod = filterMethod;
}

#pragma mark - navigate here upon new ripple creation
// New ripple was created. Add it to the "started" list
- (void)notifyNewRipple:(NSNotification *)notification {
    
    Ripple *newRipple = (Ripple *)[notification object];
    [self.myRipples insertObject:newRipple atIndex:0];
    
    
    // use the UITableView to animate the removal of this row
    self.selectedRippleArray = self.myRipples;
    self.newRippleCreated = YES;
    
    [self.tableView reloadData];
    
    // determine if this was first ripple user sent
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    
    NSNumber *sentFirstRipple = [userData objectForKey:@"sentFirstRipple"];
    int sentFirstRippleCheck = [sentFirstRipple intValue];
    
    // if we recently updated, return
    if (sentFirstRippleCheck <= 2 && [[PFUser currentUser][@"score"] intValue] <= 250)
    {
        //increment point
        [[PFUser currentUser] incrementKey:@"score"];
        [[PFUser currentUser] saveInBackground];
        
        // show alert saying you got a point, and take to user page
        UIAlertView *sentFirstRipple = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:@"You just sent a ripple. Here's a point!" delegate:self cancelButtonTitle:@"Learn about points" otherButtonTitles:nil];
        
        [sentFirstRipple show];
        [userData setObject:[NSNumber numberWithInteger:2] forKey:@"sentFirstRipple"];
        [userData synchronize];
    }
    
    // start refresh
    [self.refreshControl setHidden:NO];
    [self.refreshControl beginRefreshing];
    
    // DELETE AFTER VIDEO:
    /*
     [AGPushNoteView showWithNotificationMessage:[NSString stringWithFormat:@"You have new ripples"]];
     
     [AGPushNoteView setMessageAction:^(NSString *message) {
     self.selectedRippleArray = self.pendingRipples;
     
     [self.rippleSegmentControl setSelectedSegmentIndex:1];
     [self chosenRippleSegmentChanged:nil];
     
     }];
     */
}

- (void)notifyNewRippleEnd:(NSNotification *)notification {
    [self refreshList];
    [self.refreshControl endRefreshing];
    [self.refreshControl setHidden:YES];
}


- (void)addRippleToPropagated:(NSNotification *)notification {
    // grab ripple
    Ripple *ripple = (Ripple *)[notification object];
    [self.propagatedRipples insertObject:ripple atIndex:0];
    
}

- (void)rippleDeleted:(Ripple *)ripple
{
    // use the UITableView to animate the removal of this row
    NSUInteger index = [self.myRipples indexOfObject:ripple];
    
    if (index != NSNotFound)
    {
        [self.tableView beginUpdates];
        [self.myRipples removeObject:ripple];
        
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                              withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
    }
    
    [self checkRemainingRipples];
    
    
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
           [BellowService deleteRipple:ripple];
    });
    
    [PFAnalytics trackEvent:@"RippleDeleted" dimensions:@{}];
    
    [Flurry logEvent:@"Ripple_Deleted"];
}

- (void)checkRemainingRipples
{
    if ([self.myRipples count] == 0 && self.filterMethod == 0)
    {
        self.noRipplesTextView.text = self.defaultNoPendingRippleString;
        [self.view updateConstraints];
        [self.noRipplesTextView setHidden:NO];
    }
    
    else
        [self.noRipplesTextView setHidden:YES];
}

#pragma mark - login and signup
- (void)showLogInAndSignUpView
{
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(justLoggedIn) name:@"justLoggedIn" object:nil];
    
    // Create the log in view controller
    RippleLogInView *logInViewController = [[RippleLogInView alloc] init];
    [logInViewController setDelegate:self]; // Set ourselves as the delegate
    [logInViewController setFields: PFLogInFieldsDefault];
    
    // Create the sign up view controller
    RippleSignUpView *signUpViewController = [[RippleSignUpView alloc] init];
    [signUpViewController setDelegate:self]; // Set ourselves as the delegate
    signUpViewController.fields = (PFSignUpFieldsUsernameAndPassword | PFSignUpFieldsSignUpButton | PFSignUpFieldsEmail | PFSignUpFieldsAdditional | PFSignUpFieldsDismissButton);

    [signUpViewController setDelegate:self]; // Set ourselves as the delegate
    
    // Assign our sign up controller to be displayed from the login controller
    [logInViewController setSignUpController:signUpViewController];
    
    // Present the log in view controller
    [self presentViewController:logInViewController animated:YES completion:NULL];
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    // Associate the device with a user
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation[@"user"] = [PFUser currentUser];
    [installation saveInBackground];
    
    
    // initiate user refresh
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        [[PFUser currentUser] fetch];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // initiate user user refresh
            self.currentUser = [PFUser currentUser];
            [self setupHeaderView];
            [self refreshList];
            // [self updateView];
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    });
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    UIAlertView *failToLogInAlertView = [[UIAlertView alloc] initWithTitle:@"Failed to log in" message:[NSString stringWithFormat:@"%@", error.userInfo[@"error"]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [failToLogInAlertView show];
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    // initiate user refresh
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        [[PFUser currentUser] fetch];
        
        //referral
        if (user[@"additional"] != NULL)
        {
            self.referralNum = [BellowService acceptReferral:user[@"additional"]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // initiate user user refresh
            self.currentUser = [PFUser currentUser];
            [self setupHeaderView];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReferralAlert" object:[NSNumber numberWithInt: self.referralNum]];
            
            [[PFUser currentUser] setObject:[[PFUser currentUser].username lowercaseString] forKey:@"canonicalUsername"];
            
            NSArray *followingArray = [NSArray arrayWithObject:@"qqyvLOFvNT"];
            [[PFUser currentUser] setObject:followingArray forKey:@"following"];
            
            [[PFUser currentUser] saveInBackground];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    });
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error
{
    
}

- (IBAction)loginSignupFromProfile:(id)sender
{
    [self showLogInAndSignUpView];
}

#pragma mark - swipeableCellDelegates
- (void)rippleDismissed:(Ripple *)ripple
{
    // update trending ripple
    NSUInteger position = [self.myRipples indexOfObject:ripple];
    Ripple *rippleObject = [self.myRipples objectAtIndex:position];
    rippleObject.actedUponState = 2;
    
    [self.myRipples replaceObjectAtIndex:position withObject:rippleObject];
    
    // post notifications
    ripple.actedUponState = 2;

    
    // data
    [PFAnalytics trackEvent:@"RippleDismissed" dimensions:@{@"feed":@"  "}];
    [Flurry logEvent:@"Ripple_Dismissed" withParameters:[NSDictionary dictionaryWithObject:@"user_profile_feed" forKey:@"feed"]];
    
}

- (void)ripplePropagated:(Ripple *)ripple
{
    // update ripple
    NSUInteger position = [self.myRipples indexOfObject:ripple];
    Ripple *rippleObject = [self.myRipples objectAtIndex:position];
    rippleObject.actedUponState = 1;
    rippleObject.numberPropagated += 1;
    
    [self.myRipples replaceObjectAtIndex:position withObject:rippleObject];
    
    // post notifications
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RipplePropagated" object:ripple];
    
    // data
    [PFAnalytics trackEvent:@"RipplePropagated" dimensions:@{@"feed":@"user_profile_feed"}];
    [Flurry logEvent:@"Ripple_Spread" withParameters:[NSDictionary dictionaryWithObject:@"user_profile_feed" forKey:@"feed"]];
    
    // check if this is first ripple
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    NSNumber *spreadFirstRipple = [userData objectForKey:@"spreadFirstRipple"];
    int spreadFirstRippleCheck = [spreadFirstRipple intValue];
    
    // if we recently updated, return. // Gal:???
    if (spreadFirstRippleCheck <= 100 && [[PFUser currentUser][@"score"] intValue] <= 101)
    {
        if (spreadFirstRippleCheck == 0) {
            [AGPushNoteView showWithNotificationMessage:[NSString stringWithFormat:@"You just spread your first ripple! It was sent to 7 people nearby"]];
            
            [AGPushNoteView setMessageAction:^(NSString *message) {
            }];
            
            
        }
        
        else if (spreadFirstRippleCheck == 3) {
            UIAlertView *tapOnRipple = [[UIAlertView alloc]initWithTitle:@"Tap on a Ripple!" message:@"See a map of where that ripple has spread and leave a comment"delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [tapOnRipple show];
            
            
            
        }
        
        else if (spreadFirstRippleCheck == 50) {
            
            UIAlertView *reviewRipple = [[UIAlertView alloc] initWithTitle:@"Review Ripple" message:@"Enjoying Ripple? Rate or review it!" delegate:self cancelButtonTitle:@"Not now" otherButtonTitles:@"Rate or review", nil];
            
            [Flurry logEvent:@"Ask_For_Review"];
            
            [reviewRipple show];
        }
        
        else if (spreadFirstRippleCheck == 100) {
            UIAlertView *referralPoints = [[UIAlertView alloc] initWithTitle:@"Invite friends!" message:[NSString stringWithFormat:@"Ripple is more fun with frineds! Get them on Ripple, you'll both earn points"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Invite", nil];
            [referralPoints show];
        }
        
        [userData setObject:[NSNumber numberWithInteger:(spreadFirstRippleCheck + 1)] forKey:@"spreadFirstRipple"];
        [userData synchronize];
    }
}

- (void)swipedRippleUpdateUserProfile:(NSNotification *)notification
{
    // check if the ripple is in the list
    Ripple *swipedRipple = (Ripple *)[notification object];
    
    NSUInteger index = [self.myRipples indexOfObject:swipedRipple];
    
    if (index != NSNotFound)
    {
        // update ripple
        if (swipedRipple.actedUponState == 1)
        {
            swipedRipple.numberPropagated += 1;
        }
        
        [self.myRipples replaceObjectAtIndex:index withObject:swipedRipple];
        
        [self.tableView reloadData];
    }
}
                                      

#pragma mark - Following methods
- (IBAction)didPressFollowButton:(id)sender {
    
    if ([PFUser currentUser][@"following"] != nil)
    {
        if([[PFUser currentUser][@"following"] indexOfObject:self.userId] == NSNotFound)
        {
            if (self.userId != [PFUser currentUser].objectId)
           {
                // add!
                [[PFUser currentUser][@"following"] addObject:self.userId];
                [self.followButton setImage:[UIImage imageNamed:@"following.png"] forState:UIControlStateNormal];
                [BellowService addToFollowingNumber:self.userId];
                
                // add to followingNum
                [self.currentUser incrementKey:@"followingNumber"];
                [self.followingNum setTitle:[NSString stringWithFormat:@"%ld",[self.currentUser[@"followingNumber"]integerValue]] forState:UIControlStateNormal];
            }
        }
        else
        {
            // remove!
            [[PFUser currentUser][@"following"] removeObject:self.userId];
            [self.followButton setImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
            [BellowService removeFromFollowingNumber:self.userId];
            
            // remove from followingNum
            [self.currentUser incrementKey:@"followingNumber" byAmount:[NSNumber numberWithInt:-1]];
            [self.followingNum setTitle:[NSString stringWithFormat:@"%ld",[self.currentUser[@"followingNumber"]integerValue]] forState:UIControlStateNormal];
        }
    }
    else
    {
        // we're adding a user...stupido!
        NSMutableArray *following = [[NSMutableArray alloc] initWithObjects:self.userId, nil];
        [PFUser currentUser][@"following"] = following;
        
        [self.followButton setImage:[UIImage imageNamed:@"following.png"] forState:UIControlStateNormal];
        [BellowService addToFollowingNumber:self.userId];
        
        // add to followingNum
        [self.currentUser incrementKey:@"followingNumber"];
        [self.followingNum setTitle:[NSString stringWithFormat:@"%d",[self.currentUser[@"followingNumber"]integerValue]] forState:UIControlStateNormal];
    }
    
    if ([self.followingNum.titleLabel.text isEqualToString:@"1"])
        [self.followingLabel setTitle:@"follower" forState:UIControlStateNormal];
    else
        [self.followingLabel setTitle:@"followers" forState:UIControlStateNormal];
            
    [[PFUser currentUser] saveInBackground];
    
    // postnotification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFollowing" object:self.userId];
}

- (IBAction)didPressFollowing:(id)sender {
    if (!self.userId)
        [self performSegueWithIdentifier:@"SegueToFollowingUsers" sender:nil];
}

- (IBAction)didPressFollower:(id)sender {
    if (!self.userId)
    {
        // alert that this feature is coming
        UIAlertView *comingFeature = [[UIAlertView alloc] initWithTitle:@"Coming Soon!" message:@"We're working on letting you see a list of your followers. Stay tuned!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [comingFeature show];
    }
}

#pragma mark - Scrollview related methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.userId)
    {
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
            
            if (!self.userId)
                [[NSNotificationCenter defaultCenter] postNotificationName:@"hideTabBar" object:nil];
        }
        
        else if (scrollView.contentOffset.y < self.contentOffset - 5)
        {
            if (!self.userId)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"showTabBar" object:nil];
                [self.tabBarController.tabBar setHidden:NO];
            }
            
            [[self navigationController] setNavigationBarHidden:NO animated:YES];
            
        }
        
        
        self.contentOffset = scrollView.contentOffset.y;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    self.url = URL;
    
    [self performSegueWithIdentifier:@"WebViewSegue" sender:nil];
    
    return NO;
}

#pragma mark - share and action items from profile view
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if ([alertView.title isEqualToString:@"Review Ripple"])
    {
        if (buttonIndex == 1)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"itms-apps://itunes.apple.com/app/" stringByAppendingString: @"id946792245"]]];
            
            [Flurry logEvent:@"Review_Clicked"];
        }
    }

    if ([alertView.title isEqualToString:@"Congratulations"])
    {
        [self performSegueWithIdentifier:@"SegueToPointsFromProfile" sender:nil];
    }
    
    
    if ([alertView.title isEqualToString:@"Invite your friends!"])
    {
        if (buttonIndex == 1)
        {
            UIActivityViewController *shareController = [ShareRippleSheet shareRippleSheet:nil];
            [self presentViewController:shareController animated:YES completion:nil];
        }
    }

}

- (void)justLoggedIn
{
    self.currentUser = [PFUser currentUser];
     [self setupHeaderView];
     [self refreshList];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"justLoggedIn" object:nil];
}

- (void)didPressSettings
{
   // perform segue
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideTabBar" object:nil];
    [self performSegueWithIdentifier:@"MoreSegue" sender:self];
}

- (void)shareSheetForRipple
{
    // alert view
    UIAlertView *referralPoints = [[UIAlertView alloc] initWithTitle:@"Invite your friends!" message:[NSString stringWithFormat:@"Earn points when friends sign in using your username as a referral code. Get points when they invite their friends, too."] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Invite", nil];
    [referralPoints show];
}

@end
