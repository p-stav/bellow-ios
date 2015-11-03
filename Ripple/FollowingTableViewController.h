//
//  FollowingTableViewController.h
//  Bellow
//
//  Created by Paul Stavropoulos on 8/25/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "UserSearchCellDelegate.h"

@interface FollowingTableViewController : UITableViewController<UserSearchDelegate>

@property (strong, nonatomic) NSMutableArray *followingUsers;

@end
