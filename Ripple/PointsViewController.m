//
//  PointsViewController.m
//  Bellow
//
//  Created by Paul Stavropoulos on 2/2/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import "PointsViewController.h"
#import "BellowService.h"
#import "BellowPoint.h"
#import "BellowLevel.h"
#import "LevelCell.h"
#import "ShareRippleSheet.h"

@interface PointsViewController ()
@property (strong, nonatomic) NSMutableArray *levels;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *levelsFromService;
@property (weak, nonatomic) IBOutlet UIButton *shareRipple;
@property (weak, nonatomic) IBOutlet UIButton *shareImage;
@property (weak, nonatomic) IBOutlet UITextView *pointsLevelText;


@end

@implementation PointsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.levels = [[NSMutableArray alloc] init];
    
    
    // make call to get table data
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        self.levelsFromService = [BellowService getRippleLevels];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            [self.levels addObjectsFromArray:self.levelsFromService];
            
            // reload table and check if pending ripples
            [self.tableView reloadData];
        });
    });
    
    // add touch targets to share stuff
    [self.shareRipple addTarget:self action:@selector(shareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.shareImage addTarget:self action:@selector(shareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // write text for pointsLevelText
    if (!self.points)
        self.points = 0;

    if ([[PFUser currentUser][@"score"] integerValue] != 1)
        [self.pointsLevelText setText:[NSString stringWithFormat:@"You have %d points and are at the '%@' level", self.points ,[PFUser currentUser][@"reachLevel"]]];
    else
        [self.pointsLevelText setText:[NSString stringWithFormat:@"You have %d point and are at the '%@' level",self.points ,[PFUser currentUser][@"reachLevel"]]];
    
    [self.pointsLevelText setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:15.0]];
    [self.pointsLevelText setTextColor:[UIColor colorWithRed:3.0/255.0f green:123.0f/255 blue:255.0f/255 alpha:1.0]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)shareButtonPressed:(id)sender
{
    UIActivityViewController *shareController = [ShareRippleSheet shareRippleSheet:nil];
    [self presentViewController:shareController animated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.levels count];
}

- (LevelCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LevelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"levelCell" forIndexPath:indexPath];
    
    BellowLevel *level = [self.levels objectAtIndex:[indexPath row]];
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
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
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
            cell.backgroundColor = [UIColor colorWithRed:3.0/255.0f green:123.0f/255 blue:255.0f/255 alpha:0.7];
        else
            cell.backgroundColor = [UIColor colorWithRed:3.0/255.0f green:123.0f/255 blue:255.0f/255 alpha:0.6];
        
        cell.levelLabel.textColor = [UIColor whiteColor];
        cell.reachLabel.textColor = [UIColor whiteColor];
        cell.pointsLabel.textColor = [UIColor whiteColor];
        cell.levelNumber.textColor = [UIColor whiteColor];
    }
    
    return cell;
}

- (IBAction)doneWasPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 97.0;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(LevelCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Levels:"];
}

@end
