//
//  RippleLevelView.m
//  Ripple
//
//  Created by Gal Oshri on 11/22/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import "RippleLevelView.h"
#import "RippleService.h"
#import "RippleLevel.h"
#import "LevelsTableViewCell.h"
#import <Parse/Parse.h>


@interface RippleLevelView ()

@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *reachLabel;
@property (weak, nonatomic) IBOutlet UILabel *reachNumLabel;

// @property (strong, nonatomic) IBOutlet UITextView *explanation;
// @property (strong, nonatomic) IBOutlet UIView *headerView;

@end

@implementation RippleLevelView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableHeaderView.backgroundColor = [UIColor colorWithRed:43.0/255.0f green:132.0f/255 blue:219.0f/255 alpha:1.0];
    self.navigationItem.title = @"Levels";
    self.navigationItem.leftBarButtonItem.title = @"";
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        self.rippleLevels = [RippleService getRippleLevels];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            // reload table and check if pending ripples
            [self.tableView reloadData];
        });
    });
    
    self.scoreLabel.text = [NSString stringWithFormat:@"%@ points", [PFUser currentUser][@"score"]];
    self.reachLabel.text = [NSString stringWithFormat:@"%@", [PFUser currentUser][@"reachLevel"]];
    self.reachNumLabel.text = [NSString stringWithFormat:@"%@x reach",[PFUser currentUser][@"reach"]];
}

/*
- (IBAction)explanationToggle:(UIButton *)sender
{
    if (self.explanation.alpha == 1.0)
    {
        [UIView animateWithDuration:0.5 animations:^{
            
            CGRect newFrame = self.tableHeaderView.frame;
            newFrame.size.height = newFrame.size.height - 90;
            self.tableHeaderView.frame = newFrame;
            NSLog(@"%f", self.tableHeaderView.frame.size.height);
            [self.tableView setTableHeaderView:self.tableHeaderView];
        }];
        self.explanation.alpha = 0.0;
    }
    else
    {
        self.explanation.alpha = 1.0;
        [UIView animateWithDuration:0.5 animations:^{
            
            CGRect newFrame = self.tableHeaderView.frame;
            newFrame.size.height = newFrame.size.height + 90;
            self.tableHeaderView.frame = newFrame;
            NSLog(@"%f", self.tableHeaderView.frame.size.height);
            [self.tableView setTableHeaderView:self.tableHeaderView];
        }];
    }
}
*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [self.rippleLevels count];
}


- (LevelsTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LevelsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"levelCell" forIndexPath:indexPath];
    
    RippleLevel *level = [self.rippleLevels objectAtIndex:[indexPath row]];
    cell.levelLabel.text = level.name;
    cell.reachLabel.text = [NSString stringWithFormat:@"%dx reach",level.reach];
    cell.pointsLabel.text = [NSString stringWithFormat:@"%d points", level.minScore];
        
    if (level.minScore < [[PFUser currentUser][@"score"] intValue])
    {
        cell.backgroundColor = [UIColor whiteColor];
        cell.levelLabel.textColor = [UIColor grayColor];
        cell.reachLabel.textColor = [UIColor grayColor];
        cell.pointsLabel.textColor = [UIColor grayColor];
    }
    else
    {
        cell.backgroundColor = [UIColor whiteColor];
        cell.levelLabel.textColor = [UIColor blackColor];
        cell.reachLabel.textColor = [UIColor grayColor];
        cell.pointsLabel.textColor = [UIColor grayColor];
    }
    

    if ([level.name isEqualToString:[PFUser currentUser][@"reachLevel"]])
    {
        cell.backgroundColor = [UIColor colorWithRed:43.0/255.0f green:132.0f/255 blue:219.0f/255 alpha:0.9];
        cell.levelLabel.textColor = [UIColor whiteColor];
        cell.reachLabel.textColor = [UIColor whiteColor];
        cell.pointsLabel.textColor = [UIColor whiteColor];
    }
    
    
    
    return cell;
}

@end
