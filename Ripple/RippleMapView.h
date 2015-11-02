//
//  RippleMapView.h
//  Ripple
//
//  Created by Gal Oshri on 10/9/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "Ripple.h"
#import "CommentCellDelegate.h"

@interface RippleMapView : UIViewController <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, UIActionSheetDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, CommentTableCellDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, UITextViewDelegate>

@property (strong, nonatomic) Ripple *ripple;
@property (nonatomic) BOOL commentsUp;

@end
