//
//  TutorialViewController.h
//  Bellow
//
//  Created by Gal Oshri on 10/20/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "RippleLogInView.h"
#import "PropagateCellDelegate.h"

@interface TutorialViewController : UIViewController <UIWebViewDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UIScrollViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *tutorialScrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

// location
@property (strong, nonatomic) CLLocationManager *locationManager;

@end
