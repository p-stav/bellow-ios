///
//  TutorialViewController.m
//  Bellow
//
//  Created by Gal Oshri on 10/20/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import "TutorialViewController.h"
#import "PendingRippleCell.h"
#import <Parse/Parse.h>
#import "RippleLogInView.h"
#import "RippleSignUpView.h"
#import "HomePage.h"
#import <ParseFacebookUtilsV4/ParseFacebookUtilsV4.h>
#import <ParseTwitterUtils/ParseTwitterUtils.h>
#include "BellowService.h"



@interface TutorialViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textViewAccept;
@property (weak, nonatomic) IBOutlet UIButton *tosButton;
@property (weak, nonatomic) IBOutlet UILabel *andLabel;
@property (weak, nonatomic) IBOutlet UIButton *privacyButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *headerview;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) UIImageView *backgroundImage;

@property (strong, nonatomic) UIImageView *spreadImage;
@property (strong, nonatomic) UILabel *spreadLabel;
@property (strong, nonatomic) UIImageView *dismissImage;
@property (strong, nonatomic) UILabel *dismissLabel;

@property (strong, nonatomic) NSArray *images;
@property (nonatomic) NSUInteger numTutorialPages;
@property (nonatomic) NSUInteger currentTutorialPage;
@property (strong, nonatomic) NSArray *tutorialCells;

@property (strong, nonatomic) UIImageView *imageView0;
@property (strong, nonatomic) UIImageView *imageView1;
@property (strong, nonatomic) UIImageView *imageView2;
@property (strong, nonatomic) UIImageView *imageView3;

@property (strong, nonatomic) UIWebView *gif0WebView;
@property (strong, nonatomic) UIWebView *gif1WebView;
@property (strong, nonatomic) UIWebView *gif2WebView;
@property (strong, nonatomic) UIWebView *gif3WebView;

@property (nonatomic) int referralNum;


@end


@implementation TutorialViewController

