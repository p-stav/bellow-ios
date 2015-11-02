//
//  PropagateRippleTableViewController.h
//  Ripple
//
//  Created by Paul Stavropoulos on 11/8/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "PropagateRippleCellDelegate.h"
#import "MyRippleCellDelegate.h"
#import <ParseUI/ParseUI.h>

@interface HomePage : UIViewController <UITableViewDataSource, UITableViewDelegate,UITextViewDelegate, PendingRippleCellDelegate,ActedRippleCellDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, UIScrollViewDelegate>

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

- (void)ripplePropagated:(Ripple *)ripple;
- (void)rippleDismissed:(Ripple *)ripple;

// location
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;

// @property (strong, nonatomic) NSMutableArray *topRipples;

@end
