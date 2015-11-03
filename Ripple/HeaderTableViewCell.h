//
//  HeaderTableViewCell.h
//  Bellow
//
//  Created by Paul Stavropoulos on 4/23/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderTableViewCellDelegate.h"

@interface HeaderTableViewCell : UITableViewCell<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *sortButton;
@property (weak, nonatomic) IBOutlet UIView *filterView;
@property (weak, nonatomic) IBOutlet UIButton *filterStarted;
@property (weak, nonatomic) IBOutlet UIButton *filterSpread;
@property (weak, nonatomic) IBOutlet UIImageView *leftMineCarat;
@property (weak, nonatomic) IBOutlet UIImageView *rightSpreadCarat;
@property (weak, nonatomic) IBOutlet UILabel *UserRecentLabel;

@property (strong, nonatomic) UIView *sortView;
@property (nonatomic) BOOL isChoosingSort;
@property (strong, nonatomic) NSArray *sortButtons;
@property (strong, nonatomic) NSMutableArray *sortImages;
@property (strong, nonatomic) UIView *sortUnderlay;
@property (strong, nonatomic) UITapGestureRecognizer *dismissSort;

@property (nonatomic) int sortMethod;
@property (nonatomic) int filterMethod;

// acting delegate
@property (nonatomic, assign) id<HeaderCellDelegate> delegate;

// methods to call
- (void)changeColorOfFilterMethods:(int)filterMethod;
- (void)changeColorOfSortOptions: (int)sortMethod;
- (void) firstSortOption;
- (void) secondSortOption;

@end
