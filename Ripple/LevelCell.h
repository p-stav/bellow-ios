//
//  LevelsTableViewCell.h
//  Bellow
//
//  Created by Paul Stavropoulos on 12/1/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LevelCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *reachLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *levelLabelWidthConstraint;
@end
