//
//  OtherUserProfileViewController.m
//  Bellow
//
//  Created by Paul Stavropoulos on 11/8/15.
//  Copyright © 2015 Kefi Labs. All rights reserved.
//

#import "OtherUserProfileViewController.h"
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
#import "PointsViewController.h"


@interface OtherUserProfileViewController()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicatorFooter;
@property (weak, nonatomic) IBOutlet UITextView *noRipplesTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noTextTopConstraint;
@property (nonatomic) CGFloat contentOffset;

@property (strong, nonatomic) IBOutlet UIView *tableHeader;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIButton *followingLabel;
@property (strong, nonatomic) IBOutlet UIButton *followingNum;
@property (weak, nonatomic) IBOutlet UIButton *followersLabel;
@property (weak, nonatomic) IBOutlet UIButton *followersNum;
@property (weak, nonatomic) IBOutlet UIButton *reachLabel;
@property (weak, nonatomic) IBOutlet UIButton *reachValue;

@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet UITextView *aboutText;
@property (weak, nonatomic) IBOutlet UITextView *interestText;
@property (weak, nonatomic) IBOutlet UILabel *interestsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *aboutHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *interstsHeightConstraint;

@property (nonatomic) BOOL segueWithCommentsUp;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) TTTTimeIntervalFormatter *timeIntervalFormatter;
@property (strong, nonatomic) NSArray *selectedRippleArray;
@property (strong, nonatomic) NSString *defaultNoPendingRippleString;
@property (nonatomic) BOOL viewDidLoadJustRan;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) UIView *overlay;
@property (nonatomic) BOOL isOverlayTutorial;

@property (strong, nonatomic) NSMutableDictionary *profileToHandle;


@end

@implementation OtherUserProfileViewController

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
    return NO;
}

-(NSString *) getUserIdString {
    return self.userId;
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
        [Flurry logEvent:@"Image_Open_Profile"];
    }
}

- (void) goToUserProfile: (Bellow *)ripple
{
    if (ripple)
    {
        if (![self.currentUser.objectId isEqualToString:ripple.creatorId])
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
    OtherUserProfileViewController *otherUser = [storyboard instantiateViewControllerWithIdentifier:@"OtherUserProfileView"];
    otherUser.userId = creatorId;
    [self.navigationController setNavigationBarHidden:NO];
    
    [self.navigationController pushViewController:otherUser animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embededIconSegue"]) {
        SocialMediaCollectionView * collectionView = (SocialMediaCollectionView *) [segue destinationViewController];
        collectionView.delegate = self;
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
            
            if ([sender isKindOfClass:[Bellow class]])
            {
                Bellow *ripple = (Bellow *)sender;
                mv.ripple = ripple;
                
                if (self.segueWithCommentsUp)
                    mv.commentsUp = YES;
            }
        }
    }
    
    
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
    self.isOverlayTutorial = NO;
    
    // navigtion bar stuff
    self.navigationItem.hidesBackButton = NO;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self checkFirstTimeProfile];
    
    // tab bar hidden
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(swipedRippleUpdateUserProfile:) name:@"swipedRippleUpdateUserProfile" object:nil];
    
    if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [self.navigationController setHidesBarsOnSwipe:NO];
    
    
    
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
    [self.followersNum setHidden:YES];
    [self.followingNum setHidden:YES];
    [self.followingLabel setHidden:YES];
    [self.followersLabel setHidden:YES];
    [self.reachLabel setHidden:YES];
    [self.reachValue setHidden:YES];
    [self.interestsLabel setHidden:YES];
    [self.interestText setHidden:YES];
    [self.aboutText setHidden:YES];
    [self.profileImage setHidden:YES];
    
    // bools and original values
    self.viewDidLoadJustRan = YES;
    self.profileToHandle = nil;
    
    [self hideTabBar];
    
    // get data
    [self updateView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.activityIndicator stopAnimating];
    [self.activityIndicator setHidden:YES];
    
    
    [self.navigationController.navigationBar setHidden:NO];
    
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)hideTabBar
{
    if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [self.tabBarController.tabBar setHidden:YES];
    [self hideComposeButton];
}

#pragma mark - setup
- (void) updateView
{
    // Get My ripples
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];

    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        self.user = [BellowService getUser:self.userId];
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
            self.selectedRippleArray = self.myRipples;
            self.currentUser = self.user;
            
            [self.tableView reloadData];
            [self setupHeaderView];
            
            [self.activityIndicator stopAnimating];
            [self.activityIndicator setHidden:YES];
        });
    });
}

