//
//  UserSearchHeaderViewCell.h
//  Bellow
//
//  Created by Paul Stavropoulos on 11/4/15.
//  Copyright © 2015 Kefi Labs. All rights reserved.
//

#import "HeaderTableViewCell.h"
#import "UserSearchHeaderViewCellDelegate.h"

@interface UserSearchHeaderViewCell : UITableViewCell<UISearchBarDelegate, UserSearchHeaderDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *userSearchView;

// acting delegate
@property (nonatomic, assign) id<UserSearchHeaderDelegate> delegate;

@end
