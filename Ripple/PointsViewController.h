//
//  PointsViewController.h
//  Ripple
//
//  Created by Paul Stavropoulos on 2/2/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PointsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) int points;

@end
