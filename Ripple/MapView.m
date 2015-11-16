//
//  RippleMapView.m
//  Bellow
//
//  Created by Gal Oshri on 10/9/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import "MapView.h"
#import "MiniBellow.h"
#import "BellowService.h"
#import "Comment.h"
#import "CommentTableViewCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "BellowService.h"
#import "RippleLogInView.h"
#import "RippleSignUpView.h"
#import "ImageViewerViewController.h"
#import "WebViewViewController.h"
#import "ProfilePageViewController.h"
#import "OtherUserProfileViewController.h"
#import "HomePage.h"
#import "Flurry.h"

@interface MapView ()

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *mapOverlayView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *postCommentButton;
@property (weak, nonatomic) IBOutlet UIView *postCommentView;
@property (weak, nonatomic) IBOutlet UITextView*postCommentTextField;
@property (weak, nonatomic) IBOutlet UITextView *rippleTextView;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UIButton *rippleUsername;
@property (weak, nonatomic) IBOutlet UILabel *rippleDate;
@property (weak, nonatomic) IBOutlet UIView *topTableViewHeader;
@property (weak, nonatomic) IBOutlet UILabel *spreadLabel;
@property (weak, nonatomic) IBOutlet UIView *outerImageFile;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *outerImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *moreInfoComments;
@property (weak, nonatomic) IBOutlet UIImageView *commentsImage;
@property (weak, nonatomic) IBOutlet UIView *spreadCommentView;
@property (weak, nonatomic) IBOutlet UIButton *reportDeleteButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageWidthConstraint;
@property (weak, nonatomic) IBOutlet PFImageView *imageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapOverlayTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapOverlayHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rippleTextHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postCommentViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rippleTextTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rippleImageTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postCommentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spreadCommenTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rippleNameWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightSpreadCommentViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftSpreadCommentViewConStraint;

@property (strong, nonatomic) NSArray *miniRipples;
@property (strong, nonatomic) NSMutableArray *commentArray;
@property (strong, nonatomic) NSMutableArray *overlays;
@property (strong, nonatomic) NSMutableArray *lineOverlays;
@property (strong, nonatomic) TTTTimeIntervalFormatter *timeIntervalFormatter;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) UIButton *pathButton;
@property BOOL keyboardOrNah;
@property BOOL commentsShowingOrNah;
@property (nonatomic, assign) CGFloat contentOffset;
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizerMap;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeCommentViewDown;
@property (strong, nonatomic) UILongPressGestureRecognizer *swipeMapViewFirstTime;
@property (strong, nonatomic) UITapGestureRecognizer *tapImageRecognizer;
@property (strong, nonatomic) NSURL *url;
@property (nonatomic) float originalPostCommentViewHeight;
@property (strong, nonatomic) NSString *placeholderText;

@property (strong, nonatomic) IBOutlet UIButton *propagateButton;
@property (strong, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UILabel *alreadyActedLabel;
@property (weak, nonatomic) IBOutlet UIButton *alreadyActedButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *propagateButtonRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dismissButtonLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cityLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *spreadText;
@property (strong,nonatomic) UIView *overlay;
@property (nonatomic) BOOL isOverlayTutorial;


@property (nonatomic) BOOL viewDidLoadJustRan;
@property (nonatomic) BOOL didPressMapOverlayOnce;
@property (nonatomic) BOOL pathsShowingOrNah;
@property (nonatomic) int maxDepth;


// @property (strong, nonatomic) UITapGestureRecognizer *tapMapOverlayOnce;
// @property (weak, nonatomic) IBOutlet NSLayoutConstraint *rippleUsernameBottomConstraint;
// @property (weak, nonatomic) IBOutlet NSLayoutConstraint *rippleDateBottomConstraint;
// @property (weak, nonatomic) IBOutlet NSLayoutConstraint *cityLabelBottomConstraint;
// @property (weak, nonatomic) IBOutlet UIView *shadowViewForMapOverlay;
// @property (weak, nonatomic) IBOutlet UILabel *noCommentsLabel;
// @property (weak, nonatomic) IBOutlet UIView *tableViewUnderLay;
// @property (weak, nonatomic) IBOutlet UIButton *propagateButton;
// @property (weak, nonatomic) IBOutlet UIView *topHeaderUnderlayView;
// @property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewUnderlayHeightConstraint;
// @property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeaderUnderlayTopConstraint;
// @property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeaderUnderlayHeightConstraint;
// @property (weak, nonatomic) IBOutlet NSLayoutConstraint *noCommentsLabelTopConstraint;
// @property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewUnderlayTopConstraint;

@end

#define MERCATOR_RADIUS 85445659.44705395
#define ARC4RANDOM_MAX      0x100000000

@implementation MapView

- (void)goToUserProfile:(Comment *)comment
{
    if ([comment.creatorId isEqualToString:[PFUser currentUser].objectId])
        [self.tabBarController setSelectedIndex:1];
    
    else
        [self performSegueWithIdentifier:@"UserProfile" sender:comment.creatorId];
}

- (IBAction)unwindToRippleMapView:(UIStoryboardSegue *)segue
{
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
     if ([segue.identifier isEqualToString:@"ImageSegue"])
     {
         [Flurry logEvent:@"Image_Open_MapView"];
         [PFAnalytics trackEvent:@"SegueToImage" dimensions:nil];
         ImageViewerViewController *ivc = (ImageViewerViewController *)segue.destinationViewController;
         ivc.rippleImageFile = self.ripple.imageFile;
         ivc.imageHeight = self.ripple.imageHeight;
         ivc.imageWidth = self.ripple.imageWidth;
     }
    
    if ([segue.identifier isEqualToString:@"WebViewSegue"])
    {
        [Flurry logEvent:@"Web_Open_MapView"];
        [PFAnalytics trackEvent:@"SegueToWebView" dimensions:nil];
        WebViewViewController *wvc = (WebViewViewController *)segue.destinationViewController;
        wvc.url = self.url;
    }

    if ([segue.identifier isEqualToString:@"UserProfile"])
    {
        if ([sender isKindOfClass:[NSString class]])
        {
            NSString *userId = sender;
            OtherUserProfileViewController *oupv = (OtherUserProfileViewController *)segue.destinationViewController;
             self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
            oupv.userId = userId;
        }

    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.maxDepth = 1;
    [self.navigationController.navigationBar setHidden:NO];
    
    
    //  set up map
    self.overlays = [[NSMutableArray alloc] init];
    self.lineOverlays = [[NSMutableArray alloc] init];
    
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeStandard;
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    
    // setup right bar button to toggle path
    self.pathButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 15, 30)];
    [self.pathButton setImage:[UIImage imageNamed:@"noPath.png"] forState:UIControlStateNormal];
    [self.pathButton addTarget:self action:@selector(didPressPathButton) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:self.pathButton];
    self.navigationItem.rightBarButtonItem = barButton;
    
    
    // set up table
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.originalPostCommentViewHeight = self.postCommentViewHeightConstraint.constant;
    
    if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        self.tableViewBottomConstraint.constant = self.postCommentView.frame.size.height + self.originalPostCommentViewHeight + 3;
    else
        self.tableViewBottomConstraint.constant = self.postCommentView.frame.size.height + self.originalPostCommentViewHeight + self.tabBarController.tabBar.frame.size.height + 3;
        
    
    // comment text field
    self.placeholderText = @"Add a comment";
    [self.postCommentTextField setText:self.placeholderText];
    [self.postCommentTextField setTextColor:[UIColor darkGrayColor]];

    self.miniRipples = [[NSArray alloc] init];
    self.commentArray = [[NSMutableArray alloc] init];
    
    // get miniripples to display location circles
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.miniRipples = [BellowService getMiniRipplesGraph:self.ripple.rippleId];

        dispatch_async( dispatch_get_main_queue(), ^{
            [self addMiniRipplePaths];
            [self addMiniRipplePins];
            
        });
    });
    
    [self checkFirstTimeMap];
    [self grabComments];
    
    // navigation bar items, constraints
    [self setupPage];
    [self setConstraintsForMapOverlay];
    [self addGestureTargets];
    
    
    self.outerImageFile.backgroundColor = [UIColor clearColor];
    [self.propagateButton.layer setZPosition:0.0];
    [self.dismissButton.layer setZPosition:0.0];
    
    // set bools to false
    self.commentsShowingOrNah = NO;
    self.pathsShowingOrNah = NO;
    
    // set maptoggle
    if (!self.commentsUp || self.isOverlayTutorial)
    {
        self.commentsUp = NO;
        [self showHideMapToggle:self];
        self.didPressMapOverlayOnce = NO;
    }

    [PFAnalytics trackEvent:@"MapViewLoaded" dimensions:nil];
    [Flurry logEvent:@"View_Map"];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // do work to move 'legal' in map view.
    UILabel *attributionLabel = [self.mapView.subviews objectAtIndex:1];
    attributionLabel.frame = CGRectMake(5, 5, attributionLabel.frame.size.width, attributionLabel.frame.size.height);
    
    if (!self.viewDidLoadJustRan)
    {
        self.viewDidLoadJustRan = YES;
        [self setupImageConstraints];
        
        // check if first dismiss
        NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
        NSNumber *firstMapVisit = [userData objectForKey:@"visitFirstMap"];
        int firstMapVisitCheck = [firstMapVisit intValue];
        
        // if we recently updated, return
        if (firstMapVisitCheck == 5)
        {
            // setup alert
            UIAlertView *pathsToggleAlert = [[UIAlertView alloc] initWithTitle:@"See a ripple's path!" message:@"Tap the button on the top right to show/hide path lines." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [pathsToggleAlert show];
            
            [userData setObject:[NSNumber numberWithInteger: firstMapVisitCheck + 1] forKey:@"visitFirstMap"];
            [userData synchronize];
        }
        else if (firstMapVisitCheck < 5)
        {
            // increment
            [userData setObject:[NSNumber numberWithInteger: firstMapVisitCheck + 1] forKey:@"visitFirstMap"];
            [userData synchronize];
        }
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    
    // set shade on tableView and colors
    self.mapOverlayView.layer.shadowOffset = CGSizeMake(0,0);
    self.mapOverlayView.layer.shadowRadius = 5;
    self.mapOverlayView.layer.shadowOpacity = .25;
    self.mapOverlayView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.mapOverlayView.bounds].CGPath;
    
    if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [self hideComposeButton];
        [self.tabBarController.tabBar setHidden:YES];
        [self.navigationController setHidesBarsOnSwipe:NO];
    }
    else
    {
        [self.tabBarController.tabBar setHidden:NO];
        [self showComposeButton];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showTabBar" object:nil];
        
    }
}

