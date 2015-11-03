//
//  PropagateRippleTableViewController.m
//  Bellow
//
//  Created by Paul Stavropoulos on 11/8/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <CoreText/CoreText.h>
#import "HomePage.h"
#import "PendingRippleCell.h"
#import "MyRippleCell.h"
#import "WebViewViewController.h"
#import "BellowService.h"
#import "ImageCropping.h"
#import "RippleLogInView.h"
#import "RippleSignUpView.h"
#import "TTTTimeIntervalFormatter.h"
#import "MapView.h"
#import "ShareRippleSheet.h"
#import "AGPushNoteView.h"
#import "ImageViewerViewController.h"
#import "WebViewViewController.h"
#import "ProfilePageViewController.h"
#import "Flurry.h"
#import "TabBarController.h"
#import "NotificationsPage.h"
#import "PointsViewController.h"
#import "StaticProfileTableTableViewController.h"
#import <ParseFacebookUtilsV4/ParseFacebookUtilsV4.h>
#import <ParseTwitterUtils/ParseTwitterUtils.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>


#define ARC4RANDOM_MAX      0x100000000

@interface HomePage ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicatorFooter;
@property (weak, nonatomic) IBOutlet UITextView *noRipplesTextView;
@property (strong, nonatomic) UISegmentedControl *rippleSegmentControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noTextTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topTableViewConstraint;
@property (weak, nonatomic) IBOutlet UIButton *homeScreenFinishTutorialButton;

@property (strong, nonatomic) UIButton *barBtn;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) TTTTimeIntervalFormatter *timeIntervalFormatter;
@property (strong, nonatomic) NSString *defaultNoPendingRippleString;
@property (strong, nonatomic) Bellow *segueToRippleForPropagateCell;

@property (nonatomic) BOOL isFirstRunPostInteractiveTutorial;
@property (nonatomic) BOOL getLocationOnce;
@property (nonatomic) BOOL creatingAnonymousUser;
@property (nonatomic) BOOL viewDidLoadJustRan;
@property (nonatomic) BOOL finishedFirstUpdateView;
@property (nonatomic) BOOL segueWithCommentsUp;
@property (nonatomic) float originalTableHeaderHeight;
@property (nonatomic) float isChoosingSort;
@property (nonatomic) float isActive;
@property (nonatomic) int currentScore;
@property (strong, nonatomic) NSURL *url;

@property (nonatomic) BOOL continueRippleMapAnimation;
@property (strong, nonatomic) NSMutableArray *circles;
@property (nonatomic) CGRect originalTabFrame;
@property (nonatomic) CGFloat contentOffset;

@end


@implementation HomePage

NSString *defaultNoPendingRipplesString;

int PARSE_PAGE_SIZE = 25;

@synthesize locationManager;

- (NSMutableArray *)pendingRipples
{
    if (!_pendingRipples)
    {
        _pendingRipples = [[NSMutableArray alloc] init];
    }
    return _pendingRipples;
}

- (IBAction)unwindToPropagateRippleTableView:(UIStoryboardSegue *)segue
{
    if ([segue.identifier isEqualToString:@"unwindToHomeViewFromTutorial"])
    {
        if ([PFUser currentUser] && [PFUser currentUser][@"location"])
            [self updateView];
        else if ([PFUser currentUser] && ![PFUser currentUser][@"location"])
        {
            // signed up. Follow same process
            [self createAnonymousUser];
        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    self.url = URL;
    
    [self performSegueWithIdentifier:@"WebViewSegue" sender:nil];
    
    return NO;
}

-(void) goToMapView:(Bellow *)ripple withComments:(BOOL)commentsUp
{
    if (commentsUp)
        self.segueWithCommentsUp = YES;
    else
        self.segueWithCommentsUp = NO;
    
    [self performSegueWithIdentifier:@"MapViewSegue" sender:ripple];
}



- (void) goToImageView: (Bellow *)ripple
{
    if (ripple.imageFile)
    {
        [self performSegueWithIdentifier:@"RippleImageView" sender:ripple];
        [Flurry logEvent:@"Image_Open_Feed"];
    }
}

- (void) goToUserProfile: (Bellow *)ripple
{
    if (ripple)
    {
        if ([ripple.creatorId isEqualToString:[PFUser currentUser].objectId])
            [self.tabBarController setSelectedIndex:1];
        
        else
            [self performSegueWithIdentifier:@"UserProfile" sender:ripple];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"WebViewSegue"]) {
        [Flurry logEvent:@"Web_Open_MapView"];
        [PFAnalytics trackEvent:@"SegueToWebView" dimensions:nil];
        WebViewViewController *wvc = (WebViewViewController *)segue.destinationViewController;
        wvc.url = self.url;
    }
    
    if ([segue.identifier isEqualToString:@"MapViewSegue"]) {
        
        self.navigationItem.title = @"";
        
        // log event
        [PFAnalytics trackEvent:@"ViewCommentsAndMap" dimensions:@{@"Cell Type" : @"Home Cell"}];
        [Flurry logEvent:@"View_Comments_And_Map" withParameters:[NSDictionary dictionaryWithObject:@"home" forKey:@"page"]];
        
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
    
    /*
    if ([segue.identifier isEqualToString:@"SegueToMapViewForPropagatedCell"]) {
        self.navigationItem.title = @"";
        
        // log event
        [PFAnalytics trackEvent:@"ViewCommentsAndMap" dimensions:@{@"Cell Type" : @"Propagated Cell"}];
        
        RippleMapView *rmv = (RippleMapView *) segue.destinationViewController;
        if ([segue.destinationViewController isKindOfClass:[RippleMapView class]])
        {
             if ([sender isKindOfClass:[self class]])
             {
                
                rmv.ripple = self.segueToRippleForPropagateCell;
                rmv.selectedSegmentIndex = (int) self.rippleSegmentControl.selectedSegmentIndex;
                self.segueToRippleForPropagateCell = nil;
             }
        }
    }
     */
    
    if ([segue.identifier isEqualToString:@"RippleImageView"])
    {
        if ([sender isKindOfClass:[Bellow class]])
        {
            Bellow *ripple = (Bellow *)sender;
        
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
    
    if ([segue.identifier isEqualToString:@"UserProfile"])
    {
        if ([sender isKindOfClass:[Bellow class]])
        {
            [self.navigationController setNavigationBarHidden:NO];
            Bellow *ripple = sender;
            NSString *string = (NSString*) ripple.creatorId;
            ProfilePageViewController *ppvc = (ProfilePageViewController *)segue.destinationViewController;
            ppvc.userId = string;
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

    
    // BOOLs
    [self.barBtn setHidden:YES];
    self.viewDidLoadJustRan = NO;
    self.finishedFirstUpdateView = NO;
    [self.rippleSegmentControl setHidden:YES];
    [self.homeScreenFinishTutorialButton setHidden:YES];
    self.followingSkip = 0;
    
    self.continueRippleMapAnimation = YES;
    self.circles = [[NSMutableArray alloc] init];
    
    // set up navigation bar, table, and
    [self pageSetup];
    
    // check if have location and if need to segue
    if ([PFUser currentUser][@"location"])
    {
        [self.activityIndicator startAnimating];
        
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager = locationManager;
        
        if ([CLLocationManager locationServicesEnabled])
        {
            // Find the current location
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
            // Being compiled with a Base SDK of iOS 8 or later
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.locationManager requestAlwaysAuthorization];
            } else {
                // No such method on this device - do something else as needed
            }
        #else
            // Being compiled with a Base SDK of iOS 7.x or earlier
            // No such method - do something else as needed
        #endif
            
            [locationManager startUpdatingLocation];
        }

        
        
        self.isActive = YES;
        // check to see user is inactive
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[PFUser currentUser] fetch];
            
            // log on crashlytics
            [CrashlyticsKit setUserName:[PFUser currentUser].username];
            
            if  ([PFUser currentUser][@"isActive"]==[NSNumber numberWithBool:NO])
            {
                self.isActive = NO;
                [self getNearestRipplesOnLoad];
            }
            
            dispatch_async( dispatch_get_main_queue(), ^{
                if (!self.isActive)
                {
                    [PFUser currentUser][@"isActive"] = [NSNumber numberWithBool:YES];
                    [[PFUser currentUser] saveInBackground];
                    
                    self.isActive = YES;
                }
                
            
                self.currentScore = [[PFUser currentUser][@"score"] integerValue];
                [self.barBtn setTitle:[NSString stringWithFormat:@"%d", self.currentScore] forState:UIControlStateNormal];
                [self.barBtn setHidden:NO];
                
                //TODO: delete
                //[self presentHomeTutorial];
                //self.isFirstRunPostInteractiveTutorial = YES;
                
                [self updateView];
            });
        });
    }
    
    else
    {
        self.currentScore = 0;
        [self.barBtn setTitle:[NSString stringWithFormat:@"%d", self.currentScore] forState:UIControlStateNormal];
        [self.barBtn setHidden:NO];
    }
    
    // set up bar buttons
    self.barBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 42, 30)];
    [self.barBtn.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16]];
    self.barBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.barBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.barBtn addTarget:self action:@selector(didPressReachBarButton) forControlEvents:UIControlEventTouchUpInside];
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0,0,42,30)];
    buttonView.bounds = CGRectOffset(buttonView.bounds,10,0);
    [buttonView addSubview:self.barBtn];
    [self.barBtn.layer setBorderColor:[[UIColor colorWithRed:3.0/255.0f green:190.0f/255 blue:255.0f/255 alpha:1.0] CGColor]];
    [self.barBtn.layer setBorderWidth:1.0];
    [self.barBtn.layer setCornerRadius:5.0];

    [self.barBtn setTitleEdgeInsets:UIEdgeInsetsMake(1, 3, 1, 3)];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
    self.navigationItem.leftBarButtonItem = barButton;
    self.barBtn.titleLabel.adjustsFontSizeToFitWidth=YES;
    

    // get settings data
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        [BellowService getSettings];
    });

    
    // Set up notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyNewRipple:) name:@"goToProfile" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPendingRipples:) name:@"AppToForeground" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBarBtn) name:@"updateBarBtn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incrementScore) name:@"incrementScore" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(swipedRippleNotification:) name:@"swipedRipple" object:nil];

    // setup notification for referral alert
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(referralAlert:) name:@"ReferralAlert" object:nil];
    
    // [self checkIfShare];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    
    // tab bar and nav bar get ready
    self.navigationItem.hidesBackButton = NO;
    [self.tabBarController.tabBar setHidden:NO];
    [self.navigationController.navigationBar setHidden:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showTabBar" object:nil];
    
    if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [self.navigationController setHidesBarsOnSwipe:YES];

    // unhide button
    for(UIView *view in self.tabBarController.view.subviews)
    {
        if ([view isKindOfClass:[UIButton class]] && view.tag == 100)
        {
            [view setHidden:NO];
            break;
        }
    }
    
    if (!self.viewDidLoadJustRan)
        self.viewDidLoadJustRan = YES;
    //else
    //    [self.barBtn setTitle:[NSString stringWithFormat:@"%@", [PFUser currentUser][@"score"]] forState:UIControlStateNormal];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.originalTabFrame = self.tabBarController.tabBar.frame;
    
    self.segueToRippleForPropagateCell = nil;
    
    if (![PFUser currentUser])
        [self createAnonymousUser];
    
    else if (([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]] && [PFUser currentUser][@"reach"] == nil) ||
             ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]] && [PFUser currentUser][@"reach"] == nil))
        [self createAnonymousUser];
    
    
    
}