- (void) setupHeaderView
{
    
    // setup navigation title
    UIView *titleView = [[UIView alloc] initWithFrame: CGRectMake(0,40,[UIScreen mainScreen].bounds.size.width - 100, 44)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleView.frame.size.width/2 - 110,0,220, 44)];
    [titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:22.0]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    if([PFAnonymousUtils isLinkedWithUser:self.currentUser])
        titleLabel.text = @"Profile";
    else
        titleLabel.text= [NSString stringWithFormat:@"%@", self.currentUser.username];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleView addSubview:titleLabel];
    self.navigationItem.titleView = titleView;
    [self.navigationItem.titleView setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2, self.navigationController.navigationBar.frame.size.height/2)];
    
    // check if user is following
    if ([PFUser currentUser][@"following"] !=nil && [[PFUser currentUser][@"following"] indexOfObject:self.userId] != NSNotFound)
    {
        [self.followButton setImage:[UIImage imageNamed:@"followingAndLabel.png"] forState:UIControlStateNormal];
    }
    else
    {
        [self.followButton setImage:[UIImage imageNamed:@"followAndLabel.png"] forState:UIControlStateNormal];
    }
    
    // set up followers and following and reach
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
    
    if (self.currentUser[@"reach"] != nil)
        [self.reachValue setTitle:[NSString stringWithFormat:@"%ld", [self.currentUser[@"reach"] integerValue]] forState:UIControlStateNormal];
    else
        [self.reachValue setTitle:@"7" forState:UIControlStateNormal];
    
    [self.followingNum.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:18.0]];
    [self.followersNum.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:18.0]];
    [self.reachValue.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:18.0]];

    // image
    [self.profileImage.layer setCornerRadius:self.profileImage.frame.size.height/2];
    [self.profileImage setBackgroundColor:[UIColor clearColor]];
    [self.profileImage.layer setMasksToBounds:YES];
    [self.profileImage.layer setBorderWidth:0];
    
    // set image
    if (self.currentUser[@"profileImg"]) {
        PFFile *imageFile = self.currentUser[@"profileImg"];
        self.profileImage.file = imageFile;
        [self.profileImage loadInBackground];
    }
    
    // find height of tableHeader and saet about + interest heights
    CGFloat additionalHeaderHeight = 0;
    UIFont *myFont = [UIFont fontWithName:@"AvenirNext-Regular" size:13.0];
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:myFont, NSFontAttributeName,nil];
    CGSize maximumSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - 16.0, 9999);
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];

    if (self.currentUser[@"aboutMe"] != nil && [self.currentUser[@"aboutMe"] length] != 0)
    {
        [self.aboutText setHidden:NO];
        [self.aboutText setText:self.currentUser[@"aboutMe"]];
        [self.aboutText setTextColor:[UIColor blackColor]];
        [self.aboutText setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:13.0]];
        
        CGRect aboutSize =  [self.aboutText.text boundingRectWithSize:maximumSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:context];
        self.aboutHeightConstraint.constant = aboutSize.size.height + 30;
        
    }
    else
    {
        [self.aboutText setHidden:YES];
        self.aboutHeightConstraint.constant = 0;
    }
    
    if (self.currentUser[@"interests"] != nil && [self.currentUser[@"interests"] length] != 0)
    {
        [self.interestText setHidden:NO];
        [self.interestsLabel setHidden:NO];
        [self.interestText setTextColor:[UIColor blackColor]];
        [self.interestText setText:self.currentUser[@"interests"]];
        [self.interestText setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:13.0]];
        
        CGRect interestSize =  [self.interestText.text boundingRectWithSize:maximumSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:context];
        self.interstsHeightConstraint.constant = interestSize.size.height + 30;
    }
    else
    {
        [self.interestText setHidden:YES];
        [self.interestsLabel setHidden:YES];
        self.interstsHeightConstraint.constant = 0;
    }

    // size the table header
    additionalHeaderHeight =self.interstsHeightConstraint.constant + self.aboutHeightConstraint.constant;
    if ([self.user[@"accessibleProfiles"] count] >0)
        additionalHeaderHeight += 50;

    
    self.tableHeader.frame = CGRectMake(self.tableHeader.frame.origin.x, self.tableHeader.frame.origin.y, self.tableHeader.frame.size.width, 100 + additionalHeaderHeight);
    [self.tableView setTableHeaderView:self.tableHeader];
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
    
    // unhide elements
    if (!self.isOverlayTutorial)
    {
        [self.activityIndicator stopAnimating];
        [self.activityIndicator setHidden:YES];
        [self.followingLabel setHidden:NO];
        [self.followingNum setHidden:NO];
        [self.followersLabel setHidden:NO];
        [self.followersNum setHidden:NO];
        [self.reachLabel setHidden:NO];
        [self.reachValue setHidden:NO];
        [self.profileImage setHidden:NO];
        [self.followButton setHidden:NO];
    }
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
    return [self setSwipeableCell:tableView withIndexPath:indexPath];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.user)
        return 30;
    else
        return 0;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // 1. Dequeue the custom header cell
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(8, 5, [UIScreen mainScreen].bounds.size.width - 16, 20);
    myLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:14.0];
    myLabel.text = [NSString stringWithFormat:@"%@'s posts:", self.currentUser.username];
    [myLabel setTextColor:[UIColor blackColor]];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1.0]];
    [headerView addSubview:myLabel];
    
    return headerView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (SwipeableCell *)setSwipeableCell:(UITableView *)tableView withIndexPath:(NSIndexPath *) indexPath
{
    [tableView registerNib:[UINib nibWithNibName:@"SwipeableCell" bundle:nil] forCellReuseIdentifier:@"SwipeableCell"];
    
    SwipeableCell *cell = (SwipeableCell *)[tableView dequeueReusableCellWithIdentifier:@"SwipeableCell" forIndexPath:indexPath];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    Bellow *ripple = [self.selectedRippleArray objectAtIndex:[indexPath row]];
    
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
    [cell.spreadReachLabel setText:[NSString stringWithFormat:@"spread to %@ people",[PFUser currentUser][@"reach"]]];
    
    
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
    
    if ([indexPath row] == [self.selectedRippleArray count] - 4)
    {
        // call method to create ripples with block to reload
        [self.indicatorFooter startAnimating];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *newMyRipples;
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
}


- (void)refreshList
{
    [self updateView];
}

- (void)checkRemainingRipples
{
    if ([self.myRipples count] == 0)
    {
        self.noRipplesTextView.text =[NSString stringWithFormat:@"There are no posts from %@", self.currentUser.username];
        [self.view updateConstraints];
        [self.noRipplesTextView setHidden:NO];
    }
    
    else
        [self.noRipplesTextView setHidden:YES];
}

#pragma mark - swipeableCellDelegates
- (void)rippleDismissed:(Bellow *)ripple
{
    // update trending ripple
    NSUInteger position = [self.myRipples indexOfObject:ripple];
    Bellow *rippleObject = [self.myRipples objectAtIndex:position];
    rippleObject.actedUponState = 2;
    
    [self.myRipples replaceObjectAtIndex:position withObject:rippleObject];
    
    // post notifications
    ripple.actedUponState = 2;
    
    
    // data
    [PFAnalytics trackEvent:@"RippleDismissed" dimensions:@{@"feed":@"  "}];
    [Flurry logEvent:@"Ripple_Dismissed" withParameters:[NSDictionary dictionaryWithObject:@"user_profile_feed" forKey:@"feed"]];
    
}

- (void)ripplePropagated:(Bellow *)ripple
{
    // update ripple
    NSUInteger position = [self.myRipples indexOfObject:ripple];
    Bellow *rippleObject = [self.myRipples objectAtIndex:position];
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
            UIAlertView *tapOnRipple = [[UIAlertView alloc]initWithTitle:@"Tap on a Bellow!" message:@"See a map of where that ripple has spread and leave a comment"delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [tapOnRipple show];
            
            
            
        }
        
        else if (spreadFirstRippleCheck == 50) {
            
            UIAlertView *reviewRipple = [[UIAlertView alloc] initWithTitle:@"Review Bellow" message:@"Enjoying Bellow? Rate or review it!" delegate:self cancelButtonTitle:@"Not now" otherButtonTitles:@"Rate or review", nil];
            
            [Flurry logEvent:@"Ask_For_Review"];
            
            [reviewRipple show];
        }
        
        else if (spreadFirstRippleCheck == 100) {
            UIAlertView *referralPoints = [[UIAlertView alloc] initWithTitle:@"Invite friends!" message:[NSString stringWithFormat:@"Bellow is more fun with frineds! Get them on Bellow, you'll both earn points"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Invite", nil];
            [referralPoints show];
        }
        
        [userData setObject:[NSNumber numberWithInteger:(spreadFirstRippleCheck + 1)] forKey:@"spreadFirstRipple"];
        [userData synchronize];
    }
}

- (void)swipedRippleUpdateUserProfile:(NSNotification *)notification
{
    // check if the ripple is in the list
    Bellow *swipedRipple = (Bellow *)[notification object];
    
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
                [self.followButton setImage:[UIImage imageNamed:@"followingAndLabel.png"] forState:UIControlStateNormal];
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
            [self.followButton setImage:[UIImage imageNamed:@"followAndLabel.png"] forState:UIControlStateNormal];
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
        
        [self.followButton setImage:[UIImage imageNamed:@"followingAndLabel.png"] forState:UIControlStateNormal];
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
    
    if ([alertView.title isEqualToString:@"Review Bellow"])
    {
        if (buttonIndex == 1)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"itms-apps://itunes.apple.com/app/" stringByAppendingString: @"id946792245"]]];
            
            [Flurry logEvent:@"Review_Clicked"];
        }
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