- (void) hideComposeButton
{
    
    if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        for(UIView *view in self.tabBarController.view.subviews)
        {
            if ([view isKindOfClass:[UIButton class]] && view.tag ==100)
            {
                [view setHidden:YES];
            }
        }
    }
}

- (void) showComposeButton
{
    
    if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        for(UIView *view in self.tabBarController.view.subviews)
        {
            if ([view isKindOfClass:[UIButton class]] && view.tag ==100)
            {
                [view setHidden:NO];
            }
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


- (void)grabComments
{
    if ([self.ripple.rippleId isEqualToString:@"FakeRipple"])
    {
        [self.tableView reloadData];
        return;
    }
    [self.mapOverlayView setHidden:YES];
    
    // grab comments
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        self.commentArray = [BellowService getRippleComments:self.ripple];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            [self.mapOverlayView setHidden:NO];

            if ([self.commentArray count] != 0)
                [self.tableView reloadData];
            
            if (self.commentsUp && !self.isOverlayTutorial)
            {
                [self showHideMapToggle:self];
                self.didPressMapOverlayOnce = YES;
                //[self.mapOverlayView removeGestureRecognizer:self.tapMapOverlayOnce];

            }
        });
    });
}


#pragma mark map methods
- (void)addMiniRipplePins
{
    double max_lat = 0.0;
    double min_lat = 90.0;
    double max_long = -180.0;
    double min_long = 180.0;
    
    for (MiniBellow *miniRipple in self.miniRipples)
    {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(miniRipple.latitude, miniRipple.longitude);
        
        MKCircle *point = [MKCircle circleWithCenterCoordinate:coordinate radius:100];
        [self.overlays addObject:point];
    
        if (coordinate.latitude > max_lat) {max_lat = coordinate.latitude;}
        if (coordinate.latitude < min_lat) {min_lat = coordinate.latitude;}
        if (coordinate.longitude > max_long) {max_long = coordinate.longitude;}
        if (coordinate.longitude < min_long) {min_long = coordinate.longitude;}
    }
    
    // Include ground zero ripple
    if (self.ripple.latitude > max_lat) {max_lat = self.ripple.latitude;}
    if (self.ripple.latitude < min_lat) {min_lat = self.ripple.latitude;}
    if (self.ripple.longitude > max_long) {max_long = self.ripple.longitude;}
    if (self.ripple.longitude < min_long) {min_long = self.ripple.longitude;}
    
    // calculate center of map
    double center_long = (max_long + min_long) / 2;
    double center_lat = (max_lat + min_lat) / 2;
    
    // calculate deltas
    double deltaLat = fabs(max_lat - min_lat) * 1.1;
    double deltaLong = fabs(max_long - min_long) * 1.1;
    
    // set minimal delta
    if (deltaLat < 0.02) {deltaLat = 0.02;}
    if (deltaLong < 0.02) {deltaLong = 0.02;}
    
    if (deltaLat>180.0)
        deltaLat = 180.0;
    if (deltaLong>360.0)
        deltaLong = 360.0;
    
    // add overlay to self.overlays
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.ripple.latitude, self.ripple.longitude);
    
    MKCircle *point = [MKCircle circleWithCenterCoordinate:coordinate radius:100];
    [self.overlays insertObject:point atIndex:0];
    
    //create new region and set map

    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(center_lat, center_long);
    MKCoordinateSpan span = MKCoordinateSpanMake(deltaLat, deltaLong);
    MKCoordinateRegion region = MKCoordinateRegionMake(coord, span);
    [self.mapView setRegion:region animated:YES];
}

- (void)addMiniRipplePaths
{
    // BFS on all the mini ripples
    NSMutableSet *frontier = [[NSMutableSet alloc] init];
    
    
    // find all first wave miniripples
    for (MiniBellow *miniRipple in self.miniRipples)
    {
        if (miniRipple.isFirstWave)
        {
            [frontier addObject:miniRipple];
            miniRipple.depth = 1;
            [self drawLineRippleToMiniRipple:self.ripple to:miniRipple];
        }
    }
    
    while ([frontier count] > 0)
    {
        MiniBellow *current = [frontier anyObject];
        for (NSString *nextId in current.children)
        {
            for (MiniBellow *next in self.miniRipples)
            {
                if ([nextId isEqualToString:next.miniRippleId])
                {
                    [frontier addObject:next];
                    next.depth = current.depth + 1;
                    if (next.depth > self.maxDepth)
                        self.maxDepth = next.depth;
                    [self drawLineBetweenMiniRipples:current to:next];
                    break;
                }
            }
            
            
        }   
        [frontier removeObject:current];
    }
}