- (void)updateView
{
    // location not enabled for app; shut down experience
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
        [self presentNeedsLocation];
    
    else
    {
        if (self.isFirstRunPostInteractiveTutorial)
            return;
        
        self.rippleSegmentControl.userInteractionEnabled = YES;
        [self.rippleSegmentControl setAlpha:1.0];
        [self.noRipplesTextView setHidden:YES];
        [self.tableView setHidden:NO];
        self.rippleSegmentControl.enabled = YES;
        [self.tableView setAlpha:1.0];
        
        // Get Feed
        if (self.isFirstRun)
        {
            self.selectedRippleArray = self.pendingRipples;
            self.rippleSegmentControl.userInteractionEnabled = NO;
            [self.rippleSegmentControl setAlpha:0.5];
            return;
        }
        
        self.rippleSegmentControl.userInteractionEnabled = YES;
        [self.rippleSegmentControl setAlpha:1.0];
        
        
        if ([self.selectedRippleArray count] == 0)
        {
            self.continueRippleMapAnimation = YES;
            [self rippleMapAnimation];
        }
        
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Add code here to do background processing
            if (self.rippleSegmentControl.selectedSegmentIndex == 0)
                self.pendingRipples = [BellowService getPendingRipples:0];
            if (self.rippleSegmentControl.selectedSegmentIndex == 1)
            {
                self.followingRipples = [BellowService getFollowingRipples];
                self.followingSkip = 0;
            }
            if (self.rippleSegmentControl.selectedSegmentIndex == 2)
                self.topRipples  = [BellowService getTopRipples:0];
            
            dispatch_async( dispatch_get_main_queue(), ^{
                // reload table and check if pending ripples
                // [self checkRemainingRipples];
                [self updateBadgeNumber];
                [self checkBarrier];
                
                self.isFirstRunPostInteractiveTutorial = NO;
                
                
            });
        });
        
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (!self.finishedFirstUpdateView)
            {
                self.followingRipples = [BellowService getFollowingRipples];
                //self.topRipples  = [BellowService getTopRipples:0];
                
                dispatch_async( dispatch_get_main_queue(), ^{
                    [self checkBarrier];
                    self.finishedFirstUpdateView = YES;
                });

            }
            
        });
    }
}

- (void)checkBarrier
{
    switch ([self.rippleSegmentControl selectedSegmentIndex])
    {
        case 0:
            self.selectedRippleArray = self.pendingRipples;
            [self.tableView reloadData];
            [self.activityIndicator stopAnimating];
            
            if ([self.selectedRippleArray count] <25) // PARSE_PAGE_SIZE)
            {
                self.isAllHomeRipples = YES;
                
                if ([self.selectedRippleArray count] == 0)
                    [self setNoRipplesText];
            }
            else
            {
                self.isAllHomeRipples = NO;
            }
            
            
            break;
            
         
        case 1:
            self.selectedRippleArray = self.followingRipples;
            [self.tableView reloadData];
            [self.activityIndicator stopAnimating];
            
            if ([self.selectedRippleArray count] <25) // PARSE_PAGE_SIZE)
            {
                self.isAllFollowingRipples = YES;
                
                if ([self.selectedRippleArray count] == 0)
                    [self setNoRipplesText];
            }
            else
            {
                self.isAllFollowingRipples = NO;
            }
            
            break;
        
        case 2:
            self.selectedRippleArray = self.topRipples;
            [self.tableView reloadData];
            [self.activityIndicator stopAnimating];
            break;
            
        default:
            [self.activityIndicator stopAnimating];
            break;
    }
    
    self.continueRippleMapAnimation = NO;
    for (int i = 0; i < [self.circles count]; i++)
        [self.circles[i] removeFromSuperview];
    
    // [self checkRemainingRipples];
}


- (void)checkRemainingRipples
{
    if (!self.isFirstRunPostInteractiveTutorial)
    {
        if ([self.selectedRippleArray count] == 0)
        {
            [self setNoRipplesText];
            
            self.noTextTopConstraint.constant = 40;
            [self.view updateConstraints];
            [self.noRipplesTextView setHidden:NO];
            
            // log empty feed
            [PFAnalytics trackEvent:@"EmptyFeed" dimensions:nil];
            [Flurry logEvent:@"EmptyFeed"];
        }
        
        else
        {
            
            [self.noRipplesTextView setHidden:YES];
            [self.tableView setHidden:NO];
        }
    }
}