#pragma mark-first run
- (void)checkFirstTimeProfile
{
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    NSNumber *firstTime = [userData objectForKey:@"firstTimeOtherUserProfile"];
    int firstTimeCheck = [firstTime intValue];
    
    if (firstTimeCheck == 0)
    {
        self.isOverlayTutorial = YES;
        
        //show overlay
        self.overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        [self.overlay setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.8]];
        
        // add textview explaining
        UITextView *topPosts = [[UITextView alloc] initWithFrame:CGRectMake(8, 80, [UIScreen mainScreen].bounds.size.width - 16, 50)];
        [topPosts setUserInteractionEnabled:NO];
        [topPosts setScrollEnabled:NO];
        [topPosts setTextColor:[UIColor whiteColor]];
        [topPosts setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:20.0]];
        [topPosts setText:@"User profile page"];
        [topPosts setTextAlignment:NSTextAlignmentCenter];
        [topPosts setBackgroundColor:[UIColor clearColor]];
        
        UIButton *ok = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 50, topPosts.frame.origin.y + topPosts.frame.size.height, 100, 40)];
        [ok setBackgroundColor:[UIColor colorWithRed:255.0/255.0f green:156.0/255.0f blue:0.0/255.0f alpha:1.0]];
        [ok setTitle:@"Got it" forState:UIControlStateNormal];
        [ok setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [ok addTarget:self action:@selector(removeFirstRunOverlay) forControlEvents:UIControlEventTouchUpInside];
        [ok.layer setCornerRadius:5.0];
        
        
        UILabel *swipe = [[UILabel alloc] initWithFrame:CGRectMake(8,[UIScreen mainScreen].bounds.size.height - 150, [UIScreen mainScreen].bounds.size.width - 16, 40)];
        [swipe setUserInteractionEnabled:NO];
        [swipe setTextColor:[UIColor colorWithRed:1.0f green:156.0/255.0f blue:0.0f alpha:1.0]];
        [swipe setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:14.0]];
        [swipe setText:@"You can swipe posts from a user's profile."];
        [swipe setTextAlignment:NSTextAlignmentCenter];
        [swipe setBackgroundColor:[UIColor clearColor]];
        
        UIImageView *swipeImg= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tap"]];
        [swipeImg setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-20, swipe.frame.origin.y + 40, 40, 40)];
        
        UIImageView *followImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tap"]];
        [followImg setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 50, 200, 40, 40)];
        
        UILabel *follow = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 250, followImg.frame.origin.y+ 35, [UIScreen mainScreen].bounds.size.width, 40)];
        [follow setUserInteractionEnabled:NO];
        [follow setTextColor:[UIColor colorWithRed:1.0f green:156.0/255.0f blue:0.0f alpha:1.0]];
        [follow setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:14.0]];
        [follow setText:@"Tap here to follow a user."];
        [follow setTextAlignment:NSTextAlignmentCenter];
        [follow setBackgroundColor:[UIColor clearColor]];
        
        
        [self.overlay addSubview:swipeImg];
        [self.overlay addSubview:swipe];
        [self.overlay addSubview:followImg];
        [self.overlay addSubview:follow];
        [self.overlay addSubview:topPosts];
        [self.overlay addSubview:ok];
        [self.view addSubview:self.overlay];
        [userData setObject:[NSNumber numberWithInteger:1] forKey:@"firstTimeOtherUserProfile"];
        [userData synchronize];
        
        [self.activityIndicator stopAnimating];
        [self.activityIndicator setHidden:YES];
    }
}

- (void)removeFirstRunOverlay
{
    [self.overlay removeFromSuperview];
    
    //unhide items
    [self.followingLabel setHidden:NO];
    [self.followingNum setHidden:NO];
    [self.followersLabel setHidden:NO];
    [self.followersNum setHidden:NO];
    [self.activityIndicator stopAnimating];
    [self.activityIndicator setHidden:YES];
}

@end