- (void)drawLineRippleToMiniRipple:(Bellow *)ripple to:(MiniBellow *)miniRipple
{
    CLLocationCoordinate2D pointA = CLLocationCoordinate2DMake(ripple.latitude, ripple.longitude);
    CLLocationCoordinate2D pointB = CLLocationCoordinate2DMake(miniRipple.latitude, miniRipple.longitude);
    CLLocationCoordinate2D array[2];
    array[0] = pointA;
    array[1] = pointB;
    
    MKPolyline *line = [MKPolyline polylineWithCoordinates:array count:2];
    line.title = @"line";
    line.subtitle = [NSString stringWithFormat:@"%d", miniRipple.depth];
    [self.lineOverlays addObject:line];
}

- (void)drawLineBetweenMiniRipples:(MiniBellow *)miniRippleA to:(MiniBellow *)miniRippleB
{
    CLLocationCoordinate2D pointA = CLLocationCoordinate2DMake(miniRippleA.latitude, miniRippleA.longitude);
    CLLocationCoordinate2D pointB = CLLocationCoordinate2DMake(miniRippleB.latitude, miniRippleB.longitude);
    CLLocationCoordinate2D array[2];
    array[0] = pointA;
    array[1] = pointB;

    MKPolyline *line = [MKPolyline polylineWithCoordinates:array count:2];
    line.title = @"line";
    line.subtitle = [NSString stringWithFormat:@"%d", miniRippleB.depth];
    [self.lineOverlays addObject:line];
}



- (void)drawOverlays
{
    double zoomLevel = [self zoomLevel];
    
    if (self.pathsShowingOrNah)
    {
        // SOMETHING HERE FOR POLYLINE
        for (int i = (int)[self.lineOverlays count] - 1; i >= 0; i--)
        {
            MKPolyline *line = self.lineOverlays[i];
            [self.mapView addOverlay:line];
        }
    }
    
    // add circles based on new zoom level, and remove the old ones
    for (int i = (int)[self.overlays count] - 1; i >= 0; i--)
    {
        // resize and add accordingly
        float newRadius;
        
        // configure size of circles
        if (zoomLevel > 12)
            newRadius = 800;
    /*
        else if (zoomLevel > 9)
            newRadius = powf((18.00 - zoomLevel),3);

        else if (zoomLevel > 4)
            newRadius = powf((18.00 - zoomLevel),3) * 8;*/
        
        else
            newRadius = powf((20.00 - zoomLevel),4.2);
        
        MKCircle *circle = self.overlays[i];
        MKCircle *newCircle = [MKCircle circleWithCenterCoordinate:circle.coordinate radius:newRadius];
        
        [self.mapView removeOverlay:self.overlays[i]];
        self.overlays[i] = newCircle;
        [self.mapView addOverlay:newCircle];
        
    }
}


- (void)removeLines
{
    for (int i = (int)[self.lineOverlays count] - 1; i >= 0; i--)
    {
        MKPolyline *line = self.lineOverlays[i];
        
        [self.mapView removeOverlay:line];
    }

    
}



- (MKOverlayView *)mapView:(MKMapView *)map viewForOverlay:(id <MKOverlay>)overlay
{
    MKShape *shape = (MKShape *)overlay;
    
    if ([shape.title isEqualToString:@"line"])
    {
        int depth = [shape.subtitle intValue];
        MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
        
        if (depth==1) {
            float red = 163; // 255 - 212 * ((float)depth / self.maxDepth);
            float green = 30; // 170 - 38 * ((float)depth / self.maxDepth);
            float blue = 252; // 63 + 156 * ((float)depth / self.maxDepth);
            polylineView.strokeColor = [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:0.8];
        }
        else
        {
            float red = 3; // 255 - 212 * ((float)depth / self.maxDepth);
            float green = 123; // 170 - 38 * ((float)depth / self.maxDepth);
            float blue = 255; // 63 + 156 * ((float)depth / self.maxDepth);
            polylineView.strokeColor = [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:0.8];
        }
        
        polylineView.lineWidth = 2;
        
        return polylineView;
    }
    
    MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
    //circleView.strokeColor = [UIColor blackColor];
    MKCircle *circle = (MKCircle *)overlay;

    if (circle.coordinate.latitude == self.ripple.latitude)
    {
        circleView.fillColor = [UIColor colorWithRed:163.0f/255 green:30.0f/255 blue:252.0f/255 alpha:0.95];
    }
    else
    {
        circleView.fillColor = [UIColor colorWithRed:3.0/255.0f green:123.0f/255 blue:255.0f/255 alpha:0.6];
    }
    return circleView;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self drawOverlays];
}

- (double) zoomLevel
{
    return 21.00 - log2(self.mapView.region.span.longitudeDelta * MERCATOR_RADIUS * M_PI / (180.0 * self.mapView.bounds.size.width));
}

- (void) didPressPathButton
{
    
    // flip bool, toggle lines, and change button
    if (self.pathsShowingOrNah)
    {
        self.pathsShowingOrNah = NO;
        [self removeLines];
        [self.pathButton setImage:[UIImage imageNamed:@"noPath.png"] forState:UIControlStateNormal];
    }
    else
    {
        self.pathsShowingOrNah = YES;
        [self drawOverlays];
        [self.pathButton setImage:[UIImage imageNamed:@"path.png"] forState:UIControlStateNormal];
    }
}

# pragma mark - table for comments
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.commentArray count];
}

- (CommentTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentTableViewCell" forIndexPath:indexPath];
    cell.comment = [self.commentArray objectAtIndex:indexPath.row];
    cell.delegate = self;
    
    // username
    [cell.usernameLabel setTitle:cell.comment.creatorUsername forState:UIControlStateNormal];
    
    // size rippleUsername accordingly
    CGSize stringSize = [cell.comment.creatorUsername sizeWithAttributes:[NSDictionary dictionaryWithObject:NSFontAttributeName forKey:[UIFont fontWithName:@"Avenir-Heavy" size:10]]];
    
    cell.usernameLabelWidthConstraint.constant = stringSize.width + 3;
    

    
    // set username and city
    if (cell.comment.city  != (id) [NSNull null])
    {
        [cell.cityLabel setText:cell.comment.city];
    }
    
    else
    {
        [cell.cityLabel setHidden:YES];
    }

    
    // format text box
    cell.commentText.text = cell.comment.commentText;
    cell.commentText.font = [UIFont fontWithName:@"Avenir" size:12.0];
    
    
    // format date
    NSTimeInterval timeInterval = [cell.comment.createdAt timeIntervalSinceNow];
    cell.dateLabel.text = [NSString stringWithFormat:@"%@", [self.timeIntervalFormatter stringForTimeInterval:timeInterval]];
    
    //set cell separator insets work
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        cell.separatorInset = UIEdgeInsetsZero;
        
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setPreservesSuperviewLayoutMargins: NO];
        [cell setLayoutMargins:UIEdgeInsetsZero];
        
        [self.tableView setPreservesSuperviewLayoutMargins:NO];
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    // adjust height nd width of the text box and update constraints
    cell.textHeightConstraint.constant = cell.frame.size.height - 30.0;
    cell.textWidthConstraint.constant = self.tableView.frame.size.width - 14;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell setNeedsUpdateConstraints];
    [cell layoutIfNeeded];
    
    // set delegate of text view to be this view?
    cell.commentText.delegate = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // set things
    Comment *currentComment= [self.commentArray objectAtIndex:indexPath.row];
    CGSize maximumSize = CGSizeMake(self.tableView.frame.size.width - 14, 9999);
    UIFont *myFont = [UIFont fontWithName:@"Avenir" size:13.0];
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:myFont, NSFontAttributeName,nil];
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    
    CGRect stringsize =  [currentComment.commentText boundingRectWithSize:maximumSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:context];
    
    return stringsize.size.height + 64.0;
}