- (void)rippleMapAnimation
{
    self.circles = [[NSMutableArray alloc] init];
    
    int circleRadius = 20;
    int circleDiameter = circleRadius * 2;
    
    CGPoint groundZero = self.view.center;
    
    double randomMultiplierX = (((double)arc4random() / ARC4RANDOM_MAX) - 0.5) * 0.25;
    double randomMultiplierY = (((double)arc4random() / ARC4RANDOM_MAX) - 0.5) * 0.25;
    
    groundZero.x = groundZero.x + randomMultiplierX * self.view.frame.size.width;
    groundZero.y = groundZero.y + randomMultiplierY * self.view.frame.size.height;
    
    UIView *groundZeroCircle = [[UIView alloc] initWithFrame:CGRectMake(groundZero.x - circleRadius,
                                                                   groundZero.y - circleRadius,
                                                                   circleDiameter,
                                                                   circleDiameter)];
    //groundZeroCircle.alpha = 0.3;
    groundZeroCircle.layer.cornerRadius = circleRadius;
    groundZeroCircle.backgroundColor = [UIColor colorWithRed:1.0 green:196.0f/255 blue:50.0f/255 alpha:1.0];
    if (self.continueRippleMapAnimation)
        [self.view insertSubview:groundZeroCircle belowSubview:self.noRipplesTextView];
    [self.circles addObject: groundZeroCircle];
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        for (int i = 0; i < 6; i++)
        {
            double randomMultiplierX = (((double)arc4random() / ARC4RANDOM_MAX) - 0.5) * 0.4;
            double randomMultiplierY = (((double)arc4random() / ARC4RANDOM_MAX) - 0.5) * 0.4;
            
            CGPoint center;
            
            center.x = groundZero.x + randomMultiplierX * self.view.frame.size.width;
            center.y = groundZero.y + randomMultiplierY * self.view.frame.size.height;
            
            UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(center.x - circleRadius,
                                                                      center.y - circleRadius,
                                                                      circleDiameter,
                                                                      circleDiameter)];
            //circle.alpha = 0.3;
            circle.layer.cornerRadius = circleRadius;
            circle.backgroundColor = [UIColor colorWithRed:3.0/255.0f green:123.0f/255 blue:255.0f/255 alpha:0.9];
            
            if (self.continueRippleMapAnimation)
                [self.view insertSubview:circle belowSubview:groundZeroCircle];
            [self.circles addObject:circle];
            
            
        }
        
    });
    
    delayInSeconds = 1;
    popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        for (int i = 0; i < 6; i++)
        {
            double randomMultiplierX = (((double)arc4random() / ARC4RANDOM_MAX) - 0.5) * 0.65;
            double randomMultiplierY = (((double)arc4random() / ARC4RANDOM_MAX) - 0.5) * 0.65;
            
            CGPoint center;
            
            center.x = groundZero.x + randomMultiplierX * self.view.frame.size.width;
            center.y = groundZero.y + randomMultiplierY * self.view.frame.size.height;
            
            UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(center.x - circleRadius,
                                                                      center.y - circleRadius,
                                                                      circleDiameter,
                                                                      circleDiameter)];
            //circle.alpha = 0.3;
            circle.layer.cornerRadius = circleRadius;
            circle.backgroundColor = [UIColor colorWithRed:3.0/255.0f green:123.0f/255 blue:255.0f/255 alpha:0.9];
            
            if (self.continueRippleMapAnimation)
                [self.view insertSubview:circle belowSubview:groundZeroCircle];
            [self.circles addObject:circle];
        }
    });
    
    
   
    delayInSeconds = 2.5;
    popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        for (int i = 0; i < [self.circles count]; i++)
        {
            [self.circles[i] removeFromSuperview];
        }
        
    });
}


- (void)segmentChanged
{
    switch (self.rippleSegmentControl.selectedSegmentIndex)
    {
        // Pending ripples
        case 0:
            //[Flurry logEvent:@"View_Pending"];
            //[self.filterView setHidden:YES];
            self.selectedRippleArray = self.pendingRipples;
            self.tableView.allowsSelection = YES;
        
            break;

        case 1:
            //[Flurry logEvent:@"View_Rippled"];
            self.selectedRippleArray = self.followingRipples;
            self.tableView.allowsSelection = YES;
            break;
            
        case 2:
            //[Flurry logEvent:@"View_Rippled"];
            self.selectedRippleArray = self.topRipples;
            break;
            
        default:
            break;
    }
    
    [self.tableView reloadData];
    [self updateViewConstraints];
    [self ChangeColorOfSegment:self.rippleSegmentControl];
    [self.activityIndicator stopAnimating];
    
    if (self.selectedRippleArray.count > 0)
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    [self checkRemainingRipples];
    
    [PFAnalytics trackEvent:@"HomePageSegmentSwitch" dimensions:@{@"Segment" : [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:self.rippleSegmentControl.selectedSegmentIndex]]}];
    [Flurry logEvent:@"Home_Page_Segment_Switch" withParameters:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:self.rippleSegmentControl.selectedSegmentIndex]] forKey:@"Selected"]];
}


#pragma mark - table work
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.selectedRippleArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self setPropagatedCell:tableView withIndexPath:indexPath];
    
    /*
    switch (self.rippleSegmentControl.selectedSegmentIndex)
    {
        // Pending ripples
        case 0:
            return [self setPropagatedCell:tableView withIndexPath:indexPath];
            break;
        // My ripples
        default:
            return [self setMyRippleCell:tableView withIndexPath:indexPath];
            break;
    }
    */
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
        return 0;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
    UILabel *label = [[UILabel alloc] init];
    label.text = @"today's top ripples:";
    [label setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:15.0]];
    [label setFrame:CGRectMake(18, 5, 200, 21)];
    [headerView addSubview:label];
    [headerView setBackgroundColor:[UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1.0]];
    return headerView;
}


