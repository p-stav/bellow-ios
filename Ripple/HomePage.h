//
//  PropagateRippleTableViewController.h
//  Bellow
//
//  Created by Paul Stavropoulos on 11/8/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "PropagateCellDelegate.h"
#import "MyRippleCellDelegate.h"
#import <ParseUI/ParseUI.h>
#import "UserSearchHeaderViewCellDelegate.h"

@interface HomePage : UIViewController <UITableViewDataSource, UITableViewDelegate,UITextViewDelegate, PendingCellDelegate,ActedRippleCellDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate,UserSearchHeaderDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) NSMutableArray *selectedRippleArray;
@property (nonatomic, strong) NSMutableArray *pendingRipples;
@property (strong, nonatomic) NSMutableArray *topRipples;
@property (strong, nonatomic) NSMutableArray *followingRipples;

@property (strong, nonatomic) NSMutableArray *myRipplesMostPopular;
@property (strong, nonatomic) NSMutableArray *propagatedRipples;
@property (strong, nonatomic) NSMutableArray *propagatedRipplesMostPopular;
@property (nonatomic) BOOL isFirstRun;
@property (strong, nonatomic) NSArray *userLevels;

@property (nonatomic) BOOL isAllHomeRipples;
@property (nonatomic) BOOL isAllFollowingRipples;
@property (nonatomic) int followingSkip;
@property (nonatomic) BOOL didSignUpFromTutorial;

@property (strong, nonatomic) NSString *goToRippleId;
@property (nonatomic) BOOL goToProfileFromPush;

- (void)ripplePropagated:(Bellow *)ripple;
- (void)rippleDismissed:(Bellow *)ripple;

// location
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;

// @property (strong, nonatomic) NSMutableArray *topRipples;

@end