# pragma mark - keyboard work and comment posts
- (void)touchEventOnView: (id) sender
{
    // remove gesture
    UITapGestureRecognizer *gestureRecognizer = sender;
    [self.view removeGestureRecognizer:gestureRecognizer];
    
    [self.view endEditing:YES];
    
    // reset logic
    self.keyboardOrNah = NO;
}

- (void)keyboardFrameDidChange:(NSNotification*)notification
{
   // self.didTapMapOverlayOnce = YES;
    self.commentsShowingOrNah = YES;
    NSDictionary* info = [notification userInfo];
    CGRect kKeyBoardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // logic for moving safe zone portion up and down based on keyboard
    if (self.keyboardOrNah)
    {
        self.postCommentViewBottomConstraint.constant = 0;
        self.mapOverlayTopConstraint.constant = 0;
        self.tableViewBottomConstraint.constant = self.postCommentView.frame.size.height + self.originalPostCommentViewHeight + 3;
        
        [UIView animateWithDuration:0.5 animations:^{
            [self.view setNeedsUpdateConstraints];
            [self.view layoutIfNeeded];
        }];
    }
    
    else
    {
        self.mapOverlayTopConstraint.constant = 0;
        
        self.tableViewBottomConstraint.constant = kKeyBoardFrame.size.height + self.postCommentView.frame.size.height + self.originalPostCommentViewHeight + 3;
        
        if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
            self.postCommentViewBottomConstraint.constant = kKeyBoardFrame.size.height;
        else
            self.postCommentViewBottomConstraint.constant = kKeyBoardFrame.size.height - self.tabBarController.tabBar.frame.size.height;
        
        //self.tableViewBottomConstraint.constant = kKeyBoardFrame.size.height + self.postCommentView.frame.size.height + 6;
        [UIView animateWithDuration:0.5 animations:^{
            [self.view updateConstraints];
            [self.view layoutIfNeeded];
        }];

        // scroll to zeh bottom yah
        if (self.ripple.numberComments > 0 && !self.mapOverlayView.isHidden)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.ripple.numberComments-1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
    
    self.keyboardOrNah = !self.keyboardOrNah;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    
    // check if user is anonymous
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]])
    {
        [self.view endEditing:YES];
        UIAlertView *signInPlease = [[UIAlertView alloc] initWithTitle:@"Sign up!" message:@"You must have an account to comment on ripples" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [self showLogInAndSignUpView];
        [signInPlease show];
    }
    
    // remove gesture recognizer of swipe comments and tap map
    [self.mapView removeGestureRecognizer:self.tapRecognizerMap];
    [self.mapOverlayView removeGestureRecognizer:self.swipeCommentViewDown];
    
    //call selector to dismiss keyboard code if it is present
    UITapGestureRecognizer *tapRecognizerTextField = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchEventOnView:)];
    [tapRecognizerTextField setNumberOfTapsRequired:1];
    [tapRecognizerTextField setDelegate:self];
    [self.view addGestureRecognizer:tapRecognizerTextField];

    // placeholder string
    if ([self.postCommentTextField.text isEqualToString:self.placeholderText])
        self.postCommentTextField.text = @"";
    self.postCommentTextField.textColor = [UIColor blackColor];

    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    // remove gesture recognizer of swipe comments and tap map
    [self.mapView addGestureRecognizer:self.tapRecognizerMap];
    [self.mapOverlayView addGestureRecognizer:self.swipeCommentViewDown];
    
    self.commentsShowingOrNah = NO;
    [self showHideMapToggle:nil];
    
    
    // placeholder text
    if ([self.postCommentTextField.text isEqualToString:@""] || [self.postCommentTextField.text isEqualToString:@" "])
    {
        self.postCommentTextField.text = self.placeholderText;
        self.postCommentTextField.textColor = [UIColor darkGrayColor];
        
    }

    [self.view updateConstraints];

    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self adjustFrames];
}

-(void) adjustFrames
{
    self.postCommentViewHeightConstraint.constant = self.postCommentTextField.contentSize.height;
    [self.view updateConstraints];
    
    //[self.postCommentTextField setScrollEnabled:NO];
    //[self.postCommentTextField setScrollEnabled:YES];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    [self.postCommentTextField resignFirstResponder];
    return YES;
}

- (IBAction)postComment:(id)sender
{
    // check that there is content to post
    if ([self.postCommentTextField.text isEqualToString:@""] || [self.postCommentTextField.text isEqualToString:@" "] || [self.postCommentTextField.text isEqualToString:@"Add a comment"])
        return;
    
    // go to ripple service
    else
    {
        [self.postCommentButton setEnabled:NO];
        
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Add code here to do background processing
            if (![self.ripple.rippleId isEqualToString:@"FakeRipple"])
                [BellowService addComment:self.postCommentTextField.text forRipple:self.ripple];
            
            dispatch_async( dispatch_get_main_queue(), ^{
                // append this to commentsArray and add to table
                Comment *newComment = [[Comment alloc] init];
                newComment.commentText = self.postCommentTextField.text;
                newComment.creatorUsername = [PFUser currentUser].username;
                if ([self.ripple.rippleId isEqualToString:@"FakeRipple"])
                    newComment.creatorUsername = @"New user";
                newComment.createdAt = [NSDate date];
                
                // add newComment to correct places
                self.ripple.numberComments = self.ripple.numberComments + 1;
                [self.commentArray addObject:newComment];
                [self.ripple.commentArray addObject:newComment];
                self.moreInfoComments.text = [NSString stringWithFormat:@"%d", self.ripple.numberComments];
                self.postCommentTextField.text = @"";

                [self.tableView reloadData];
                [self.postCommentButton setEnabled:YES];
                
                // log event
                [PFAnalytics trackEvent:@"PostedComment" dimensions:nil];
                [Flurry logEvent:@"Comment_Posted"];
            });
        });
        
        // bring back comment box to original height
        self.postCommentTextField.contentSize = CGSizeMake(self.postCommentTextField.frame.size.width, self.originalPostCommentViewHeight);
        [self adjustFrames];
        self.tableViewBottomConstraint.constant = self.postCommentView.frame.size.height + self.originalPostCommentViewHeight + 3;
        
        [self.view updateConstraints];
        [self.view layoutIfNeeded];

        // dissmiss keyboard
        [self.view endEditing:YES];
    }
}


#pragma mark - ripple action methods
- (IBAction)propagateRipple:(UIButton *)sender {
    // [self.propagateButton.layer setZPosition:0.0];
    // [self.dismissButton.layer setZPosition:1.0];
    if (self.ripple.miniRippleId != nil)
        [BellowService propagateRipple:self.ripple];
    else
        [BellowService propagateSwipeableRipple:self.ripple];
    
    self.ripple.actedUponState = 1;
    
    // log
    [PFAnalytics trackEvent:@"RipplePropagated" dimensions:@{@"feed":@"map_view"}];
    [Flurry logEvent:@"Ripple_Spread" withParameters:[NSDictionary dictionaryWithObject:@"map_view" forKey:@"feed"]];
    
    [UIView animateWithDuration:0.4 animations:^{
        /*
         self.dismissButton.frame = CGRectMake(22, 0, 40, 40);
         self.propagateButton.frame = CGRectMake(22, 0, 40, 40);
         self.dismissButtonRightConstraint.constant = 22;
         self.propagateButtonLeftConstraint.constant = 22;
         */
    }completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.3 animations:^{
            // NOOP
        }completion:^(BOOL finished) {
            // notifications to home page, explore page, and user profile page
            [[NSNotificationCenter defaultCenter] postNotificationName:@"swipedRippleUpdateUserProfile" object:self.ripple];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"swipedRipple" object:self.ripple];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"incrementScore" object:nil];
            
            // dismiss view
            [self.navigationController popViewControllerAnimated:YES];
            
        }];
    }];
}