- (PendingRippleCell *)setPropagatedCell:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath
{
    // grab the correct cell ripple
    [tableView registerNib:[UINib nibWithNibName:@"PendingCell" bundle:nil] forCellReuseIdentifier:@"PropagateRippleCell"];
    PendingRippleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PropagateRippleCell" forIndexPath:indexPath];
    cell.currentRipple = nil;
    
    cell.currentRipple = [self.selectedRippleArray objectAtIndex:indexPath.row];
    cell.delegate = self;
    
    // reset button images
    cell.currentRipple.actedUponState = 0;
    [cell.dismissButton setHidden:NO];
    [cell.spreadButton setHidden:NO];
    [cell.spreadButton setUserInteractionEnabled:YES];
    [cell.dismissButton setUserInteractionEnabled:YES];

    [cell.spreadButton setImage:[UIImage imageNamed:@"propagateButtonUnselected"] forState:UIControlStateNormal];
    [cell.dismissButton setImage:[UIImage imageNamed:@"dismissRippleIconUnselected"] forState:UIControlStateNormal];
    
    // update constraints for the text view
    [cell setNeedsUpdateConstraints];
    [cell layoutIfNeeded];

    // Configure the cell
    cell.rippleTextView.text = cell.currentRipple.text;
    cell.rippleTextView.delegate = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    // userlabel work
    [cell.userLabel setTitle:cell.currentRipple.creatorName forState:UIControlStateNormal];
    
    UIFont *myFont = [UIFont fontWithName:@"AvenirNext-Medium" size:18.0];
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:myFont, NSFontAttributeName,nil];
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    
    CGSize stringSize = [cell.currentRipple.creatorName sizeWithAttributes:attributesDictionary];
    
    cell.userLabelWidthConstraint.constant = stringSize.width + 3; //[UIScreen mainScreen].bounds.size.width;
    
    // set city and time
    NSTimeInterval timeInterval = [cell.currentRipple.createdAt timeIntervalSinceNow];
    if (cell.currentRipple.city)
    {
        // set city label hidden
        [cell.cityLabel setHidden:NO];
        cell.cityLabel.text = cell.currentRipple.city;
        
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
    rippledText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%dx", cell.currentRipple.numberPropagated] attributes:boldAttributes];
    [cell.numPropagatedLabel setAttributedText:rippledText];
    [cell.numPropagatedLabel setTextColor:[UIColor colorWithRed:3.0/255.0f green:123.0f/255 blue:255.0f/255 alpha:1.0]];
    [cell.reachSpreadLabel setText:[NSString stringWithFormat:@"spread to %@ people",[PFUser currentUser][@"reach"]]];
    [cell.reachSpreadLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:13.0]];
    [cell.dismissLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:13.0]];
    
    // do work to display comments and recognize tap
    [cell.numberOfCommentsButton setTitle:[NSString stringWithFormat:@"%d", cell.currentRipple.numberComments] forState:UIControlStateNormal];
    
    // set colors of dismiss and propagate views
    cell.propagateView.backgroundColor = [UIColor colorWithRed:3.0/255.0f green:123.0f/255 blue:255.0f/255 alpha:1.0];
    cell.dismissView.backgroundColor = [UIColor colorWithRed:255/255.0f green:92.0f/255 blue:122.0f/255 alpha:1.0];
    cell.propagateImageView.alpha = 0.2;
    cell.dismissImageView.alpha = 0.2;
    
    
    cell.textViewWidthConstraint.constant = [UIScreen mainScreen].bounds.size.width - 8;
    
    // set text top constraint if  have image
    if (cell.currentRipple.imageFile)
    {
        // image work!
        [cell.outerImageView setHidden:NO];
        [cell.rippleImageView setHidden:NO];
        cell.rippleImageView.image = [UIImage imageNamed:@"grayBox.png"];
        [cell.outerImageView setBackgroundColor:[UIColor colorWithWhite:232/255.0 alpha:1.0]];
        
        cell.rippleImageView.file = (PFFile *)cell.currentRipple.imageFile;
        
        // set text top constraint if  have image
        CGFloat heightRatio = (float) cell.currentRipple.imageHeight / cell.currentRipple.imageWidth;
        cell.rippleImageViewWidthConstraint.constant = cell.outerImageView.frame.size.width;
        
        CGFloat cellImageHeight;
        if (([UIScreen mainScreen].bounds.size.width) *heightRatio <=350)
        {
            cell.outerImageViewHeightConstraint.constant = ([UIScreen mainScreen].bounds.size.width) *heightRatio;
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
        cell.topTextViewConstraint.constant = cellImageHeight + cell.outerImageView.frame.origin.y + cell.spreadCommentView.frame.size.height + 5;
        
        // find textview height
        [cell.rippleTextView setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0]];
        CGSize maximumSize = CGSizeMake(self.tableView.frame.size.width- 12.0, 9999);
        CGRect textSize =  [cell.currentRipple.text boundingRectWithSize:maximumSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:context];
        
        cell.textViewHeightConstraint.constant = textSize.size.height + 30;
        
        // place spreadCommentView on image
        cell.spreadCommentViewTopConstraint.constant = cellImageHeight + cell.outerImageView.frame.origin.y;
        
        // remove borders, but add border around image
        [cell.rippleTextView.layer setBorderWidth:0.0];
        [cell.outerImageView.layer setBorderColor:[[UIColor colorWithRed:220.0/255.0f green:220.0f/255 blue:220.0f/255 alpha:1.0] CGColor]];
        [cell.outerImageView.layer setBorderWidth:1.0];
        
        cell.rightSpreadCommentViewConstraint.constant = 0;
        cell.leftSpreadCommentViewConStraint.constant = 0;
    
    }
    
    else
    {
        cell.rippleImageView.hidden = YES;
        cell.rippleImageView.image = nil;
        [cell.outerImageView setHidden:YES];
        [cell.rippleTextView setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:20.0]];
        cell.topTextViewConstraint.constant = cell.outerImageView.frame.origin.y;
        
        // find textview height
        [cell.rippleTextView setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:20.0]];
        CGSize maximumSize = CGSizeMake(self.tableView.frame.size.width- 12.0, 9999);
        UIFont *myFont = [UIFont fontWithName:@"AvenirNext-Regular" size:20.0];
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:myFont, NSFontAttributeName,nil];
        NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
        
        CGRect textSize =  [cell.currentRipple.text boundingRectWithSize:maximumSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:context];
        
        cell.textViewHeightConstraint.constant = textSize.size.height + 53;

        
        // place spreadCommentView there
        cell.spreadCommentViewTopConstraint.constant = textSize.size.height + cell.outerImageView.frame.origin.y + 20;
        
        // add small border to this
        [cell.rippleTextView.layer setBorderColor:[[UIColor colorWithRed:220.0/255.0f green:220.0f/255 blue:220.0f/255 alpha:1.0] CGColor]];
        [cell.rippleTextView.layer setBorderWidth:1.0];
        cell.rippleTextView.layer.cornerRadius = 5.0;
        
        cell.rightSpreadCommentViewConstraint.constant = 4;
        cell.leftSpreadCommentViewConStraint.constant = 4;
    }

    if (cell.currentRipple.isFollowingUser) {
        [cell.followingImage setHidden:NO];
        cell.leftUsernameConstraint.constant = 29;
    }
    else
    {
        [cell.followingImage setHidden:YES];
        cell.leftUsernameConstraint.constant = 8;
    }
    
    // update constraints
    [cell setNeedsUpdateConstraints];
    [cell layoutIfNeeded];
    
    // not selectable
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell.propagateImageView setHidden:NO];
        
    if (([cell.currentRipple.rippleId isEqualToString:@"FakeRipple"] || [cell.currentRipple.rippleId isEqualToString:@"FakeRippleTap"]) && indexPath.row != 0)
        cell.rippleMainView.backgroundColor= [UIColor lightGrayColor];
    else
        cell.rippleMainView.backgroundColor = [UIColor whiteColor];
    
    // set constraints to 0 and reset buttons
    [cell.spreadButton setHidden:NO];
    [cell.spreadButton setAlpha:1.0];
    [cell.dismissButton setAlpha:1.0];
    [cell.dismissButton setHidden:NO];
    
    // add border to username
    /*[cell.userLabel.layer setBorderColor:[[UIColor colorWithWhite:0.9 alpha:1.0] CGColor]];
    [cell.userLabel.layer setBorderWidth:1.0];
    cell.userLabel.layer.cornerRadius = 5.0;*/
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[PendingRippleCell class]])
    {
        PendingRippleCell *propagateCell = (PendingRippleCell *)cell;
        
        // set up height of dismiss and propagate views
        propagateCell.dismissViewHeightConstraint.constant = propagateCell.rippleMainView.frame.size.height;
        propagateCell.propagateViewHeightConstraint.constant = propagateCell.rippleMainView.frame.size.height;
        propagateCell.spreadButtonLeftConstraint.constant = -7;
        propagateCell.dismissButtonRightConstaint.constant = -7;

        [propagateCell setNeedsUpdateConstraints];
        [propagateCell layoutIfNeeded];
        
        [super updateViewConstraints];
        
        // work to add circles to propagate view
        propagateCell.rippleCircles = [[NSMutableArray alloc] init];
        for (int i = 0; i < 3; i ++)
        {
            UIView *outerCircle = [[UIView alloc] initWithFrame:CGRectMake(propagateCell.propagateView.frame.size.width - 30.0 - propagateCell.propagateImageView.frame.size.width/2 - 1.1, propagateCell.rippleMainView.frame.size.height/2.0 - 1.1, 2.2, 2.2)];
            outerCircle.alpha = 0.3;
            outerCircle.layer.cornerRadius = 1.1;
            
            UIView *innerCircle = [[UIView alloc] initWithFrame:CGRectMake(propagateCell.propagateView.frame.size.width - 30.0 - propagateCell.propagateImageView.frame.size.width/2 - 1, propagateCell.rippleMainView.frame.size.height/2.0 - 1, 2, 2)];
            innerCircle.alpha = 0.3;
            innerCircle.layer.cornerRadius = 1;
            
            [propagateCell.propagateView addSubview:outerCircle];
            [propagateCell.propagateView addSubview:innerCircle];
            
            [propagateCell.rippleCircles addObject:outerCircle];
            [propagateCell.rippleCircles addObject:innerCircle];
            
            
            // add shadow and unhide propagateimage
            propagateCell.rippleMainView.layer.shadowOffset = CGSizeMake(0,0);
            propagateCell.rippleMainView.layer.shadowRadius = 2;
            propagateCell.rippleMainView.layer.shadowOpacity = 0.5;
            propagateCell.rippleMainView.layer.shadowPath = [UIBezierPath bezierPathWithRect:propagateCell.rippleMainView.bounds].CGPath;
            propagateCell.propagateView.layer.shadowOffset = CGSizeMake(0,0);
            propagateCell.propagateView.layer.shadowRadius = 2;
            propagateCell.propagateView.layer.shadowOpacity = 0.5;
            propagateCell.propagateView.layer.shadowPath = [UIBezierPath bezierPathWithRect:propagateCell.propagateView.bounds].CGPath;
            propagateCell.dismissView.layer.shadowOffset = CGSizeMake(0,0);
            propagateCell.dismissView.layer.shadowRadius = 2;
            propagateCell.dismissView.layer.shadowOpacity = 0.5;
            propagateCell.dismissView.layer.shadowPath = [UIBezierPath bezierPathWithRect:propagateCell.dismissView.bounds].CGPath;
        }
    }


    if ([indexPath row] == [self.selectedRippleArray count] - 6)
    {
        if (self.rippleSegmentControl.selectedSegmentIndex == 0 && !self.isAllHomeRipples)
        {
            [self.indicatorFooter startAnimating];

            // call method to create ripples with block to reload
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSArray *newHomeRipples = [BellowService getPendingRipples:(int)[self.selectedRippleArray count]];
                
                if (newHomeRipples.count < PARSE_PAGE_SIZE)
                    self.isAllHomeRipples = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.pendingRipples addObjectsFromArray:newHomeRipples];
                    self.selectedRippleArray = self.pendingRipples;
                    [self.indicatorFooter stopAnimating];
                    [self.tableView reloadData];
                });
            });
        }
        
        if (self.rippleSegmentControl.selectedSegmentIndex == 1 && !self.isAllFollowingRipples)
        {
            [self.indicatorFooter startAnimating];
            // call method to create ripples with block to reload
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSArray *newFollowingRipples = [BellowService getStoredFollowingRipples:self.followingSkip + 25];
                
                if (newFollowingRipples.count < PARSE_PAGE_SIZE)
                    self.isAllFollowingRipples = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.followingSkip += 25;
                    [self.followingRipples addObjectsFromArray:newFollowingRipples];
                    self.selectedRippleArray = self.followingRipples;
                    [self.indicatorFooter stopAnimating];
                    [self.tableView reloadData];
                });
            });
        }
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        // set current ripple
        Bellow *currentRipple = [self.selectedRippleArray objectAtIndex:indexPath.row];
        
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
            
            if (currentRipple.imageHeight <= currentRipple.imageWidth)
                imageHeight += 25;
            
            // include height of spreadViewComment
            imageHeight += 25;
            
            UIFont *myFont = [UIFont fontWithName:@"AvenirNext-Regular" size:16.0];
            attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:myFont, NSFontAttributeName,nil];
        }
        else
        {
            imageHeight = 20;
            UIFont *myFont = [UIFont fontWithName:@"AvenirNext-Regular" size:20.0];
            attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:myFont, NSFontAttributeName,nil];
        }
    
        CGRect stringsize =  [currentRipple.text boundingRectWithSize:maximumSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:context];
        
        CGFloat dismissSpreadView = 60;
        
        return stringsize.size.height + imageHeight + 75 + dismissSpreadView;
}


