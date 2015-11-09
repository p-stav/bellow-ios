//
//  OtherUserProfileViewController.h
//  Bellow
//
//  Created by Paul Stavropoulos on 11/8/15.
//  Copyright © 2015 Kefi Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "HeaderTableViewCellDelegate.h"
#import <ParseUI/ParseUI.h>
#import "SocialMediaCollectionView.h"
#import "SwipeableCell.h"
#import "OtherUserProfileViewController.h"


@interface OtherUserProfileViewController : UIViewController<UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, UIScrollViewDelegate, HeaderCellDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate, SocialMediaCollectionControllerDelegate, SwipeableRippleCellDelegate>

@property (strong, nonatomic) NSMutableArray *myRipples;
@property (strong, nonatomic) NSMutableArray *myRipplesMostPopular;
@property (strong, nonatomic) NSMutableArray *propagatedRipples;
@property (strong, nonatomic) NSMutableArray *propagatedRipplesMostPopular;

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) NSArray *userLevels;

@property (nonatomic) BOOL isAllMyRipples;
@property (nonatomic) BOOL isAllMyRipplesMostPopular;
@property (nonatomic) BOOL isAllPropagatedRipples;
@property (nonatomic) BOOL isAllPropagatedRipplesMostPopular;

@property (nonatomic) BOOL goToProfileFromPush;


@end