- (IBAction)dismissRipple:(UIButton *)sender {
    // [self.propagateButton.layer setZPosition:2.0];
    // [self.dismissButton.layer setZPosition:0.0];
    
    if (self.ripple.miniRippleId != nil)
        [BellowService dismissRipple:self.ripple];
    else
        [BellowService dismissSwipeableRipple:self.ripple];

    self.ripple.actedUponState = 2;
    
    [PFAnalytics trackEvent:@"RippleDismissed" dimensions:@{@"feed":@"map_view"}];
    [Flurry logEvent:@"Ripple_Dismissed" withParameters:[NSDictionary dictionaryWithObject:@"map_view" forKey:@"feed"]];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        /*
         self.dismissButton.frame = CGRectMake(22, 0, 40, 40);
        self.propagateButton.frame = CGRectMake(22, 0, 40, 40);
        self.dismissButtonRightConstraint.constant = 22;
        self.propagateButtonLeftConstraint.constant = 22;
         */
        
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"swipedRippleUpdateUserProfile" object:self.ripple]; 
            [[NSNotificationCenter defaultCenter] postNotificationName:@"swipedRipple" object:self.ripple];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"incrementScore" object:nil];
            
            // dismiss view
            [self.navigationController popViewControllerAnimated:YES];

        }];
    }];
}

- (IBAction)deleteRipple:(UIButton *)sender {
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [BellowService deleteRipple:self.ripple];
    });
    
    ProfilePageViewController *ppvc = (ProfilePageViewController *)[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    
    [self.navigationController popViewControllerAnimated:YES];
    [ppvc rippleDeleted:self.ripple];
}

- (void)goToScrollView:(id)sender
{
    [self performSegueWithIdentifier:@"ImageSegue" sender:self];
}

- (IBAction)didPressUsername:(id)sender {
    if (self.commentsShowingOrNah)
    {
        if ([self.ripple.creatorId isEqualToString:[PFUser currentUser].objectId])
            [self.tabBarController setSelectedIndex:1];
        
        else
            [self performSegueWithIdentifier:@"UserProfile" sender:self.ripple.creatorId];
    }
    else
        [self showHideMapToggle:sender];
}

- (IBAction)didPressAlreadyActedButton:(id)sender {
    if (self.ripple.actedUponState == 1)
    {
        [self.alreadyActedLabel setText:@"You already spread this ripple"];
        [self.alreadyActedLabel setTextColor:[UIColor colorWithRed:3.0/255.0f green:123.0f/255 blue:255.0f/255 alpha:1.0]];
    }
    
    else if(self.ripple.actedUponState == 2)
    {
        [self.alreadyActedLabel setText:@"You already dismissed this ripple"];
        [self.alreadyActedLabel setTextColor:[UIColor colorWithRed:3.0/255.0f green:123.0f/255 blue:255.0f/255 alpha:1.0]];
    }

    [self.alreadyActedLabel setHidden:NO];
    [self.alreadyActedLabel setAlpha:0.0];
    [self.alreadyActedButton setAlpha:0.0];
    [self.alreadyActedLabel setHidden:NO];
    [self.spreadLabel setHidden:YES];
    [self.spreadText setHidden:YES];
    [self.commentsImage setHidden:YES];
    [self.moreInfoComments setHidden:YES];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.alreadyActedLabel setAlpha:1.0];
    }completion:^(BOOL finished) {
        [NSThread sleepForTimeInterval:1.0f];
        [UIView animateWithDuration:0.3 animations:^{
            [self.alreadyActedLabel setAlpha:0.0];
        }completion:^(BOOL finished) {
            [self.alreadyActedLabel setHidden:YES];
            [self.alreadyActedLabel setAlpha:1.0];
            [self.alreadyActedButton setAlpha:1.0];
            [self.spreadLabel setHidden:NO];
            [self.spreadText setHidden:NO];
            [self.commentsImage setHidden:NO];
            [self.moreInfoComments setHidden:NO];
        }];
    }];

}


- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    // save URL and perform segue
    self.url = URL;
    
    [self performSegueWithIdentifier:@"WebViewSegue" sender:nil];
    
    return NO;
    
}


# pragma mark scroll methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // move commentUnderlay accordingly
    /*
    CGFloat difference = scrollView.contentOffset.y - self.lastContentOffset;
    // self.topHeaderUnderlayTopConstraint.constant = self.topHeaderUnderlayTopConstraint.constant - difference;
    
     if (!self.noCommentsLabel.isHidden)
        self.noCommentsLabelTopConstraint.constant = self.noCommentsLabelTopConstraint.constant - difference;
    */
    self.contentOffset = scrollView.contentOffset.y;
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


# pragma mark - flag and delete sheets.
- (IBAction)moreOptionsSheet:(id)sender
{
    UIActionSheet *moreOptions;
    // create aciton sheet
    if ([self.ripple.creatorId isEqualToString:[PFUser currentUser].objectId])
        moreOptions = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Delete this ripple", nil];
    else
        moreOptions = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Report Content", nil];

    [moreOptions showInView:self.view];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([self.ripple.creatorId isEqualToString:[PFUser currentUser].objectId])
    {
        // delete Bellow
        if(buttonIndex == 0)
            [self deleteRipple:nil];
    }
    
    // only one option
    else
    {
       if(buttonIndex == 0)
           [self reportContent:nil];
    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"Report this ripple?"])
    {
        if (buttonIndex == 1)
        {
            // flag this ripple
            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [BellowService flagRipple:self.ripple.rippleId];
            });
        }
    }
}