- (void)rippleDismissed:(Bellow *)ripple
{
    // use the UITableView to animate the removal of this row
    NSUInteger index = [self.selectedRippleArray indexOfObject:ripple];
    if (index != NSNotFound)
    {
        [self.tableView beginUpdates];
        [self.selectedRippleArray removeObject:ripple];
        PendingRippleCell *cell = (PendingRippleCell *)[self.tableView cellForRowAtIndexPath:0];
        cell.rippleMainView.backgroundColor = [UIColor whiteColor];

        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                              withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
        [self checkRemainingRipples];
    }
    
    if (self.rippleSegmentControl.selectedSegmentIndex ==0)
        [BellowService dismissRipple:ripple];
    else
        [BellowService dismissSwipeableRipple:ripple];
    
    // check if first dismiss
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    NSNumber *dismissFirstRipple = [userData objectForKey:@"dismissFirstRipple"];
    int dismissFirstRippleCheck = [dismissFirstRipple intValue];
    
    // notification to update ripple on explore feed
    ripple.actedUponState = 2;
    [self swipedRipple:ripple];
    
    
    // if we recently updated, return
    if (dismissFirstRippleCheck != 1 && [[PFUser currentUser][@"score"] intValue] <= 10)
    {
        [AGPushNoteView showWithNotificationMessage:@"You just dismissed a ripple. You will not see it again."];
        
        [userData setObject:[NSNumber numberWithInteger:1] forKey:@"dismissFirstRipple"];
        [userData synchronize];
    }
    
    [self incrementScore];

    if (self.rippleSegmentControl.selectedSegmentIndex == 0)
    {
        [PFAnalytics trackEvent:@"RippleDismissed" dimensions:@{@"feed":@"home_feed"}];
        [Flurry logEvent:@"Ripple_Dismissed" withParameters:[NSDictionary dictionaryWithObject:@"home_feed" forKey:@"feed"]];
    }
    if (self.rippleSegmentControl.selectedSegmentIndex == 1)
    {
        [PFAnalytics trackEvent:@"RippleDismissed" dimensions:@{@"feed":@"following_feed"}];
        [Flurry logEvent:@"Ripple_Dismissed" withParameters:[NSDictionary dictionaryWithObject:@"following_feed" forKey:@"feed"]];
    }
    if (self.rippleSegmentControl.selectedSegmentIndex == 2)
    {
        [PFAnalytics trackEvent:@"RippleDismissed" dimensions:@{@"feed":@"trending_feed"}];
        [Flurry logEvent:@"Ripple_Dismissed" withParameters:[NSDictionary dictionaryWithObject:@"trending_feed" forKey:@"feed"]];
    }
}


