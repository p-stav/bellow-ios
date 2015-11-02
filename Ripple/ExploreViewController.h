//
//  ExploreViewController.h
//  Ripple
//
//  Created by Paul Stavropoulos on 5/23/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyRippleCellDelegate.h"
#include "UserSearchCellDelegate.h"
#import "SwipeableCellDelegate.h"

@interface ExploreViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate,UIAlertViewDelegate, UIScrollViewDelegate>


@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) NSMutableArray *trendingRipples;
//@property (strong, nonatomic) NSMutableArray *selectedDataSource;

@property (nonatomic) BOOL isAllTopRipples;


@end
