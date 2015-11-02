//
//  UserSearchCell.h
//  Ripple
//
//  Created by Paul Stavropoulos on 8/12/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSearchCellDelegate.h"

@interface UserSearchCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UIButton *followerImage;
@property (weak, nonatomic) IBOutlet UILabel *level;


@property (nonatomic) BOOL isFollowing;
@property (strong, nonatomic) NSString *objectId;

// acting delegate
@property (nonatomic, assign) id<UserSearchDelegate> delegate;



@end