- (void)ripplePropagated:(Bellow *)ripple
{
    // use the UITableView to animate the removal of this row
    NSUInteger index = [self.selectedRippleArray indexOfObject:ripple];
    if (index != NSNotFound)
    {
        [self.tableView beginUpdates];
        [self.selectedRippleArray removeObject:ripple];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                              withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView endUpdates];
        [self checkRemainingRipples];
    }
    
    // cloud calls and notifications
    if (ripple.miniRippleId != nil)
        [BellowService propagateRipple:ripple];
    else
        [BellowService propagateSwipeableRipple:ripple];
    
    ripple.numberPropagated += 1;
    ripple.actedUponState = 1;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RipplePropagated" object:ripple];
    [self swipedRipple:ripple];

    // check if thisis first ripple
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    NSNumber *spreadFirstRipple = [userData objectForKey:@"spreadFirstRipple"];
    int spreadFirstRippleCheck = [spreadFirstRipple intValue];
    
    // if we recently updated, return. 
    if (spreadFirstRippleCheck <= 100 && [[PFUser currentUser][@"score"] intValue] <= 101)
    {
        if (spreadFirstRippleCheck == 0) {
            [AGPushNoteView showWithNotificationMessage:[NSString stringWithFormat:@"You just spread your first ripple! It was sent to 7 people nearby"]];
            
            [AGPushNoteView setMessageAction:^(NSString *message) {
            }];
        }
        
        else if (spreadFirstRippleCheck == 3) {
            UIAlertView *tapOnRipple = [[UIAlertView alloc]initWithTitle:@"Tap on a Bellow!" message:@"See a map of where that ripple has spread and leave a comment"delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [tapOnRipple show];
        }
        
        else if (spreadFirstRippleCheck == 50) {
            
            UIAlertView *reviewRipple = [[UIAlertView alloc] initWithTitle:@"Review Bellow" message:@"Enjoying Bellow? Rate or review it!" delegate:self cancelButtonTitle:@"Not now" otherButtonTitles:@"Rate or review", nil];
            
            [Flurry logEvent:@"Ask_For_Review"];
            [reviewRipple show];
        }
        
        else if (spreadFirstRippleCheck == 100) {
            UIAlertView *referralPoints = [[UIAlertView alloc] initWithTitle:@"Invite friends!" message:[NSString stringWithFormat:@"If you're enjoying ripple, invite your friends! You'll both earn points"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Invite", nil];
            [referralPoints show];
        }
        
        [userData setObject:[NSNumber numberWithInteger:(spreadFirstRippleCheck + 1)] forKey:@"spreadFirstRipple"];
        [userData synchronize];
    }
    
    
    // call method to increment score and check level
    [self incrementScore];
    
    if (self.rippleSegmentControl.selectedSegmentIndex == 0)
    {
        [PFAnalytics trackEvent:@"RipplePropagated" dimensions:@{@"feed":@"home_feed"}];
        [Flurry logEvent:@"Ripple_Spread" withParameters:[NSDictionary dictionaryWithObject:@"home_feed" forKey:@"feed"]];
    }
    if (self.rippleSegmentControl.selectedSegmentIndex == 1)
    {
        [PFAnalytics trackEvent:@"RipplePropagated" dimensions:@{@"feed":@"following_feed"}];
        [Flurry logEvent:@"Ripple_Spread" withParameters:[NSDictionary dictionaryWithObject:@"following_feed" forKey:@"feed"]];
    }
    if (self.rippleSegmentControl.selectedSegmentIndex == 2)
    {
        [PFAnalytics trackEvent:@"RipplePropagated" dimensions:@{@"feed":@"trending_feed"}];
        [Flurry logEvent:@"Ripple_Spread" withParameters:[NSDictionary dictionaryWithObject:@"trending_feed" forKey:@"feed"]];
    }
    

}


#pragma mark - notification methods

- (void)incrementScore
{
    self.currentScore = self.currentScore+ 1;
    [self.barBtn setTitle:[NSString stringWithFormat:@"%d",self.currentScore] forState:UIControlStateNormal];
}

- (void)updateBarBtn
{
    self.currentScore = [[PFUser currentUser][@"score"] integerValue];
    [self.barBtn setTitle:[NSString stringWithFormat:@"%d",self.currentScore] forState:UIControlStateNormal];
}

- (void)swipedRipple:(Bellow *)swipedRipple
{
    NSArray *arrays = [NSArray arrayWithObjects:self.pendingRipples, self.followingRipples, self.topRipples, nil];
    
    for (int i=0; i<[arrays count]; i++) {
        if (self.rippleSegmentControl.selectedSegmentIndex != i)
        {
            // check if the ripple is in the list
            NSInteger position = [arrays[i] indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([[(Bellow *)obj rippleId] isEqualToString:swipedRipple.rippleId]) {
                    *stop = YES;
                    return YES;
                }
                return NO;
            }];
            
            if (position != NSNotFound)
            {
                [arrays[i] removeObjectAtIndex:position];
            }
        }
    }
}

- (void)swipedRippleNotification: (NSNotification *)notification {
    Bellow *ripple = (Bellow *)[notification object];
    
    NSArray *arrays = [NSArray arrayWithObjects:self.pendingRipples, self.followingRipples, self.topRipples, nil];
    
    for (int i=0; i<[arrays count]; i++)
    {
        // check if the ripple is in the list
        NSInteger position = [arrays[i] indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[(Bellow *)obj rippleId] isEqualToString:ripple.rippleId]) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        
        if (position != NSNotFound)
        {
            [arrays[i] removeObjectAtIndex:position];
        }
    }
}

-(void)referralAlert:(NSNotification *)notification {
    
    NSNumber *referral = (NSNumber *)[notification object];
    
    if (referral == [NSNumber numberWithInt:0])
    {
        [self.tabBarController setSelectedIndex:0];
        UIAlertView *failedToRefer = [[UIAlertView alloc] initWithTitle:@"Uh Oh!" message:@"Looks like your referral code did not work." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try Again", nil];
        [failedToRefer show];
    }
    else if (referral ==  [NSNumber numberWithInt:-1])
    {
        UIAlertView *alreadyUsed = [[UIAlertView alloc]initWithTitle:@"Already referred" message:@"You have already used a referral code." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alreadyUsed show];
    }
    
    else
    {
        self.currentScore = [[PFUser currentUser][@"score"] integerValue];
        self.currentScore = self.currentScore + [referral intValue];
        [self.barBtn setTitle:[NSString stringWithFormat:@"%d",self.currentScore] forState:UIControlStateNormal];
        
        UIAlertView *referralPoints = [[UIAlertView alloc] initWithTitle:@"Woohoo!" message:[NSString stringWithFormat:@"You've just earned %@ points. Invite your friends to earn more", referral] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Invite", nil];
        [referralPoints show];
    }
}

// New ripple was created. Add it to the "started" list
- (void)refreshPendingRipples:(NSNotification *)notification {
    
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
        [self presentNeedsLocation];
    
    else
    {
        self.rippleSegmentControl.userInteractionEnabled = YES;
        [self.rippleSegmentControl setAlpha:1.0];
        [self.noRipplesTextView setHidden:YES];
        self.rippleSegmentControl.enabled = YES;
        [self.tableView setHidden:NO];
    }
    
    // Figure out which view we are on
    if ([self.selectedRippleArray count] == 0)
    {
        self.continueRippleMapAnimation = YES;
        [self rippleMapAnimation];
    }
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        
        if ([self.rippleSegmentControl selectedSegmentIndex] == 0)
        {
            self.pendingRipples = [BellowService getPendingRipples:0];
            self.selectedRippleArray = self.pendingRipples;
        }
        
        else if (self.rippleSegmentControl.selectedSegmentIndex ==1)
        {
            self.followingRipples = [BellowService getFollowingRipples];
            self.selectedRippleArray = self.followingRipples;
        }
        
        dispatch_async( dispatch_get_main_queue(), ^{
            // reload table and check if pending ripples
            // [self checkRemainingRipples];
            self.continueRippleMapAnimation = NO;
            for (int i = 0; i < [self.circles count]; i++)
                [self.circles[i] removeFromSuperview];
            
            [self.tableView reloadData];
            [self checkBarrier];
            
            self.isFirstRunPostInteractiveTutorial = NO;
        });
    });
    [self addNotificationsBadge];
}

#pragma mark - Log in and sign up
- (void)createAnonymousUser
{

    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    NSNumber *isTutorialDone = [userData objectForKey:@"isTutorialDone"];
    
    
    if ([isTutorialDone boolValue])
    {
        self.isFirstRunPostInteractiveTutorial = YES;
        //[self presentHomeTutorial];
        // set isfirstrun
        self.isFirstRun = YES;
        self.getLocationOnce = YES;
        
        
        // no currentuser; user hasn't been signed in
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager = locationManager;
        
        if ([CLLocationManager locationServicesEnabled])
        {
            // Find the current location
            #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
            // Being compiled with a Base SDK of iOS 8 or later
            // Now do a runtime check to be sure the method is supported
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.locationManager requestAlwaysAuthorization];
            } else {
                // No such method on this device - do something else as needed
            }
            #else
            // Being compiled with a Base SDK of iOS 7.x or earlier
            #endif
            
            [locationManager startUpdatingLocation];
        }
    }
    
    else
    {
        [self performSegueWithIdentifier:@"SegueToTutorial" sender:self];
    }
}

