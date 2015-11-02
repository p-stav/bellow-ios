//
//  MyRipplesViewController.m
//  Ripple
//
//  Created by Gal Oshri on 9/23/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import "MyRipplesViewController.h"
#import "RippleService.h"
#import "MyRippleCell.h"
#import "RippleMapView.h"
#import <MapKit/MapKit.h>
#import "RippleLevelView.h"
#import "RippleLevel.h"
#import "LevelCell.h"

#import "TTTTimeIntervalFormatter.h"

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface MyRipplesViewController ()

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *TopOfHeaderView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *rippleLevel;
@property (weak, nonatomic) IBOutlet UILabel *highestPropagatedLabel;
@property (strong, nonatomic) IBOutlet UILabel *networkScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;

@property (strong, nonatomic) IBOutlet UIView *progressBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressBarWidthConstraint;
@property (strong, nonatomic) IBOutlet UIView *progressBackground;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressBackgroundWidthConstraint;

@property (strong, nonatomic) NSArray *rippleLevels;


@end

@implementation MyRipplesViewController

#pragma mark - Navigation


- (IBAction)unwindToMyRipplesView:(UIStoryboardSegue *)segue {
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // navigation item setup and color stuff
    self.TopOfHeaderView.backgroundColor = [UIColor colorWithRed:43.0/255.0f green:132.0f/255 blue:219.0f/255 alpha:1.0];

    UIButton *settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    [settingsButton setImage:[UIImage imageNamed:@"settingGear.png"] forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(showActionSheet:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    
    // set table view items
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    if ([self.tableView respondsToSelector:@selector(layoutMargins)])
        self.tableView.layoutMargins = UIEdgeInsetsZero;
        
    if ([[NSProcessInfo processInfo] respondsToSelector:@selector(isOperatingSystemAtLeastVersion:)])
        self.headerView.backgroundColor = [UIColor colorWithRed:80.0f/255 green:150.0f/255 blue:186.0f/255 alpha:1.0];
    else
        self.headerView.backgroundColor = [UIColor colorWithRed:52.0f/255 green:133.0f/255 blue:177.0f/255 alpha:1.0];
    
    self.highestPropagatedLabel.text = [NSString stringWithFormat:@"largest ripple: %d ", [[PFUser currentUser][@"highestPropagated"] intValue]];
    self.networkScoreLabel.text = [NSString stringWithFormat:@"%dx reach", [[PFUser currentUser][@"reach"] intValue]];
    self.pointsLabel.text = [NSString stringWithFormat:@"%d points", [[PFUser currentUser][@"score"] intValue]];

    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        [[PFUser currentUser] refresh];
    });

    // get ripple levels
    [self.progressBackground setHidden:YES];
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        self.rippleLevels = [RippleService getRippleLevels];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            // reload table and check if pending ripples
            [self.tableView reloadData];

            [self.activityIndicator stopAnimating];
            [self.activityIndicator setHidden:YES];
            
            [self showExperienceBar];
        });
    });
    
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
    
    
    // remove table separators when not needed
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // set up table refreshing
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;


}

- (void)showExperienceBar
{
    self.rippleLevel.hidden = NO;
    self.progressBackground.hidden = NO;
    
    // set ripple reach level text width, progress bar width, and update constraints
    [self.rippleLevel setText:[NSString stringWithFormat:@"%@", [PFUser currentUser][@"reachLevel"]]];
    
    // need to update width of progress bar
    UILabel *foo = [[UILabel alloc] init];
    foo.frame =CGRectMake(0, 0, 10.0, 10.0);
    [foo setFont:[UIFont fontWithName:@"Avenir" size:37.0]];
    foo.text = [PFUser currentUser][@"reachLevel"];
    [foo sizeToFit];
    CGSize rippleLevelTextSize = foo.frame.size;
    
    self.progressBackgroundWidthConstraint.constant = rippleLevelTextSize.width;
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
    
    // calculate progress bar width
    double score = [[PFUser currentUser][@"score"] doubleValue];
    double minScore = 0;
    double maxScore = 0;
    for (int i = 0; i < [self.rippleLevels count]; i++)
    {
        RippleLevel *level = self.rippleLevels[i];
        if (level.minScore > score)
        {
            maxScore = level.minScore;
            
            // find previous level
            if (i - 1 >= 0)
            {
                RippleLevel *previousLevel = self.rippleLevels[i - 1];
                minScore =  previousLevel.minScore;
            }
            
            break;
        }
        
    }
    
    double ratio = (score - minScore) / (maxScore - minScore);
    CGFloat xCoordinate = self.progressBackground.frame.size.width * ratio;
    if (ratio == 0)
        xCoordinate = self.progressBackground.frame.size.width * 0.01;
    
    [self.progressBackground setHidden:NO];
    // animate
    [UIView animateWithDuration:1 animations:^{
        self.progressBarWidthConstraint.constant = xCoordinate;
        
        self.progressBar.frame = CGRectMake(self.progressBar.frame.origin.x, self.progressBar.frame.origin.y, xCoordinate, self.progressBar.frame.size.height);
    }];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = [PFUser currentUser].username;
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.rippleLevels count];
}