- (IBAction)reportContent: (id)sender
{
    UIAlertView *flagContent = [[UIAlertView alloc] initWithTitle:@"Report this ripple?" message:@"If reported, this ripple will be reviewed and removed if found inappropriate. Users who repeatedly post reported content will be blocked." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Report", nil];
    
    [flagContent show];
}

- (IBAction)shareSheet:(id)sender
{
    UIActivityViewController *shareController;
    

    // there is an image and text

    
    NSString *shareText = [NSString stringWithFormat:@"%@ - Shared on Bellow by %@; http://www.getripple.io/ripple.html?id=%@", self.ripple.text,self.ripple.creatorName, self.ripple.rippleId];
    
    if (self.ripple.imageFile)
    {
        UIImage *shareImage = self.imageView.image;
        shareController = [[UIActivityViewController alloc] initWithActivityItems:@[shareText, shareImage] applicationActivities:nil];
    }
    
    else
         shareController = [[UIActivityViewController alloc] initWithActivityItems:@[shareText] applicationActivities:nil];
    
        
    [shareController setCompletionHandler:^(NSString *activityType, BOOL completed) {
        NSLog(@"completed dialog - activity: %@ - finished flag: %d", activityType, completed);
        
        if (completed)
        {
            [PFAnalytics trackEvent:@"SuccessfullyShared" dimensions:@{@"ActivityType" : activityType}];
            [Flurry logEvent:@"Ripple_Shared"];
        }
        else
            [PFAnalytics trackEvent:@"FailedShare" dimensions:nil];
    }];
    
     [self presentViewController:shareController animated:YES completion:nil];
}

# pragma mark - signin and login
- (void)showLogInAndSignUpView
{
    // Create the sign up view controller
    RippleSignUpView *signUpViewController = [[RippleSignUpView alloc] init];
    [signUpViewController setDelegate:self]; // Set ourselves as the delegate
    
    // Present the log in view controller
    [self presentViewController:signUpViewController animated:YES completion:NULL];
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    // Associate the device with a user
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation[@"user"] = [PFUser currentUser];
    [installation saveInBackground];
    
    [self.navigationController popViewControllerAnimated:YES];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
    NSLog(@"%@", error);
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [user setObject:[user.username lowercaseString] forKey:@"canonicalUsername"];
    
    NSArray *followingArray = [NSArray arrayWithObject:@"qqyvLOFvNT"];
    [[PFUser currentUser] setObject:followingArray forKey:@"following"];
    
    [user saveInBackground];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - setup methods
- (void) setupPage
{
    // setup navigation title
    UIView *titleView = [[UIView alloc] initWithFrame: CGRectMake(0,40,[UIScreen mainScreen].bounds.size.width - 100, 44)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleView.frame.size.width/2 - 110,0,220, 44)];
    [titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:22.0]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    
    // set titleView
    if (self.ripple.numberPropagated == -1)
    {
        [titleLabel setText:[NSString stringWithFormat:@"spread 0 times"]];
        self.spreadLabel.text = [NSString stringWithFormat:@"0x"];
    }
    else if (self.ripple.numberPropagated != 1)
    {
        [titleLabel setText:[NSString stringWithFormat:@"Spread %d times", self.ripple.numberPropagated]];
        self.spreadLabel.text = [NSString stringWithFormat:@"%dx", self.ripple.numberPropagated];
    }
    else
    {
        [titleLabel setText:[NSString stringWithFormat:@"Spread %d time", self.ripple.numberPropagated]];
        self.spreadLabel.text = [NSString stringWithFormat:@"%dx", self.ripple.numberPropagated];
    }
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleView addSubview:titleLabel];
    self.navigationItem.titleView = titleView;
    [self.navigationItem.titleView setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2, self.navigationController.navigationBar.frame.size.height/2)];
    
    
    //set labels accordingly
    self.rippleTextView.text = self.ripple.text;
    self.rippleTextView.delegate = self;
    [self.rippleUsername setTitle:self.ripple.creatorName forState:UIControlStateNormal];
    
    NSTimeInterval timeInterval = [self.ripple.createdAt timeIntervalSinceNow];
    if (self.ripple.city)
    {
        // set city label hidden
        if (!self.isOverlayTutorial)
            [self.cityLabel setHidden:NO];
        
        self.cityLabel.text = self.ripple.city;
        
        self.rippleDate.text = [NSString stringWithFormat:@"%@", [self.timeIntervalFormatter stringForTimeInterval:timeInterval]];
        
        if (!self.isOverlayTutorial)
            [self.rippleDate setHidden:NO];
    }
    else
    {
        self.cityLabel.text = [NSString stringWithFormat:@"%@", [self.timeIntervalFormatter stringForTimeInterval:timeInterval]];
        [self.rippleDate setHidden:YES];
    }
    
    self.moreInfoComments.text = [NSString stringWithFormat:@"%d", self.ripple.numberComments];
    
    // set responder for keyboard and bool for safe zones
    self.keyboardOrNah = NO;
    self.postCommentTextField.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardFrameDidChange:)
                                                 name:UIKeyboardWillChangeFrameNotification object:nil];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.mapOverlayView.clipsToBounds = NO;
    self.mapOverlayView.layer.masksToBounds = NO;
    [self.tableView setSeparatorColor:[UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1.0]];
    [self.postCommentView setHidden:YES];
    
    
    // set action items
    if ([self.ripple.creatorId isEqualToString:[PFUser currentUser].objectId])
        [self.reportDeleteButton setImage:[UIImage imageNamed:@"trash.png"] forState:UIControlStateNormal];
    
    [self.alreadyActedLabel setHidden:YES];
    
    // set action button items
    if (self.ripple.actedUponState == 0)
    {
        [self.propagateButton setHidden:NO];
        [self.dismissButton setHidden:NO];
        [self.alreadyActedButton setHidden:YES];

        [self.propagateButton setImage:[UIImage imageNamed:@"propagateButtonUnselected"] forState:UIControlStateNormal];
        [self.dismissButton setImage:[UIImage imageNamed:@"dismissRippleIconUnselected"] forState:UIControlStateNormal];
        [self.propagateButton setUserInteractionEnabled:YES];
        [self.dismissButton setUserInteractionEnabled:YES];
    }
    else if (self.ripple.actedUponState == 1)
    {
        [self.propagateButton setHidden:YES];
        [self.dismissButton setHidden:YES];
        
        [self.alreadyActedButton setImage:[UIImage imageNamed:@"alreadySpread.png"] forState:UIControlStateNormal];
        [self.alreadyActedButton setHidden:NO];

    }
    
    else if (self.ripple.actedUponState == 2)
    {
        [self.propagateButton setHidden:YES];
        [self.dismissButton setHidden:YES];
        
        [self.alreadyActedButton setImage:[UIImage imageNamed:@"alreadyDismissed.png"] forState:UIControlStateNormal];
        [self.alreadyActedButton setHidden:NO];
    }
    
    else
    {
        [self.propagateButton setHidden:YES];
        [self.dismissButton setHidden:YES];
        [self.alreadyActedButton setHidden:YES];
    }
}