- (void)presentHomeTutorial
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"inactiveTabBarController" object:nil];
    
    [self.activityIndicator stopAnimating];
    [self.tableView setHidden:NO];
    [self.tableView setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:0.5]];
    [self.rippleSegmentControl setAlpha:0.3];
    [self.barBtn setAlpha:0.3];
    
    [self.tableView setUserInteractionEnabled:NO];
    [self.barBtn setUserInteractionEnabled:NO];
    [self.rippleSegmentControl setUserInteractionEnabled:NO];
    [self.homeScreenFinishTutorialButton setHidden:NO];
    
    if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [self.navigationController setHidesBarsOnSwipe:NO];
    
    // create ripple!
    Bellow *rippleClick = [[Bellow alloc] init];
    rippleClick.rippleId = @"FakeRippleTap";
    rippleClick.text = @"Swipe Ripples to spread them to more people or to dismiss them!";
    rippleClick.imageFile = nil;
    rippleClick.imageHeight = 0;
    rippleClick.imageWidth = 0;
    rippleClick.creatorName = @"Bellow Tutorial";
    rippleClick.miniRippleId = @"FakeMiniRipple";
    rippleClick.commentArray = [@[] mutableCopy];
    rippleClick.commentIds = [@[] mutableCopy];
    rippleClick.createdAt = [NSDate date];
    rippleClick.numberPropagated = 4;
    rippleClick.numberComments = 1;
    rippleClick.city = @"San Francisco";
    
    self.selectedRippleArray = [NSMutableArray arrayWithObjects:rippleClick, nil];
    [self.tableView reloadData];

    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //save user's location!
    self.location = [locations lastObject];
    
    NSTimeInterval locationAge = -[self.location.timestamp timeIntervalSinceNow];
    if (locationAge > 0.2)
        return;
    
    double randomVal1 = ((double)arc4random() / ARC4RANDOM_MAX) - 0.5;
    double randomVal2 = ((double)arc4random() / ARC4RANDOM_MAX) - 0.5;
    double latitudeJiggle = randomVal1 / 222;
    double milesInLongitudeDegree = 69.11 * cos(self.location.coordinate.longitude);
    double longitudeJiggle = randomVal2 / (milesInLongitudeDegree * 1.6 * 2);

    
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:self.location.coordinate.latitude + latitudeJiggle longitude:self.location.coordinate.longitude + longitudeJiggle];
    
    if ([PFUser currentUser][@"location"])
    {
        [[PFUser currentUser] setObject:point forKey:@"location"];
        [[PFUser currentUser] saveInBackground];
        
        // increment score
        [self incrementScore];
        
    }
    
    else // no location, and first time getting it; also create ripples
    {
        BOOL isAnonymous = YES;
        if ([PFUser currentUser])
            isAnonymous = NO;
        [self saveAnonymousUser:isAnonymous withPoint:point];
    }
    // terminate after first time run:
    [manager stopUpdatingLocation];
    
}

- (void)saveAnonymousUser:(BOOL)isAnonymous withPoint:(PFGeoPoint *)point
{
    self.noRipplesTextView.text = @"Getting your first ripples...";
    [self.noRipplesTextView setHidden:NO];
    [self.noRipplesTextView setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:26.0]];
    self.noTextTopConstraint.constant = 40;
    
    // anonymous sign up
    if (![PFUser currentUser] && !self.creatingAnonymousUser)
    {
        self.creatingAnonymousUser = YES;
        [PFAnonymousUtils logInWithBlock:^(PFUser *currentUser, NSError *error) {
            if (error)
            {
                NSLog(@"Anonymous login failed.");
                self.creatingAnonymousUser = NO;
            }
            else
            {
                [self saveUserObjectForUser:currentUser withLocation:point];
            }
        }];
    }
    
    else if([PFUser currentUser] && !self.creatingAnonymousUser)
    {
        self.creatingAnonymousUser = YES;
        [self saveUserObjectForUser:[PFUser currentUser] withLocation:point];
    }
}

- (void)saveUserObjectForUser:(PFUser *)currentUser withLocation:(PFGeoPoint *)point
{
    // add reach for cloud code execution
    currentUser[@"reach"] = [NSNumber numberWithInt:7];
    currentUser[@"highestPropagated"] = [NSNumber numberWithInt:0];
    currentUser[@"notificationsToday"] = [NSNumber numberWithInt:0];
    currentUser[@"reachLevel"] = @"Sea Serpent";
    currentUser[@"score"] = [NSNumber numberWithInt:0];
    currentUser[@"followingNumber"] = [NSNumber numberWithInt:0];
    [[PFUser currentUser] setObject:point forKey:@"location"];

    NSArray *followingArray = [NSArray arrayWithObject:@"qqyvLOFvNT"];
    [[PFUser currentUser] setObject:followingArray forKey:@"following"];

    
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (self.getLocationOnce)
        {
            NSLog(@"just finished getting location first time");
            self.getLocationOnce = NO;
            
            // call method to create ripples with block to reload
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self getNearestRipplesOnLoad];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"finished getNearestRipplesOnFirstLoad");
                    self.isFirstRun = NO;
                    [self updateView];
                    [self.activityIndicator stopAnimating];
                    [self.activityIndicator setHidden:NO];
                });
            });
        }
    }];
    
    // Associate the device with a user
    PFInstallation *installation = [PFInstallation currentInstallation];
    if (installation[@"user"] != currentUser)
    {
        installation[@"user"] = currentUser;
        [installation saveInBackground];
        
    }
    
    NSLog(@"just finished saving currentuser and installation");
    // [self updateView];
}


- (void)getNearestRipplesOnLoad
{
    [PFCloud callFunction:@"getNearestRipplesOnFirstLoad" withParameters:@{@"userId" : [PFUser currentUser].objectId, @"userLocation": (PFGeoPoint *)[PFUser currentUser][@"location"]}];
    
    NSLog(@"location is %@", [PFUser currentUser][@"location"]);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
        [self presentNeedsLocation];
    NSLog(@"error: %@", error.description);
}

- (void)presentNeedsLocation
{
    // disable buttons
    self.rippleSegmentControl.userInteractionEnabled = NO;
    [self.rippleSegmentControl setAlpha:0.5];
    self.rippleSegmentControl.enabled = NO;
    [self.activityIndicator stopAnimating];
    [self.tableView setAlpha:0.1];
    
    
    
    // show text box with  message to enable
    self.noRipplesTextView.text = @"Bellow needs location to share ripples with people nearby. In your phone settings, tap on Bellow and allow location services";
    [self.noRipplesTextView setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:26.0]];
    self.noTextTopConstraint.constant = 40;
    [self.noRipplesTextView setHidden:NO];
    [self.tableView setHidden:YES];
    [self.view updateConstraints];
    
    return;
}

#pragma mark - initial page setup and housekeeping
- (void)pageSetup
{
    // setup navigation title
    UIView *titleView = [[UIView alloc] initWithFrame: CGRectMake(-10,40,[UIScreen mainScreen].bounds.size.width - 100, 44)];
    
    self.rippleSegmentControl  = [[UISegmentedControl alloc] initWithItems:@[@"All",@"Following"]];
    [self.rippleSegmentControl setFrame:CGRectMake(titleView.center.x - 75, 5, 150, 34)];
    [self.rippleSegmentControl setTintColor:[UIColor whiteColor]];
    [self.rippleSegmentControl setSelectedSegmentIndex:0];
    [self.rippleSegmentControl addTarget:self action:@selector(segmentChanged) forControlEvents:UIControlEventValueChanged];
    [self.navigationItem.titleView setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2, self.navigationController.navigationBar.frame.size.height/2)];
    [titleView addSubview:self.rippleSegmentControl];
    self.navigationItem.titleView = titleView;
    
    
    /*
    // setup navigation title
    UIView *titleView = [[UIView alloc] initWithFrame: CGRectMake(0,40,200, 44)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleView.frame.size.width/2 - 110,0,220, 44)];
    
    [titleLabel setFont:[UIFont fontWithName:@"Avenir" size:22.0]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    
    titleLabel.text = @"Home";
    
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleView addSubview:titleLabel];
    self.navigationItem.titleView = titleView;
    [self.navigationItem.titleView setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2, self.navigationController.navigationBar.frame.size.height/2)];
    */
    // setup items for the table
    [self.tableView setTableHeaderView:nil];
    
    // set text and height of no text view box
    self.noRipplesTextView.textColor = [UIColor darkGrayColor];
    self.noRipplesTextView.textAlignment = NSTextAlignmentCenter;
    
    //set up table items
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // set up table refreshing
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshList) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
    
    // footer refreshing
    self.indicatorFooter = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    [self.indicatorFooter setColor:[UIColor grayColor]];
    [self.tableView setTableFooterView:self.indicatorFooter];
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [self.tableView setPreservesSuperviewLayoutMargins:NO];
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    else
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    
    //set text for no pending ripples
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    
    if ([userData objectForKey:@"defaultNoPendingRipplesString"] != nil)
        self.defaultNoPendingRippleString = [NSString stringWithString:[userData objectForKey:@"defaultNoPendingRipplesString"]];
    else
        self.defaultNoPendingRippleString = @"No pending ripples";
    
    [self.noRipplesTextView setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:32.0]];
    
    // update constraints
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
    
    //set notifications badge number on load
    [self addNotificationsBadge];
}