- (LevelCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LevelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"levelCell" forIndexPath:indexPath];
    
    RippleLevel *level = [self.rippleLevels objectAtIndex:[indexPath row]];
    cell.levelLabel.text = level.name;
    cell.levelNumber.text = [NSString stringWithFormat:@"Level %d", [indexPath row]+1 ];
    cell.reachLabel.text = [NSString stringWithFormat:@"%dx reach",level.reach];
    cell.pointsLabel.text = [NSString stringWithFormat:@"%d points", level.minScore];
    
    // size label
    UILabel *foo = [[UILabel alloc] init];
    foo.frame =CGRectMake(0, 0, 10.0, 30.0);
    [foo setFont:[UIFont systemFontOfSize:26.0]];
    foo.text = level.name;
    [foo sizeToFit];
    CGSize rippleLevelTextCellSize = foo.frame.size;
    
    cell.levelLabelWidthConstraint.constant = rippleLevelTextCellSize.width;
    [cell.contentView setNeedsUpdateConstraints];
    [cell.contentView layoutIfNeeded];
    
    if (level.minScore < [[PFUser currentUser][@"score"] intValue])
    {
        cell.backgroundColor = [UIColor whiteColor];
        cell.levelLabel.textColor = [UIColor grayColor];
        cell.reachLabel.textColor = [UIColor grayColor];
        cell.pointsLabel.textColor = [UIColor grayColor];
        cell.levelNumber.textColor = [UIColor grayColor];
        cell.levelNumber.textColor = [UIColor grayColor];
    }
    else
    {
        cell.backgroundColor = [UIColor whiteColor];
        cell.levelLabel.textColor = [UIColor blackColor];
        cell.reachLabel.textColor = [UIColor grayColor];
        cell.pointsLabel.textColor = [UIColor grayColor];
        cell.levelNumber.textColor = [UIColor blackColor];
    }
    
    if ([level.name isEqualToString:[PFUser currentUser][@"reachLevel"]])
    {
        if ([[NSProcessInfo processInfo] respondsToSelector:@selector(isOperatingSystemAtLeastVersion:)])
            cell.backgroundColor = [UIColor colorWithRed:43.0/255.0f green:132.0f/255 blue:219.0f/255 alpha:0.7];
        else
            cell.backgroundColor = [UIColor colorWithRed:43.0/255.0f green:132.0f/255 blue:219.0f/255 alpha:0.6];
        
        cell.levelLabel.textColor = [UIColor whiteColor];
        cell.reachLabel.textColor = [UIColor whiteColor];
        cell.pointsLabel.textColor = [UIColor whiteColor];
        cell.levelNumber.textColor = [UIColor whiteColor];
    }
    
    return cell;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 97.0;
}

-(IBAction)showActionSheet:(id)sender {
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Feedback", @"Terms of service", @"Privacy policy", nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

     switch (buttonIndex) {
         case 0:
         {
             NSString *urlString = @"mailto:wellRippleMeThis@gmail.com?subject=Feedback%20On%20Ripple";
             NSURL *url = [NSURL URLWithString:urlString];
             [[UIApplication sharedApplication] openURL:url];
             break;
         }
         case 1:
             [self performSegueWithIdentifier:@"SegueToTermsOfService" sender:self];
             break;
         case 2:
             [self performSegueWithIdentifier:@"SegueToPrivacyPolicy" sender:self];
             break;
         case 3:
             NSLog(@"Cancel");
         default:
             break;
             // terms of service, feedback, privacy policy,
     }
    
}

@end