- (void) setConstraintsForMapOverlay
{
    // find textview height
    [self.rippleTextView setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:18.0]];
    UIFont *myFont = [UIFont fontWithName:@"AvenirNext-Regular" size:18.0];
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:myFont, NSFontAttributeName,nil];
    CGSize stringSize = [self.ripple.creatorName sizeWithAttributes:attributesDictionary];
    self.rippleNameWidthConstraint.constant = stringSize.width + 3;

    // change color of spreadCommentView items
    [self.spreadCommentView setBackgroundColor:[UIColor colorWithRed:238.0/255.0f green:238.0f/255 blue:238.0f/255 alpha:1.0]];
    [self.spreadLabel setTextColor:[UIColor colorWithRed:3.0/255.0f green:123.0f/255 blue:255.0f/255 alpha:1.0]];
    [self.moreInfoComments setTextColor:[UIColor colorWithRed:3.0/255.0f green:123.0f/255 blue:255.0f/255 alpha:1.0]];
    [self.commentsImage setImage:[UIImage imageNamed:@"commentsBlue.png"]];
    
    // size cityLabel accordingly
    UIFont *labelFont = [UIFont fontWithName:@"AvenirNext-Regular" size:12.0];
    NSDictionary *labelDictionary = [NSDictionary dictionaryWithObjectsAndKeys:labelFont, NSFontAttributeName,nil];
    CGSize citySize = [self.ripple.city sizeWithAttributes:labelDictionary];
    self.cityLabelWidthConstraint.constant = citySize.width;

    // setup image height
    if (self.ripple.imageFile)
    {
        [self.imageView setHidden:YES];
        [self.outerImageFile setHidden:YES];
        self.imageView.file = (PFFile *)self.ripple.imageFile;
        self.imageView.image = [UIImage imageNamed:@"grayBox.png"];
        [self.imageView loadInBackground];
        
        // determine height of outerimageFile
        CGFloat heightRatio = self.ripple.imageHeight / self.ripple.imageWidth;
        CGFloat imageHeight = ([UIScreen mainScreen].bounds.size.width - 24) * heightRatio;
        
        if (imageHeight > 350)
            imageHeight = 350;
        
        self.rippleImageTopConstraint.constant = self.outerImageFile.frame.origin.y;
        
        // place ripple text right under, and adjust height of headerview
        if (self.ripple.text)
        {
            // define text height
            [self.rippleTextView setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0]];
            CGSize maximumSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - 32.0, 9999);
            UIFont *myFont = [UIFont fontWithName:@"AvenirNext-Regular" size:20.0];
            NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:myFont, NSFontAttributeName,nil];
            NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
            CGRect textSize =  [self.ripple.text boundingRectWithSize:maximumSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:context];
            self.rippleTextHeightConstraint.constant = textSize.size.height;
            
            self.topTableViewHeader.frame = CGRectMake(self.topTableViewHeader.frame.origin.x, self.topTableViewHeader.frame.origin.y, [UIScreen mainScreen].bounds.size.width, imageHeight + self.rippleTextHeightConstraint.constant + 80 + self.spreadCommentView.frame.size.height);
        }
        else
        {
            self.topTableViewHeader.frame = CGRectMake(self.topTableViewHeader.frame.origin.x, self.topTableViewHeader.frame.origin.y, [UIScreen mainScreen].bounds.size.width, imageHeight + 60 + self.spreadCommentView.frame.size.height);
        }
        
        // add gesture recognizer
        self.tapImageRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToScrollView:)];
        [self.tapImageRecognizer setNumberOfTapsRequired:1];
        [self.tapImageRecognizer setDelegate:self];
        
        // unhide
        if (!self.isOverlayTutorial)
            [self.imageView setHidden:NO];
        
        // place spreadCommentView in the right place, along with text
        self.spreadCommenTopConstraint.constant = imageHeight + self.outerImageFile.frame.origin.y;
        self.rippleTextTopConstraint.constant = imageHeight + self.outerImageFile.frame.origin.y + self.spreadCommentView.frame.size.height + 5;
        
        self.rightSpreadCommentViewConstraint.constant = 0;
        self.leftSpreadCommentViewConStraint.constant = 0;
        
        // border image
        // [self.outerImageFile.layer setCornerRadius:5.0];
        [self.outerImageFile.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
        [self.outerImageFile.layer setBorderWidth:1.0];
        
    }
    
    else
    {
        self.rippleTextTopConstraint.constant = self.outerImageFile.frame.origin.y;
        [self.outerImageFile setHidden:YES];
        
        // define text height
        [self.rippleTextView setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:20.0]];
        CGSize maximumSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - 32.0, 9999);
        UIFont *myFont = [UIFont fontWithName:@"AvenirNext-Regular" size:24.0];
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:myFont, NSFontAttributeName,nil];
        NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
        CGRect textSize =  [self.ripple.text boundingRectWithSize:maximumSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:context];
        self.rippleTextHeightConstraint.constant = textSize.size.height;
        
        self.topTableViewHeader.frame = CGRectMake(self.topTableViewHeader.frame.origin.x, self.topTableViewHeader.frame.origin.y, [UIScreen mainScreen].bounds.size.width, self.rippleTextHeightConstraint.constant + 100);
        
        // place spreadCommentView there
        self.spreadCommenTopConstraint.constant = textSize.size.height + self.outerImageFile.frame.origin.y - 5;
        
        // add small border to this
        [self.rippleTextView.layer setBorderColor:[[UIColor colorWithWhite:0.9 alpha:1.0] CGColor]];
        [self.rippleTextView.layer setBorderWidth:1.0];
        self.rippleTextView.layer.cornerRadius = 5.0;
        
        self.rightSpreadCommentViewConstraint.constant = 4;
        self.leftSpreadCommentViewConStraint.constant = 4;
        
    }
    
    self.tableView.tableHeaderView = self.topTableViewHeader;
    self.mapOverlayHeightConstraint.constant = [UIScreen mainScreen].bounds.size.height - self.navigationController.navigationBar.frame.size.height + 20;
    
    if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        self.mapOverlayTopConstraint.constant = [UIScreen mainScreen].bounds.size.height - 64 - 70;
    else
        self.mapOverlayTopConstraint.constant = [UIScreen mainScreen].bounds.size.height - 64 - 70 - self.tabBarController.tabBar.frame.size.height;

    
    // Update all!
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
    
}

- (void)setupImageConstraints
{
    if (self.ripple.imageFile)
    {
        // determine set to 100% width, ratio for height. (if smaller than...350px)
        CGFloat heightRatio = self.ripple.imageHeight / self.ripple.imageWidth;
        self.imageWidthConstraint.constant = self.outerImageFile.frame.size.width;
        
        if (self.outerImageFile.frame.size.width*heightRatio <=350)
        {
            self.outerImageViewHeightConstraint.constant = self.outerImageFile.frame.size.width*heightRatio;
        }
        
        else
        {
            self.outerImageViewHeightConstraint.constant = 350;
        }

        self.imageHeightConstraint.constant = self.outerImageFile.frame.size.width * heightRatio;
        
        // Update all!
        [self.view setNeedsUpdateConstraints];
        [self.view layoutIfNeeded];
        
        [self.outerImageFile setHidden:NO];
        
        if(!self.isOverlayTutorial)
            [self.imageView setHidden:NO];
    }
}

# pragma mark - gesture recognizers
- (void) addGestureTargets
{
    // add selector for moreInfoView
    UITapGestureRecognizer *tapRecognizerMoreInfo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(PressMoreInfoView:)];
    [tapRecognizerMoreInfo setNumberOfTapsRequired:1];
    [tapRecognizerMoreInfo setDelegate:self];
    [self.topTableViewHeader addGestureRecognizer:tapRecognizerMoreInfo];
    
    // add selector for mapOverlayView Once and tableview once
    /*self.tapMapOverlayOnce = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(PressMapOverlayOnce:)];
    [self.tapMapOverlayOnce setNumberOfTapsRequired:1];
    [self.tapMapOverlayOnce setDelegate:self];
    [self.mapOverlayView addGestureRecognizer:self.tapMapOverlayOnce];*/
    
    // add selector for map
    self.tapRecognizerMap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(PressMapView:)];
    [self.tapRecognizerMap setNumberOfTapsRequired:1];
    [self.tapRecognizerMap setDelegate:self];
    [self.mapView addGestureRecognizer:self.tapRecognizerMap];
    
    // add swipe gestures for mapOverlayView
    UISwipeGestureRecognizer *swipeCommentViewUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeMapOverlayUp:)];
    [swipeCommentViewUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeCommentViewUp setDelegate:self];
    [self.mapOverlayView addGestureRecognizer:swipeCommentViewUp];
    
    // add swipe recognizer on map
    self.swipeMapViewFirstTime = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(swipeMapView:)];
    [self.swipeMapViewFirstTime setMinimumPressDuration:0.001];
    [self.swipeMapViewFirstTime setDelegate:self];
    [self.mapView addGestureRecognizer:self.swipeMapViewFirstTime];
    
     self.swipeCommentViewDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeMapOverlayDown:)];
    [self.swipeCommentViewDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.swipeCommentViewDown setDelegate:self];
    [self.mapOverlayView addGestureRecognizer:self.swipeCommentViewDown];
    
    
}

- (BOOL)gestureRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer class] == [UISwipeGestureRecognizer class])
    {
        if ((!self.commentsShowingOrNah && gestureRecognizer.direction == UISwipeGestureRecognizerDirectionUp) || (!self.commentsShowingOrNah))//&& !self.didTapMapOverlayOnce))
            return YES;
        else if (self.commentsShowingOrNah && gestureRecognizer.direction == UISwipeGestureRecognizerDirectionDown && self.contentOffset == 0)
            return YES;
    }
    
    return NO;
}

/*- (void) PressMapOverlayOnce: (id)sender
{
    if (!self.didTapMapOverlayOnce)
        [self showHideMapToggle:sender];
    
    [self.mapOverlayView removeGestureRecognizer:self.tapMapOverlayOnce];
}*/

- (void)PressMoreInfoView:(id)sender
{
    if (!self.didPressMapOverlayOnce)
        self.commentsShowingOrNah = NO;
    
    [self showHideMapToggle:sender];
    // log event
    [PFAnalytics trackEvent:@"CheckComments" dimensions:nil];
    [Flurry logEvent:@"Check_Comments"];
    
}

- (void)PressMapView:(id)sender
{
    // slide mapOverlayView down
    if (self.commentsShowingOrNah || !self.didPressMapOverlayOnce)
    {
        self.commentsShowingOrNah = YES;
        [self showHideMapToggle:sender];
        
        // log event
        [PFAnalytics trackEvent:@"CheckMap" dimensions:nil];
        [Flurry logEvent:@"CheckMap"];
    }
}

