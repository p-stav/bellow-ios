//
//  SearchViewController.h
//  Bellow
//
//  Created by Paul Stavropoulos on 10/4/15.
//  Copyright © 2015 Kefi Labs. All rights reserved.
//

#include "UserSearchCellDelegate.h"

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate, UserSearchDelegate, UIAlertViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) NSString *searchString;

@end
