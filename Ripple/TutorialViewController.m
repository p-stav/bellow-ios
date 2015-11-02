///
//  TutorialViewController.m
//  Ripple
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
#include "RippleService.h"



@interface TutorialViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textViewAccept;
@property (weak, nonatomic) IBOutlet UIButton *tosButton;
@property (weak, nonatomic) IBOutlet UILabel *andLabel;
@property (weak, nonatomic) IBOutlet UIButton *privacyButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *headerview;
@property (weak, nonatomic) IBOutlet UIView *bottomView;


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
    self.numTutorialPages = 4;
    [self.pageControl setNumberOfPages:4];
    
    // add border to view
    [self.view setBackgroundColor:[UIColor colorWithRed:8/255.0f green:103.0f/255.0f blue:171.0f/255.0f alpha:1.0]];
    [self.headerview setBackgroundColor:[UIColor colorWithRed:8/255.0f green:103.0f/255.0f blue:171.0f/255.0f alpha:1.0]];
    [self.bottomView setBackgroundColor:[UIColor colorWithRed:8/255.0f green:103.0f/255.0f blue:171.0f/255.0f alpha:1.0]];
    [self.tutorialScrollView setBackgroundColor:[UIColor colorWithRed:8/255.0f green:103.0f/255.0f blue:171.0f/255.0f alpha:1.0]];
    
    // [self.view.layer setBorderWidth:8.0];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tutorialScrollView.contentSize = CGSizeMake(self.view.frame.size.width * self.numTutorialPages, self.tutorialScrollView.frame.size.height);
    [self.activityIndicator startAnimating];
    
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
        [tutorialView setBackgroundColor:[UIColor colorWithRed:8/255.0f green:103.0f/255.0f blue:171.0f/255.0f alpha:1.0]];
        
        if (i==0)
        {
            self.imageView0 = [[UIImageView alloc] init];
            
            if ([UIScreen mainScreen].bounds.size.height <=480) {
                self.imageView0.frame = CGRectMake(10, 60, [UIScreen mainScreen].bounds.size.width - 20, [UIScreen mainScreen].bounds.size.width - 20);
            }
            else
                self.imageView0.frame = CGRectMake(1, [UIScreen mainScreen].bounds.size.width/4+20, [UIScreen mainScreen].bounds.size.width - 3, [UIScreen mainScreen].bounds.size.width);
            
            [self.imageView0 setImage:[UIImage imageNamed:@"step1.png"]];
            
            // add textview
            UITextView *rippleIntro = [[UITextView alloc] initWithFrame:CGRectMake(4, self.imageView0.frame.origin.y - 60, self.view.frame.size.width - 8, 120)];
            [rippleIntro setEditable:NO];
            [rippleIntro setSelectable:NO];
            
            [rippleIntro setText:@"Ripple spreads your messages around the world"];
            [rippleIntro setTextColor:[UIColor whiteColor]];
            [rippleIntro setBackgroundColor:[UIColor clearColor]];
            [rippleIntro setFont:[UIFont fontWithName:@"Avenir-Roman" size:18.0]];
            [rippleIntro setTextAlignment:NSTextAlignmentCenter];
            
            
            UITextView *startRipple = [[UITextView alloc] initWithFrame:CGRectMake(4, self.imageView0.frame.origin.y + self.imageView0.frame.size.height, self.view.frame.size.width - 8, 120)];
            [startRipple setEditable:NO];
            [startRipple setSelectable:NO];
            
            [startRipple setText:@"Start a ripple. It spreads to people nearby"];
            [startRipple setTextColor:[UIColor whiteColor]];
            [startRipple setBackgroundColor:[UIColor clearColor]];
            [startRipple setFont:[UIFont fontWithName:@"Avenir-Roman" size:18.0]];
            [startRipple setTextAlignment:NSTextAlignmentCenter];
            
            //[self..scrollView setScrollEnabled:NO];
            //[self.gif0WebView setBackgroundColor:[UIColor clearColor]];
            //[self.gif0WebView setOpaque:NO];
            /*
             //add uiwebview with gif
             CGFloat aspectRatio  = 1.5625;
             NSString *filePath = [[NSBundle mainBundle] pathForResource:@"rippleMapGif" ofType:@"gif"];
             NSURL *gifURL	 = [NSURL fileURLWithPath:filePath];
             NSString *gifString = @"<html><body><img src='%@' width='%fpx' height='%fpx'></body></html>";
             NSString *gifHTML  = [[NSString alloc] initWithFormat:gifString, gifURL, frame.size.width, (frame.size.width) * aspectRatio];
             
             [self.gif0WebView loadHTMLString:gifHTML baseURL:nil];
             [self.gif0WebView setUserInteractionEnabled:NO];
             self.gif0WebView.delegate = self;*/
            
            [self.tutorialScrollView addSubview:self.imageView0];
            [self.tutorialScrollView addSubview:rippleIntro];
            [self.tutorialScrollView addSubview:startRipple];
            
        }
        
        /*if (i==1)
         {
         self.imageView1 = [[UIImageView alloc] init];
         
         if ([UIScreen mainScreen].bounds.size.height <=480) {
         self.imageView1.frame = CGRectMake(frame.origin.x + 10, 60, [UIScreen mainScreen].bounds.size.width - 20, [UIScreen mainScreen].bounds.size.width - 20);
         }
         else
         self.imageView1.frame = CGRectMake(frame.origin.x + 1, [UIScreen mainScreen].bounds.size.width/4+20, [UIScreen mainScreen].bounds.size.width - 2, [UIScreen mainScreen].bounds.size.width - 2);
         
         [self.imageView1 setImage:[UIImage imageNamed:@"step2.png"]];
         
         // add text
         UITextView *spread = [[UITextView alloc] initWithFrame:CGRectMake(frame.origin.x + 8, self.imageView1.frame.origin.y + self.imageView1.frame.size.height, self.view.frame.size.width - 8, 120)];
         [spread setEditable:NO];
         [spread setSelectable:NO];
         
         [spread setText:@"People can dismiss a ripple or spread it to others near them"];
         [spread setTextColor:[UIColor whiteColor]];
         [spread setBackgroundColor:[UIColor clearColor]];
         [spread setFont:[UIFont fontWithName:@"Avenir-Roman" size:18.0]];
         [spread setTextAlignment:NSTextAlignmentCenter];
         
         [self.tutorialScrollView addSubview:self.imageView1];
         [self.tutorialScrollView addSubview:spread];
         
         }
         
         
         if (i==2)
         {
         self.imageView2 = [[UIImageView alloc] init];
         
         if ([UIScreen mainScreen].bounds.size.height <=480) {
         self.imageView2.frame = CGRectMake(frame.origin.x + 10, 60, [UIScreen mainScreen].bounds.size.width - 20, [UIScreen mainScreen].bounds.size.width - 20);
         }
         else
         self.imageView2.frame = CGRectMake(frame.origin.x + 1, [UIScreen mainScreen].bounds.size.width/4+20, [UIScreen mainScreen].bounds.size.width - 2, [UIScreen mainScreen].bounds.size.width - 2);
         
         [self.imageView2 setImage:[UIImage imageNamed:@"step3.png"]];
         
         
         
         // textview
         UITextView *world = [[UITextView alloc] initWithFrame:CGRectMake(frame.origin.x, self.imageView2.frame.origin.y + self.imageView2.frame.size.height, self.view.frame.size.width, 120)];
         [world setEditable:NO];
         [world setSelectable:NO];
         [world setText:@"Watch your ripples spread across the world"];
         [world setTextColor:[UIColor whiteColor]];
         [world setBackgroundColor:[UIColor clearColor]];
         [world setFont:[UIFont fontWithName:@"Avenir-Roman" size:18.0]];
         [world setTextAlignment:NSTextAlignmentCenter];
         
         [self.tutorialScrollView addSubview:self.imageView2];
         [self.tutorialScrollView addSubview:world];
         
         }*/
        
        
        if (i==1)
        {
            
            self.gif3WebView = [[UIWebView alloc] init];
            
            if ([UIScreen mainScreen].bounds.size.height <=480)
                self.gif3WebView.frame= CGRectMake(frame.origin.x - 4, [UIScreen mainScreen].bounds.size.width/4 - 50, frame.size.width, 700);
            else
                self.gif3WebView.frame= CGRectMake(frame.origin.x - 4, [UIScreen mainScreen].bounds.size.width/4 - 3, frame.size.width, 700);
            
            //add uiwebview with gif
            CGFloat aspectRatio  = 1.0;
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"spreadDismiss" ofType:@"gif"];
            NSURL *gifURL = [NSURL fileURLWithPath:filePath];
            NSString *gifString = @"<html><body><img src='%@' width='%fpx' height='%fpx'></body></html>";
            NSString *gifHTML  = [[NSString alloc] initWithFormat:gifString, gifURL, self.view.frame.size.width, (self.view.frame.size.width) * aspectRatio];//, frame.size.width, frame.size.width / aspectRatio];
            
            [self.gif3WebView setUserInteractionEnabled:NO];
            [self.gif3WebView loadHTMLString:gifHTML baseURL:nil];
            [self.gif3WebView setBackgroundColor:[UIColor clearColor]];
            [self.gif3WebView setOpaque:NO];
            self.gif3WebView.delegate = self;
            [self.tutorialScrollView addSubview:self.gif3WebView];
            [self.gif3WebView setAlpha:1.0];
            
            // add text
            UITextView *spreadDismiss = [[UITextView alloc] initWithFrame:CGRectMake(frame.origin.x + 4, self.imageView0.frame.origin.y + self.imageView0.frame.size.height, self.view.frame.size.width - 8, 120)];
            [spreadDismiss setEditable:NO];
            [spreadDismiss setSelectable:NO];
            
            [spreadDismiss setText:@"Swipe a post right to spread it to more people. Swipe left to dismiss it"];
            [spreadDismiss setTextColor:[UIColor whiteColor]];
            [spreadDismiss setBackgroundColor:[UIColor clearColor]];
            [spreadDismiss setFont:[UIFont fontWithName:@"Avenir-Roman" size:18.0]];
            [spreadDismiss setTextAlignment:NSTextAlignmentCenter];
            
            [self.tutorialScrollView addSubview:spreadDismiss];
            
            UITextView *otherPeople = [[UITextView alloc] initWithFrame:CGRectMake(frame.origin.x + 4, self.imageView0.frame.origin.y - 60, self.view.frame.size.width - 8, 120)];
            [otherPeople setEditable:NO];
            [otherPeople setSelectable:NO];
            
            [otherPeople setText:@"You also receive posts from other people."];
            [otherPeople setTextColor:[UIColor whiteColor]];
            [otherPeople setBackgroundColor:[UIColor clearColor]];
            [otherPeople setFont:[UIFont fontWithName:@"Avenir-Roman" size:18.0]];
            [otherPeople setTextAlignment:NSTextAlignmentCenter];
            
            [self.tutorialScrollView addSubview:otherPeople];
            
        }
        
        
        if (i==2) {
            self.gif2WebView = [[UIWebView alloc] init];
            
            if ([UIScreen mainScreen].bounds.size.height <=480)
                self.gif2WebView.frame= CGRectMake(frame.origin.x - 4, [UIScreen mainScreen].bounds.size.width/4 - 50, frame.size.width, 700);
            else
                self.gif2WebView.frame= CGRectMake(frame.origin.x - 4, [UIScreen mainScreen].bounds.size.width/4 + 5, frame.size.width, 700);
            
            //add uiwebview with gif
            CGFloat aspectRatio  = 1.0;
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"mapView" ofType:@"gif"];
            NSURL *gifURL = [NSURL fileURLWithPath:filePath];
            NSString *gifString = @"<html><body><img src='%@' width='%fpx' height='%fpx'></body></html>";
            NSString *gifHTML  = [[NSString alloc] initWithFormat:gifString, gifURL, self.view.frame.size.width, (self.view.frame.size.width) * aspectRatio];//, frame.size.width, frame.size.width / aspectRatio];
            
            [self.gif2WebView setUserInteractionEnabled:NO];
            [self.gif2WebView loadHTMLString:gifHTML baseURL:nil];
            [self.gif2WebView setBackgroundColor:[UIColor clearColor]];
            [self.gif2WebView setOpaque:NO];
            self.gif2WebView.delegate = self;
            [self.tutorialScrollView addSubview:self.gif2WebView];
            [self.gif2WebView setAlpha:1.0];
            
            // add text
            UITextView *spreadDismiss = [[UITextView alloc] initWithFrame:CGRectMake(frame.origin.x + 8, self.imageView0.frame.origin.y + self.imageView0.frame.size.height, self.view.frame.size.width - 8, 120)];
            [spreadDismiss setEditable:NO];
            [spreadDismiss setSelectable:NO];
            
            [spreadDismiss setText:@"You can also comment here."];
            [spreadDismiss setTextColor:[UIColor whiteColor]];
            [spreadDismiss setBackgroundColor:[UIColor clearColor]];
            [spreadDismiss setFont:[UIFont fontWithName:@"Avenir-Roman" size:18.0]];
            [spreadDismiss setTextAlignment:NSTextAlignmentCenter];
            
            [self.tutorialScrollView addSubview:spreadDismiss];
            
            UITextView *comment = [[UITextView alloc] initWithFrame:CGRectMake(frame.origin.x + 8, self.imageView0.frame.origin.y - 60, self.view.frame.size.width - 8, 120)];
            [comment setEditable:NO];
            [comment setSelectable:NO];
            
            [comment setText:@"Tap a ripple to see a map of where it spread."];
            [comment setTextColor:[UIColor whiteColor]];
            [comment setBackgroundColor:[UIColor clearColor]];
            [comment setFont:[UIFont fontWithName:@"Avenir-Roman" size:18.0]];
            [comment setTextAlignment:NSTextAlignmentCenter];
            
            [self.tutorialScrollView addSubview:comment];
        }
        
        if (i == 3)
        {
            UIView *blueView = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
            [blueView setBackgroundColor:[UIColor colorWithRed:8/255.0f green:103.0f/255.0f blue:171.0f/255.0f alpha:1.0]];
            
            // add logo button button
            UIButton *logo = [[UIButton alloc] initWithFrame:CGRectMake(blueView.frame.size.width/2 -35, 60, 70, 70)];
            [logo addTarget:self action:@selector(doneWasPressed:) forControlEvents:UIControlEventTouchUpInside];
            [logo setImage:[UIImage imageNamed:@"latestIcon.png"] forState:UIControlStateNormal];
            
            logo.layer.shadowOpacity = 1.0f;
            [logo.layer setShadowColor:[[UIColor blackColor] CGColor]];
            [logo.layer setShadowOffset:CGSizeMake(0,0)];
            [logo.layer setCornerRadius:25.0f];
            
            
            // add start and explore
            UITextView *location = [[UITextView alloc] initWithFrame:CGRectMake(8, 100, self.view.frame.size.width - 8, 220)];
            [location setEditable:NO];
            [location setSelectable:NO];
            
            [location setText:@"We use location to share and spread ripples with people nearby.\n\nWe never share your exact location."];
            [location setTextColor:[UIColor whiteColor]];
            [location setBackgroundColor:[UIColor clearColor]];
            [location setFont:[UIFont fontWithName:@"Avenir-Roman" size:18.0]];
            [location setTextAlignment:NSTextAlignmentCenter];
            
            UIButton *turnOnLoc = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 100, 250, 200, 50)];
            [turnOnLoc setTitle:@"Turn on location" forState:UIControlStateNormal];
            [turnOnLoc setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [turnOnLoc setBackgroundColor:[UIColor colorWithRed:3/255.0f green:73/255.0f blue:119/255.0f alpha:1.0]];
            [turnOnLoc.titleLabel setFont:[UIFont fontWithName:@"Avenir-Roman" size:16.0]];
            [turnOnLoc addTarget:self action:@selector(doneWasPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            turnOnLoc.layer.cornerRadius = 10; // this value vary as per your desire
            turnOnLoc.clipsToBounds = YES;
            
            // add items
            //[blueView addSubview:logo];
            [blueView addSubview:location];
            [blueView addSubview:turnOnLoc
             ];
            [self.tutorialScrollView addSubview:blueView];
            
            [self.tosButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.privacyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.tutorialScrollView.frame.size.width;
    int page = floor((self.tutorialScrollView.contentOffset.x - pageWidth) / pageWidth) + 1;
    if (page == 3)
    {
        [self.activityIndicator setHidden:YES];
        [self.textViewAccept setHidden: NO];
        [self.tosButton setHidden:NO];
        [self.privacyButton setHidden:NO];
        [self.andLabel setHidden:NO];
        [self.loginLabel setHidden:NO];
        [self.loginButton setHidden:NO];
    }
    
    else
    {
        [self.textViewAccept setHidden: YES];
        [self.tosButton setHidden:YES];
        [self.privacyButton setHidden:YES];
        [self.andLabel setHidden:YES];
        [self.loginLabel setHidden:YES];
        [self.loginButton setHidden:YES];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
    [self.activityIndicator setHidden:YES];
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
        [RippleService getEmailFromFacebook];
        [self presentUsernameAlert];
        
    }
    
    else if ([PFTwitterUtils isLinkedWithUser:user] && user[@"reach"] == nil)
    {
        [RippleService getEmailFromTwitter];
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
                int check = [RippleService checkUsername:[[alertView textFieldAtIndex:0] text]];
                
                //referral
                if (![[alertView textFieldAtIndex:1].text isEqualToString:@""])
                {
                    self.referralNum = [RippleService acceptReferral:[alertView textFieldAtIndex:1].text];
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

@end
