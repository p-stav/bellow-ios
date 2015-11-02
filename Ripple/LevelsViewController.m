//
//  LevelsViewController.m
//  Ripple
//
//  Created by Gal Oshri on 2/5/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import "LevelsViewController.h"
#import "RippleService.h"
#import "LevelCell.h"
#import "RippleLevel.h"
#import <Parse/Parse.h>

@interface LevelsViewController ()
@property (strong, nonatomic) NSMutableArray *levels;
@property (strong, nonatomic) NSArray *levelsFromService;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation LevelsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.activityIndicator startAnimating];
    [self.activityIndicator setHidden:NO];
    
    self.levels = [[NSMutableArray alloc] init];
    
    
    // make call to get table data
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        self.levelsFromService = [RippleService getRippleLevels];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            [self.levels addObjectsFromArray:self.levelsFromService];
            
            // reload table and check if pending ripples
            [self.tableView reloadData];
            
            [self.activityIndicator stopAnimating];
            [self.activityIndicator setHidden:YES];
        });
    });
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
    
    RippleLevel *level = [self.levels objectAtIndex:[indexPath row]];
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

@end