@synthesize locationManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // setup webview and tutorialScrollView
    self.tutorialScrollView.delegate = self;
    self.numTutorialPages = 2;
    [self.pageControl setNumberOfPages:2];
    [self.pageControl setHidden:YES];
    
    // add border to view
    [self.headerview setBackgroundColor:[UIColor colorWithRed:0/255.0f green:123.0f/255.0f blue:255.0f/255.0f alpha:1.0]];
    [self.bottomView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.7]];
    [self.tutorialScrollView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.7]]; // setBackgroundColor:[UIColor colorWithRed:0/255.0f green:123.0f/255.0f blue:255.0f/255.0f alpha:1.0]];
    
    // set imageview background
    UIImage *image = [UIImage imageNamed:@"step1.png"];
    CGFloat ratio = (float) image.size.height / image.size.width;
    
    self.backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (int)[UIScreen mainScreen].bounds.size.height / ratio, [UIScreen mainScreen].bounds.size.height)];
    [self.backgroundImage setImage:[UIImage imageNamed:@"step1.png"]];
    
    [self.view addSubview:self.backgroundImage];
    [self.view sendSubviewToBack:self.backgroundImage];
    
    // [self.view.layer setBorderWidth:8.0];
    [self.activityIndicator setHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tutorialScrollView.contentSize = CGSizeMake(self.view.frame.size.width * self.numTutorialPages, self.tutorialScrollView.frame.size.height);
    [self.activityIndicator startAnimating];
    [self.activityIndicator stopAnimating];
    [self.activityIndicator setHidden:YES];
    
    // setup pages
    for (int i = 0; i < self.numTutorialPages; i++)
    {
        CGRect frame;
        frame.origin.x = self.tutorialScrollView.frame.size.width * i;
        frame.origin.y = -10;
        frame.size = self.tutorialScrollView.frame.size;
        frame.size.width = frame.size.width;
        frame.size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 6);
        
        UIView *tutorialView = [[UIView alloc] init];
        tutorialView.frame = frame;
        [tutorialView setBackgroundColor:[UIColor colorWithRed:0/255.0f green:123.0f/255.0f blue:255.0f/255.0f alpha:1.0]];
        
        if (i==0) {
            // add text
            UITextView *title = [[UITextView alloc]initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 80)];
            [title setText:@"Bellow"];
            [title setTextAlignment:NSTextAlignmentCenter];
            [title setEditable:NO];
            [title setSelectable:NO];
            [title setScrollEnabled:NO];
            [title setTextColor:[UIColor whiteColor]];
            [title setBackgroundColor:[UIColor clearColor]];
            [title setFont:[UIFont fontWithName:@"ArialRoundedMTBold" size:65.0]];
            
            UITextView *connect = [[UITextView alloc] initWithFrame:CGRectMake(frame.origin.x + 8, title.frame.origin.y + title.frame.size.height + 10, self.view.frame.size.width - 16, 120)];
            [connect setEditable:NO];
            [connect setSelectable:NO];
            [connect setText:@"Where your awesome stuff spreads"];
            [connect setTextColor:[UIColor whiteColor]];
            [connect setBackgroundColor:[UIColor clearColor]];
            [connect setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:18.0]];
            [connect setTextAlignment:NSTextAlignmentCenter];
            
            UIButton *continueBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 100, connect.frame.origin.y + connect.frame.size.height - 10, 200, 90)];
            [continueBtn setTitle:@"Get Started" forState:UIControlStateNormal];
            [continueBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [continueBtn setBackgroundColor:[UIColor colorWithRed:0/255.0f green:123.0f/255.0f blue:255.0f/255.0f alpha:1.0]];
            [continueBtn.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:25.0]];
            [continueBtn addTarget:self action:@selector(continueWasPressed) forControlEvents:UIControlEventTouchUpInside];
            continueBtn.layer.cornerRadius = 10;
            continueBtn.clipsToBounds = YES;
            
            UILabel *haveAccount = [[UILabel alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 180, [UIScreen mainScreen].bounds.size.width, 15)];
            [haveAccount setText:@"Have an account?"];
            [haveAccount setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:15.0]];
            [haveAccount setTextColor:[UIColor whiteColor]];
            [haveAccount setBackgroundColor:[UIColor clearColor]];
            [haveAccount setTextAlignment:NSTextAlignmentCenter];
            
            UIButton *haveAccountBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 70, haveAccount.frame.origin.y + haveAccount.frame.size.height + 10, 140, 50)];
            [haveAccountBtn setTitle:@"Login" forState:UIControlStateNormal];
            [haveAccountBtn setTitleColor:[UIColor colorWithRed:0/255.0f green:123.0f/255.0f blue:255.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
            [haveAccountBtn setBackgroundColor:[UIColor whiteColor]];
            [haveAccountBtn.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:18.0]];
            [haveAccountBtn addTarget:self action:@selector(loginWasPressed:) forControlEvents:UIControlEventTouchUpInside];
            haveAccountBtn.layer.cornerRadius = 10;
            haveAccountBtn.clipsToBounds = YES;

            
            [self.tutorialScrollView addSubview:connect];
            [self.tutorialScrollView addSubview:title];
            [self.tutorialScrollView addSubview:continueBtn];
            [self.tutorialScrollView addSubview:haveAccountBtn];
            [self.tutorialScrollView addSubview:haveAccount];

            // show tos and privacy
            [self.activityIndicator setHidden:YES];
            [self.textViewAccept setHidden: NO];
            [self.tosButton setHidden:NO];
            [self.privacyButton setHidden:NO];
            [self.andLabel setHidden:NO];

            
            /*
            UITextView *comment = [[UITextView alloc] initWithFrame:CGRectMake(frame.origin.x + 8, self.imageView0.frame.origin.y - 60, self.view.frame.size.width - 8, 120)];
            [comment setEditable:NO];
            [comment setSelectable:NO];
            
            [comment setText:@"Tap a ripple to see a map of where it spread."];
            [comment setTextColor:[UIColor whiteColor]];
            [comment setBackgroundColor:[UIColor clearColor]];
            [comment setFont:[UIFont fontWithName:@"Avenir-Roman" size:18.0]];
            [comment setTextAlignment:NSTextAlignmentCenter];
            
            [self.tutorialScrollView addSubview:comment];
            */
        }
        
        if (i == 1)
        {
            UIView *mapView = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];

            // add start and explore
            UITextView *locationTitle = [[UITextView alloc] initWithFrame:CGRectMake(8, 150, self.view.frame.size.width - 8, 40)];
            [locationTitle setEditable:NO];
            [locationTitle setSelectable:NO];
            [locationTitle setText:@"Location"];
            [locationTitle setTextColor:[UIColor whiteColor]];
            [locationTitle setBackgroundColor:[UIColor clearColor]];
            [locationTitle setFont:[UIFont fontWithName:@"Avenir-Roman" size:30.0]];
            [locationTitle setTextAlignment:NSTextAlignmentCenter];
            
            
            UITextView *location = [[UITextView alloc] initWithFrame:CGRectMake(8, locationTitle.frame.origin.y + locationTitle.frame.size.height + 10, self.view.frame.size.width - 8, 120)];
            [location setEditable:NO];
            [location setSelectable:NO];
            [location setText:@"We use location to spread posts to people near you."];
            [location setTextColor:[UIColor whiteColor]];
            [location setBackgroundColor:[UIColor clearColor]];
            [location setFont:[UIFont fontWithName:@"Avenir-Roman" size:18.0]];
            [location setTextAlignment:NSTextAlignmentCenter];
            
            UIButton *turnOnLoc = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 100, location.frame.origin.y + location.frame.size.height, 200, 80)];
            [turnOnLoc setTitle:@"Turn on" forState:UIControlStateNormal];
            [turnOnLoc setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [turnOnLoc setBackgroundColor:[UIColor colorWithRed:0/255.0f green:123.0f/255.0f blue:255.0f/255.0f alpha:1.0]];
            [turnOnLoc.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:20.0]];
            [turnOnLoc addTarget:self action:@selector(doneWasPressed:) forControlEvents:UIControlEventTouchUpInside];
            turnOnLoc.layer.cornerRadius = 10;
            turnOnLoc.clipsToBounds = YES;
            
            // add items
            [mapView addSubview:location];
            [mapView addSubview:turnOnLoc];
            [mapView addSubview:locationTitle];
            [self.tutorialScrollView addSubview:mapView];
            
            [self.tosButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.privacyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.tutorialScrollView.frame.size.width;
    int page = floor((self.tutorialScrollView.contentOffset.x - pageWidth) / pageWidth) + 1;
    if (page == 0)
    {
        [self.activityIndicator setHidden:YES];
        [self.textViewAccept setHidden: NO];
        [self.tosButton setHidden:NO];
        [self.privacyButton setHidden:NO];
        [self.andLabel setHidden:NO];
    }
    
    else
    {
        // change image view
        UIImage *newImage = [UIImage imageNamed:@"step2.png"];
        CGFloat newImageRatio = (float) newImage.size.height / newImage.size.width;
        self.backgroundImage.frame = CGRectMake(0, 0, (int)[UIScreen mainScreen].bounds.size.height / newImageRatio, [UIScreen mainScreen].bounds.size.height);
        [self.backgroundImage setImage:[UIImage imageNamed:@"step2.png"]];
        
        [self.textViewAccept setHidden: YES];
        [self.tosButton setHidden:YES];
        [self.privacyButton setHidden:YES];
        [self.andLabel setHidden:YES];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
    [self.activityIndicator setHidden:YES];
}


- (void)continueWasPressed
{
    // animate to next page
    [self.tutorialScrollView setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.width, 0) animated:YES];
}
- (IBAction)doneWasPressed:(id)sender
{
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
    
    // location
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager = locationManager;
    
    if ([CLLocationManager locationServicesEnabled])
    {
        // Find the current location
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
            // Being compiled with a Base SDK of iOS 8 or later
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.locationManager requestAlwaysAuthorization];
            } else {
                // No such method on this device - do something else as needed
            }
        #else
            // Being compiled with a Base SDK of iOS 7.x or earlier
            // No such method - do something else as needed
        #endif
        
    }
    
    
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    [userData setObject:[NSNumber numberWithBool:YES] forKey:@"isTutorialDone"];
    [userData synchronize];
    
    // [self performSegueWithIdentifier:@"unwindToHomeViewFromTutorial" sender:self];
}