- (void)swipeMapView:(id)sender
{
    [self PressMapView:nil];
    [self.mapView removeGestureRecognizer:self.swipeMapViewFirstTime];
}

- (IBAction)showHideMapToggle:(id)sender {
    
    if (!self.commentsShowingOrNah)
    {
        [UIView animateWithDuration:0.50 animations:^{
            if (self.ripple.imageFile)
                [self.imageView addGestureRecognizer:self.tapImageRecognizer];
            
            if (!self.viewDidLoadJustRan && !self.commentsUp) {
                // make it show 10% of the way of the way
                self.mapOverlayTopConstraint.constant = (self.view.frame.size.height - 64)*0.1;
            }
            
            else if (self.ripple.numberComments == 0)
            {
                if (self.tableView.contentSize.height > self.view.frame.size.height - 64 - self.postCommentViewHeightConstraint.constant)
                    self.mapOverlayTopConstraint.constant = 0;
                else
                    self.mapOverlayTopConstraint.constant = self.view.frame.size.height - 64 - self.tableView.contentSize.height - self.postCommentViewHeightConstraint.constant;
            }
            else if (self.tableView.contentSize.height <= self.view.frame.size.height - 64 - self.postCommentViewHeightConstraint.constant)
                self.mapOverlayTopConstraint.constant = self.view.frame.size.height - 64 - self.tableView.contentSize.height - self.postCommentViewHeightConstraint.constant;
            else
                self.mapOverlayTopConstraint.constant = 0 ;
            
            // work for bools and showing post comment stuff
            [self.postCommentView setHidden:NO];
            self.commentsShowingOrNah = YES;
            
            [self.view setNeedsUpdateConstraints];
            [self.view layoutIfNeeded];
        }completion:^(BOOL finished) {
            if (self.commentsUp)
            {
                // [self.postCommentTextField becomeFirstResponder];
                self.commentsUp = NO;
            }
        }];
    }

   else
    {
        [UIView animateWithDuration:0.5 animations:^{
            if (self.ripple.imageFile)
                [self.imageView removeGestureRecognizer:self.tapImageRecognizer];
            
            if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
                self.mapOverlayTopConstraint.constant = [UIScreen mainScreen].bounds.size.height - 64 - 70;
            else
                self.mapOverlayTopConstraint.constant = [UIScreen mainScreen].bounds.size.height - 64 - 70 - self.tabBarController.tabBar.frame.size.height;
            
            [self.view updateConstraints];
            
            // bool work and show comments post view
            self.commentsShowingOrNah = NO;
            [self.postCommentView setHidden:YES];
            
            [self.view setNeedsUpdateConstraints];
            [self.view layoutIfNeeded];
        }completion:^(BOOL finished) {
            //NOOP
        }];
        
        [PFAnalytics trackEvent:@"CheckMap" dimensions:nil];
        [Flurry logEvent:@"CheckMap"];

    }
    
    self.didPressMapOverlayOnce = YES;
}

- (void)swipeMapOverlayUp: (id)sender
{
    if (!self.commentsShowingOrNah)
        [self showHideMapToggle:sender];
}

- (void)swipeMapOverlayDown: (id)sender
{
    if (self.commentsShowingOrNah)
    {
        [self showHideMapToggle:sender];
    }
        
    [PFAnalytics trackEvent:@"CheckMap" dimensions:nil];
    [Flurry logEvent:@"CheckMap"];

}

#pragma mark- first run
- (void)checkFirstTimeMap
{
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    NSNumber *firstTime = [userData objectForKey:@"firstTimeMap"];
    int firstTimeCheck = [firstTime intValue];
    
    if (firstTimeCheck == 0)
    {
        self.isOverlayTutorial = YES;
        [self.mapView setAlpha:0.4];
        [self.imageView setHidden:YES];
        [self.spreadCommentView setHidden:YES];
        [self.shareButton setHidden:YES];
        [self.reportDeleteButton setHidden:YES];
        [self.cityLabel setHidden:YES];
        [self.rippleDate setHidden:YES];
        [self.rippleTextView setHidden:YES];
        
        //show overlay
        self.overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        [self.overlay setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.6]];
        
        // add textview explaining
        UITextView *map = [[UITextView alloc] initWithFrame:CGRectMake(8, [UIScreen mainScreen].bounds.size.height/2, [UIScreen mainScreen].bounds.size.width - 16, 80)];
        [map setUserInteractionEnabled:NO];
        [map setScrollEnabled:NO];
        [map setTextColor:[UIColor whiteColor]];
        [map setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:20.0]];
        [map setText:@"Leave a comment and see where posts have travelled."];
        [map setTextAlignment:NSTextAlignmentCenter];
        [map setBackgroundColor:[UIColor clearColor]];
        
        // add button to overlay
        UIButton *ok = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 50, map.frame.origin.y + map.frame.size.height, 100, 40)];
        [ok setBackgroundColor:[UIColor colorWithRed:255.0/255.0f green:156.0/255.0f blue:0.0/255.0f alpha:1.0]];
        [ok setTitle:@"OK" forState:UIControlStateNormal];
        [ok setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [ok addTarget:self action:@selector(removeFirstRunOverlay) forControlEvents:UIControlEventTouchUpInside];
        [ok.layer setCornerRadius:5.0];
        
        // add directions
        UITextView *tap = [[UITextView alloc] initWithFrame:CGRectMake(8, 70, [UIScreen mainScreen].bounds.size.width - 16, 100)];
        [tap setUserInteractionEnabled:NO];
        [tap setScrollEnabled:NO];
        [tap setTextColor:[UIColor colorWithRed:1.0f green:156.0/255.0f blue:0.0f alpha:1.0]];
        [tap setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:14.0]];
        [tap setText:@"Tap the background or swipe down to see where this post has reached."];
        [tap setTextAlignment:NSTextAlignmentCenter];
        [tap setBackgroundColor:[UIColor clearColor]];
        
        UIImageView *tapImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tap.png"]];
        [tapImage setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 20, tap.frame.origin.y + 30, 40, 40)];
        
        UITextView *path = [[UITextView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 290, 70, [UIScreen mainScreen].bounds.size.width, 40)];
        [path setUserInteractionEnabled:NO];
        [path setScrollEnabled:NO];
        [path setTextColor:[UIColor colorWithRed:1.0f green:156.0/255.0f blue:0.0f alpha:1.0]];
        [path setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:14.0]];
        [path setText:@"Tap here to see how this post spread."];
        [path setTextAlignment:NSTextAlignmentLeft];
        [path setBackgroundColor:[UIColor clearColor]];
        
        UIImageView *pathImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tap.png"]];
        [pathImage setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 40, 66, 40, 40)];
        
       // [self.overlay addSubview:path];
        //[self.overlay addSubview:pathImage];
        [self.overlay addSubview:tap];
        //[self.overlay addSubview:tapImage];
        [self.overlay addSubview:map];
        [self.overlay addSubview:ok];
        [self.view addSubview:self.overlay];
        [userData setObject:[NSNumber numberWithInteger:1] forKey:@"firstTimeMap"];
        [userData synchronize];
    }
}

- (void)removeFirstRunOverlay
{
    [self.imageView setHidden:NO];
    [self.spreadCommentView setHidden:NO];
    [self.shareButton setHidden:NO];
    [self.reportDeleteButton setHidden:NO];
    [self.cityLabel setHidden:NO];
    [self.rippleDate setHidden:NO];
    [self.rippleTextView setHidden:NO];
    
    [self.mapView setAlpha:1.0];
    self.isOverlayTutorial = NO;
    [self.overlay removeFromSuperview];
}

@end
