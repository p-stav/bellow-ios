//
//  ProfilePageTableViewController.h
//  Bellow
//
//  Created by Paul Stavropoulos on 4/21/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MyRippleCellDelegate.h"
#import "HeaderTableViewCellDelegate.h"
#import <ParseUI/ParseUI.h>
#import "SocialMediaCollectionView.h"


@interface ProfilePageViewController : UIViewController<UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, UIScrollViewDelegate, ActedRippleCellDelegate, HeaderCellDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate, SocialMediaCollectionControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) NSMutableArray *myRipples;
@property (strong, nonatomic) NSMutableArray *myRipplesMostPopular;
@property (strong, nonatomic) NSMutableArray *propagatedRipples;
@property (strong, nonatomic) NSMutableArray *propagatedRipplesMostPopular;

@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) NSArray *userLevels;

@property (nonatomic) BOOL isAllMyRipples;
@property (nonatomic) BOOL isAllMyRipplesMostPopular;
@property (nonatomic) BOOL isAllPropagatedRipples;
@property (nonatomic) BOOL isAllPropagatedRipplesMostPopular;

@property (nonatomic) BOOL goToProfileFromPush;


- (void)rippleDeleted:(Bellow *)ripple;


@end