#pragma mark - login stuff
- (IBAction)loginWasPressed:(id)sender
{
    RippleLogInView *loginViewController = [[RippleLogInView alloc] init];
    [loginViewController setDelegate:self];
    [loginViewController setFields:PFLogInFieldsDefault | PFLogInFieldsFacebook | PFLogInFieldsTwitter];
    [loginViewController setFacebookPermissions:[NSArray arrayWithObjects:@"email", @"user_about_me", nil]];

    // Create the sign up view controller
    RippleSignUpView *signUpViewController = [[RippleSignUpView alloc] init];
    [signUpViewController setDelegate:self];
    
    // Assign our sign up controller to be displayed from the login controller
    [loginViewController setSignUpController:signUpViewController];
    
    // Present the log in view controller
    [self presentViewController:loginViewController animated:YES completion:NULL];
}


- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    // Associate the device with a user
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation[@"user"] = [PFUser currentUser];
    [installation saveInBackground];
    
    if ([PFFacebookUtils isLinkedWithUser:user] && user[@"reach"]==nil)
    {
        [BellowService getEmailFromFacebook];
        [self presentUsernameAlert];
        
    }
    
    else if ([PFTwitterUtils isLinkedWithUser:user] && user[@"reach"] == nil)
    {
        [BellowService getEmailFromTwitter];
        [self presentUsernameAlert];
    }
    
    else
        [self dismissView];
}