- (void)ChangeColorOfSegment:(UISegmentedControl *)segmentControl
{
    /*
    [self.rippleSegmentControl setImage:[ImageCropping imageWithImage:[UIImage imageNamed:@"unselectedFeed.png"] scaledToSize:CGSizeMake(self.rippleSegmentControl.frame.size.height, self.rippleSegmentControl.frame.size.height) withColor:[UIColor colorWithWhite:1.0 alpha:0.45]] forSegmentAtIndex:0];
    [self.rippleSegmentControl setImage:[ImageCropping imageWithImage:[UIImage imageNamed:@"unselectedTrending.png"] scaledToSize:CGSizeMake(self.rippleSegmentControl.frame.size.height, self.rippleSegmentControl.frame.size.height) withColor:[UIColor colorWithWhite:1.0 alpha:0.45]] forSegmentAtIndex:1];
    
    
    
    if (self.rippleSegmentControl.selectedSegmentIndex == 0)
        
        [self.rippleSegmentControl setImage:[ImageCropping imageWithImage:[UIImage imageNamed:@"unselectedTrending.png"] scaledToSize:CGSizeMake(self.rippleSegmentControl.frame.size.height, self.rippleSegmentControl.frame.size.height) withColor:[UIColor colorWithWhite:1.0 alpha:1.0]]  forSegmentAtIndex:1];
    
    
    [self.rippleSegmentControl.layer setZPosition:10.0];
    [self.tableView.layer setZPosition:1.0];
    [self.view setNeedsLayout];
     
    */
}

- (void)refreshList
{
    // call service and update table
    [self.refreshControl endRefreshing];
    
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
        [self presentNeedsLocation];
    
    else
    {
        self.rippleSegmentControl.userInteractionEnabled = YES;
        [self.rippleSegmentControl setAlpha:1.0];
        [self.noRipplesTextView setHidden:YES];
        [self.tableView setHidden:NO];
        self.rippleSegmentControl.enabled = YES;
        [self.tableView setAlpha:1.0];
    
    
        if ([self.selectedRippleArray count] == 0)
        {
            self.continueRippleMapAnimation = YES;
        }
        
        [self updateView];
    }
}

- (void)addNotificationsBadge
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int badgeNumber = [BellowService getNotificationBadgeNumber];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            UITabBarItem *tbi = (UITabBarItem *) [self.tabBarController.tabBar.items objectAtIndex:3];
            if (badgeNumber != 0)
            {
                tbi.badgeValue = [NSString stringWithFormat:@"%d",badgeNumber];
            }
        });
    });
}

- (void) didPressReachBarButton
{
    UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PointsViewController *pvc =[mainstoryboard instantiateViewControllerWithIdentifier:@"PointsViewController"];
    pvc.points = [self.barBtn.titleLabel.text intValue];
    [self presentViewController:pvc animated:YES completion:nil];
}

- (void) setNoRipplesText
{
    if (self.rippleSegmentControl.selectedSegmentIndex == 0)
        self.noRipplesTextView.text = self.defaultNoPendingRippleString;
    
    else if (self.rippleSegmentControl.selectedSegmentIndex == 1)
        self.noRipplesTextView.text = @"You have no new following ripples. Swipe down to refresh";
    
    else if (self.rippleSegmentControl.selectedSegmentIndex == 2)
        self.noRipplesTextView.text = @"You have no new trending ripples. Swipe down to refresh";
    
    [self.noRipplesTextView setHidden:NO];
}

#pragma mark - share and action items from profile view
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"Share Bellow"])
    {
        if (buttonIndex == 1)
        {
            UIActivityViewController *shareController = [ShareRippleSheet shareRippleSheet:nil];
            
            [self presentViewController:shareController animated:YES completion:nil];
        }
    }
    
    if ([alertView.title isEqualToString:@"Review Bellow"])
    {
        if (buttonIndex == 1)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"itms-apps://itunes.apple.com/app/" stringByAppendingString: @"id946792245"]]];
            
            [Flurry logEvent:@"Review_Clicked"];
        }
    }
    
    if ([alertView.title isEqualToString:@"Congratulations"])
    {
        //    TODO: point to new view controller
    }
    
    if ([alertView.title isEqualToString:@"Uh Oh!"])
    {
        if (buttonIndex == 1)
        {
            // Present More Info Controller
            UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            StaticProfileTableTableViewController *sptvc =[mainstoryboard instantiateViewControllerWithIdentifier:@"StaticProfileTableTableViewController"];
            [self.navigationController pushViewController:sptvc animated:YES];
        }
    }
    
    if ([alertView.title isEqualToString:@"Woohoo!"] || [alertView.title isEqualToString:@"Invite friends!"])
    {
        if (buttonIndex == 1)
        {
            
            UIActivityViewController *shareController = [ShareRippleSheet shareRippleSheet:nil];
            [self presentViewController:shareController animated:YES completion:nil];

        }
    }
    
    
    if ([alertView.title isEqualToString:@"You've Leveled Up"])
    {
        
        if (buttonIndex == 1)
        {
            UIActivityViewController *shareController = [ShareRippleSheet shareRippleSheet:[NSString stringWithFormat:@"I'm now a %@ on Bellow. Check it out! http://getRipple.io @RippleMeThis", [PFUser currentUser][@"reachLevel"]]];
            
            [self presentViewController:shareController animated:YES completion:nil];
            
        }
    }
}

- (void)checkIfShare
{
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    
    NSNumber *runNumber = [userData objectForKey:@"runNumber"];
    int runNumberInt = [runNumber intValue];
    
    // if we recently updated, return
    if (runNumberInt == 4)
    {
        [userData setObject:[NSNumber numberWithInt:5] forKey:@"runNumber"];
        
        [userData synchronize];
        
        UIAlertView *shareRipple = [[UIAlertView alloc] initWithTitle:@"Share Bellow" message:@"Bellow is better with friends! Get them on Bellow and gain 200 points!" delegate:self cancelButtonTitle:@"Not now" otherButtonTitles:@"Share", nil];
        
        [shareRipple show];
    }
    else
    {
        [userData setObject:[NSNumber numberWithInt:(runNumberInt + 1)] forKey:@"runNumber"];
        [userData synchronize];
    }
}

- (void)updateBadgeNumber
{
    // set to zero
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}


#pragma mark - navigate here upon new ripple creation
// New ripple was created. Add it to the "started" list
- (void)notifyNewRipple:(NSNotification *)notification {
    
    [self.tabBarController setSelectedIndex:4];

    
    
    /*// determine if this was first ripple user sent
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    
    NSNumber *sentFirstRipple = [userData objectForKey:@"sentFirstRipple"];
    int sentFirstRippleCheck = [sentFirstRipple intValue];
    
    // if we recently updated, return
    if ([PFUser currentUser][@"score"] <[NSNumber numberWithInt:3] && sentFirstRippleCheck != 2)
    {
        //increment point
        [[PFUser currentUser] incrementKey:@"score"];
        [[PFUser currentUser] saveInBackground];
        
        
        // show alert saying you got a point, and take to user page
        UIAlertView *sentFirstRipple = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:@"You just sent a ripple. Here's a point! Read more about points here" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [sentFirstRipple show];
        
         [userData setObject:[NSNumber numberWithInteger:2] forKey:@"sentFirstRipple"];
         [userData synchronize];
    }
    
    // if 15 ripples, ask for  a review
    if (sentFirstRippleCheck == 3)
    {
        UIAlertView *reviewRipple = [[UIAlertView alloc] initWithTitle:@"Review Bellow" message:@"Enjoying Bellow? Rate and review us!" delegate:self cancelButtonTitle:@"Not now" otherButtonTitles:@"Rate or review", nil];
        
        [Flurry logEvent:@"Ask_For_Review"];
        
        [reviewRipple show];
    }*/
    
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


#pragma mark- scroll delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
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