//
//  ViewController.h
//  Ripple
//
//  Created by Gal Oshri on 9/10/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>



@interface StartRippleViewController : UIViewController <UITextViewDelegate, CLLocationManagerDelegate,UIGestureRecognizerDelegate, NSLayoutManagerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIButton *rippleButton;
@property (strong, nonatomic) IBOutlet UITextView *rippleTextView;

@property (nonatomic) BOOL rippleCreated;

/****MOVED to propagaterippleTVC
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;
*/
@end