- (void) presentUsernameAlert
{
    // we need to prompt them for a user name
    UIAlertView *usernameAlert = [[UIAlertView alloc]initWithTitle:@"Pick a username!" message:@"Your username will be shown everytime you start a ripple or comment on one.\n\nHave a referral code? Enter it as well." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    usernameAlert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [[usernameAlert textFieldAtIndex:1] setSecureTextEntry:NO];
    [[usernameAlert textFieldAtIndex:0] setPlaceholder:@"username"];
    [[usernameAlert textFieldAtIndex:1] setPlaceholder:@"referral code (optional)"];
    [usernameAlert show];
}

- (void) dismissView {
    
    // initiate user refresh
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        [[PFUser currentUser] fetch];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // initiate user user refresh
            [self dismissViewControllerAnimated:YES completion:^{
                [self performSegueWithIdentifier:@"unwindToHomeViewFromTutorial" sender:self];
            }];
        });
    });
}


// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    UIAlertView *failToLogInAlertView = [[UIAlertView alloc] initWithTitle:@"Failed to log in" message:[NSString stringWithFormat:@"%@", error.userInfo[@"error"]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [failToLogInAlertView show];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        [[PFUser currentUser] fetch];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // initiate user user refresh
            
            NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
            [userData setObject:[NSNumber numberWithBool:YES] forKey:@"isTutorialDone"];
            [userData synchronize];
            
            [[PFUser currentUser] setObject:[[PFUser currentUser].username lowercaseString] forKey:@"canonicalUsername"];
            
            NSArray *followingArray = [NSArray arrayWithObject:@"qqyvLOFvNT"];
            [[PFUser currentUser] setObject:followingArray forKey:@"following"];
            [[PFUser currentUser] saveInBackground];
            
            [self performSegueWithIdentifier:@"unwindToHomeViewFromTutorial" sender:self ];
        });
    });
    
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorized)
        [self performSegueWithIdentifier:@"unwindToHomeViewFromTutorial" sender:self];
    
    else if (status == kCLAuthorizationStatusDenied)
        [self performSegueWithIdentifier:@"unwindToHomeViewFromTutorial" sender:self];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark activy alert
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:@"Pick a username!"] || [alertView.title isEqualToString:@"This username is taken"] || [alertView.title isEqualToString:@"Invalid Username"])
    {
        if (![[[alertView textFieldAtIndex:0] text] isEqualToString:@""])
        {
            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                // make a call to see if username exists
                int check = [BellowService checkUsername:[[alertView textFieldAtIndex:0] text]];
                
                //referral
                if (![[alertView textFieldAtIndex:1].text isEqualToString:@""])
                {
                    self.referralNum = [BellowService acceptReferral:[alertView textFieldAtIndex:1].text];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (check == 1)
                    {
                        [[PFUser currentUser] setUsername:[[alertView textFieldAtIndex:0] text]];
                        [[PFUser currentUser] setObject:[[PFUser currentUser].username lowercaseString] forKey:@"canonicalUsername"];
                        [[PFUser currentUser] saveInBackground];
                        
                        
                        if (![[alertView textFieldAtIndex:1].text isEqualToString:@""])
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReferralAlert" object:[NSNumber numberWithInt: self.referralNum]];
                        
                        [self doneWasPressed:self];
                        //[self dismissView];
                    }
                    else
                    {
                        // we need to show again
                        UIAlertView *usernameError = [[UIAlertView alloc]initWithTitle:@"This username is taken" message:@"Choose another username.\n\nHave a referral code? Enter it as well." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        usernameError.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
                        [[usernameError textFieldAtIndex:1] setSecureTextEntry:NO];
                        [[usernameError textFieldAtIndex:0] setPlaceholder:@"username"];
                        [[usernameError textFieldAtIndex:1] setPlaceholder:@"referral code (optional)"];
                        [usernameError show];
                    }
                });
            });
        }
        
        else
        {
            // we need to show again
            UIAlertView *usernameInvalid = [[UIAlertView alloc]initWithTitle:@"Invalid Username" message:@"Choose another username.\n\nHave a referral code? Enter it as well." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            usernameInvalid.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
            [[usernameInvalid textFieldAtIndex:1] setSecureTextEntry:NO];
            [[usernameInvalid textFieldAtIndex:0] setPlaceholder:@"username"];
            [[usernameInvalid textFieldAtIndex:1] setPlaceholder:@"referral code (optional)"];
            [usernameInvalid show];
        }
        
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.tutorialScrollView.frame.size.width;
    int page = floor((self.tutorialScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    self.pageControl.currentPage = page;
    
    /*
     if (page == 1)
     {
     // [self.activityIndicator startAnimating];
     // [self.activityIndicator setHidden:NO];
     [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionAutoreverse animations:^{
     self.gif2WebView.alpha = 0.0;
     self.gif3WebView.alpha = 1.0;
     } completion:^(BOOL finished) {
     [self.gif2WebView removeFromSuperview];
     [self.gif3WebView removeFromSuperview];
     [self.tutorialScrollView addSubview:self.gif3WebView];
     // noop
     }];
     
     }
     
     
     if (page == 2)
     {
     // [self.activityIndicator startAnimating];
     // [self.activityIndicator setHidden:NO];
     [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionAutoreverse animations:^{
     self.gif2WebView.alpha = 1.0;
     self.gif3WebView.alpha = 0.0;
     } completion:^(BOOL finished) {
     [self.gif3WebView removeFromSuperview];
     [self.gif2WebView removeFromSuperview];
     [self.tutorialScrollView addSubview:self.gif2WebView];
     // noop
     }];
     }
     */
}
/*
 // Update the page when more than 50% of the previous/next page is visible
 CGFloat pageWidth = self.tutorialScrollView.frame.size.width;
 int page = floor((self.tutorialScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
 
 if (page == self.pageControl.currentPage)
 return;
 
 if (page == 0)
 {
 // [self.activityIndicator startAnimating];
 // [self.activityIndicator setHidden:NO];
 [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionAutoreverse animations:^{
 self.gif0WebView.alpha = 1.0;
 self.gif1WebView.alpha = 0.0;
 self.gif2WebView.alpha = 0.0;
 self.gif3WebView.alpha = 0.0;
 } completion:^(BOOL finished) {
 [self.gif0WebView removeFromSuperview];
 [self.gif1WebView removeFromSuperview];
 [self.gif2WebView removeFromSuperview];
 [self.gif3WebView removeFromSuperview];
 [self.tutorialScrollView addSubview:self.gif0WebView];
 // noop
 }];
 
 }
 
 
 if (page == 1)
 {
 // [self.activityIndicator startAnimating];
 // [self.activityIndicator setHidden:NO];
 [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionAutoreverse animations:^{
 self.gif0WebView.alpha = 0.0;
 self.gif1WebView.alpha = 1.0;
 self.gif2WebView.alpha = 0.0;
 self.gif3WebView.alpha = 0.0;
 } completion:^(BOOL finished) {
 [self.gif0WebView removeFromSuperview];
 [self.gif1WebView removeFromSuperview];
 [self.gif2WebView removeFromSuperview];
 [self.gif3WebView removeFromSuperview];
 [self.tutorialScrollView addSubview:self.gif1WebView];
 // noop
 }];
 }
 
 
 if (page == 2)
 {
 // [self.activityIndicator startAnimating];
 // [self.activityIndicator setHidden:NO];
 [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionAutoreverse animations:^{
 self.gif0WebView.alpha = 0.0;
 self.gif1WebView.alpha = 0.0;
 self.gif2WebView.alpha = 1.0;
 self.gif3WebView.alpha = 0.0;
 } completion:^(BOOL finished) {
 [self.gif0WebView removeFromSuperview];
 [self.gif1WebView removeFromSuperview];
 [self.gif2WebView removeFromSuperview];
 [self.gif3WebView removeFromSuperview];
 [self.tutorialScrollView addSubview:self.gif2WebView];
 // noop
 }];
 }
 
 if (page == 3)
 {
 // [self.activityIndicator startAnimating];
 // [self.activityIndicator setHidden:NO];
 [UIView animateWithDuration:0.25 animations:^{
 self.gif0WebView.alpha = 0.0;
 self.gif1WebView.alpha = 0.0;
 self.gif2WebView.alpha = 0.0;
 self.gif3WebView.alpha = 1.0;
 } completion:^(BOOL finished) {
 [self.gif0WebView removeFromSuperview];
 [self.gif1WebView removeFromSuperview];
 [self.gif2WebView removeFromSuperview];
 [self.gif3WebView removeFromSuperview];
 [self.tutorialScrollView addSubview:self.gif3WebView];
 // noop
 }];
 }
 
 if (page == 4)
 {
 
 [UIView animateWithDuration:0.25 animations:^{
 self.gif0WebView.alpha = 0.0;
 self.gif1WebView.alpha = 0.0;
 self.gif2WebView.alpha = 0.0;
 self.gif3WebView.alpha = 0.0;
 } completion:^(BOOL finished) {
 [self.gif0WebView removeFromSuperview];
 [self.gif1WebView removeFromSuperview];
 [self.gif2WebView removeFromSuperview];
 [self.gif3WebView removeFromSuperview];
 }];
 
 }
 self.pageControl.currentPage = page;
 }*/



@end
