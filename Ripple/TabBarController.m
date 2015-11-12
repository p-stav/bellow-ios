//
//  TabBarController.m
//  Bellow
//
//  Created by Paul Stavropoulos on 4/21/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import "Flurry.h"
#import "TabBarController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "RippleLogInView.h"
#import "BellowService.h"
#import "RippleSignUpView.h"
#import <ParseFacebookUtilsV4/ParseFacebookUtilsV4.h>
#import <ParseTwitterUtils/ParseTwitterUtils.h>

@interface TabBarController ()
@property (nonatomic) int referralNum;
@property (strong, nonatomic) UIButton *button;
@property (nonatomic) float tabBarHidden;
@property (nonatomic) float tabBarShowing;
@property (nonatomic) BOOL interactionDisabled;



@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.delegate = self;
    self.interactionDisabled = NO;
    
    //UIImage *pink = [UIImage imageNamed:@"redCompose.png"];
    //[[[UITabBar appearance].items objectAtIndex:2] setBackgroundImage:pink];
    
    //add button to view
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.frame = CGRectMake(0.0, 0.0, 50, 50);
    [self.button setBackgroundImage:[UIImage imageNamed:@"redCompose.png"] forState:UIControlStateNormal];
    
    CGPoint center = self.tabBar.center;
    center.y = center.y + 0.5;
    self.button.center = center;
    [self.button setTag:100];
    
    [self.button addTarget:self action:@selector(pressedButton) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.button];
    
    
    // set every tab bar item
    [[[UITabBar appearance].items objectAtIndex:0] setImageInsets:UIEdgeInsetsMake(9, 0, -9, 0)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideTabBar) name:@"hideTabBar" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTabBar) name:@"showTabBar" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLogInAndSignUpViewProfile) name:@"showLoginSignup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inactiveTabBar) name:@"inactiveTabBarController" object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    float tabBarHeight = self.tabBar.frame.size.height;
    self.tabBarHidden = tabBarHeight + self.tabBar.frame.origin.y;
    self.tabBarShowing = self.tabBar.frame.origin.y;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if (!self.interactionDisabled)
    {
        if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
            return NO;
        else if ([viewController.title isEqualToString:@"Start A Post"])
            return NO;
        
        else if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]] && [viewController.title isEqualToString:@"MeNavController"])
        {
            // login controller & present alert
            UIAlertView *signIn = [[UIAlertView alloc] initWithTitle:@"Login or Sign up!" message:@"Login or sign up to see your profile!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            
            [signIn show];
            [self showLogInAndSignUpView];
            return NO;
        }
        
        return YES;
    }
    
    else
        return NO;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if ([item isEqual:[self.tabBar.items objectAtIndex:0]])
        [Flurry logEvent:@"View_Home"];
    else if ([item isEqual:[self.tabBar.items objectAtIndex:1]])
        [Flurry logEvent:@"View_Explore"];
    else if ([item isEqual:[self.tabBar.items objectAtIndex:3]])
        [Flurry logEvent:@"View_Notifications"];
    else if ([item isEqual:[self.tabBar.items objectAtIndex:4]])
        [Flurry logEvent:@"View_Profile"];
}

- (void)pressedButton
{
    
    if ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)) //&& [CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined))
    {
        if (self.tabBar.alpha == 1)
        {
            if ([PFUser currentUser][@"reach"] != nil && ![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]])
            {
                // present modal window
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UITabBarController *obj=[storyboard instantiateViewControllerWithIdentifier:@"Start A Post"];
                // self.navigationController.navigationBarHidden=NO;
                [self presentViewController:obj animated:YES completion:nil];
            }
            
            else
            {
                UIAlertView *signInPlease = [[UIAlertView alloc] initWithTitle:@"Login or sign up!" message:@"You must have an account to create posts" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [self showLogInAndSignUpView];
                [signInPlease show];

                [self showLogInAndSignUpView];
            }
        }
    }
}


#pragma Mark - login and signup
- (void)showLogInAndSignUpViewProfile
{
    UIAlertView *signIn = [[UIAlertView alloc] initWithTitle:@"Login or Sign up!" message:@"Login or sign up to see your profile!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [signIn show];
    
    [self showLogInAndSignUpView];
}
- (void)showLogInAndSignUpView
{
    // Create the log in view controller
    RippleLogInView *logInViewController = [[RippleLogInView alloc] init];
    [logInViewController setDelegate:self]; // Set ourselves as the delegate
    
    [logInViewController setFields: PFLogInFieldsDefault | PFLogInFieldsFacebook | PFLogInFieldsTwitter];
    
    // Create the sign up view controller
    RippleSignUpView *signUpViewController = [[RippleSignUpView alloc] init];
    
    [signUpViewController setDelegate:self]; // Set ourselves as the delegate
    signUpViewController.fields = (PFSignUpFieldsUsernameAndPassword | PFSignUpFieldsSignUpButton | PFSignUpFieldsEmail | PFSignUpFieldsAdditional | PFSignUpFieldsDismissButton);

    // Assign our sign up controller to be displayed from the login controller
    [logInViewController setSignUpController:signUpViewController];
    
    // Present the log in view controller
    [self presentViewController:logInViewController animated:YES completion:NULL];
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    
    // Associate the device with a user
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation[@"user"] = [PFUser currentUser];
    [installation saveInBackground];
    
    if ([PFFacebookUtils isLinkedWithUser:user] && user[@"canonicalUsername"] == nil)
    {
        [BellowService getEmailFromFacebook];
        [self presentUsernameAlert];
    }
    
    else if([PFTwitterUtils isLinkedWithUser:user] && user[@"canonicalUsername"] == nil)
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
    UIAlertView *usernameAlert = [[UIAlertView alloc]initWithTitle:@"Pick a username!" message:@"Your username will be shown everytime you create a post or comment on one.\n\nHave a referral code? Enter it as well." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    usernameAlert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [[usernameAlert textFieldAtIndex:1] setSecureTextEntry:NO];
    [[usernameAlert textFieldAtIndex:0] setPlaceholder:@"username"];
    [[usernameAlert textFieldAtIndex:1] setPlaceholder:@"referral code (optional)"];
    [usernameAlert show];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    UIAlertView *failToLogInAlertView = [[UIAlertView alloc] initWithTitle:@"Failed to log in" message:[NSString stringWithFormat:@"%@", error.userInfo[@"error"]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [failToLogInAlertView show];
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    //referral
    if (![[PFUser currentUser][@"additional"] isEqualToString:@""])
    {
       self.referralNum = [BellowService acceptReferral:[PFUser currentUser][@"additional"]];
    }
    
    // initiate user user refresh
    [[NSNotificationCenter defaultCenter] postNotificationName:@"justLoggedIn" object:nil];
    
    if (![[PFUser currentUser][@"additional"] isEqualToString:@""])
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReferralAlert" object:[NSNumber numberWithInt: self.referralNum]];

    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSString *lowercase = [[PFUser currentUser].username lowercaseString];
    [[PFUser currentUser] setObject:lowercase forKey:@"canonicalUsername"];
    
    [[PFUser currentUser] saveInBackground];
}


- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error
{
    
}


- (IBAction)loginSignupFromProfile:(id)sender
{
    [self showLogInAndSignUpView];
}

#pragma mark activy alert and dismissing
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
                    self.referralNum = [BellowService acceptReferral:[alertView textFieldAtIndex:1].text ];
                }

                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (check == 1)
                    {
                        [[PFUser currentUser] setUsername:[[alertView textFieldAtIndex:0] text]];
                        [[PFUser currentUser] setObject:[[PFUser currentUser].username lowercaseString] forKey:@"canonicalUsername"];
                        [[PFUser currentUser] saveInBackground];
                        
                        if (![[alertView textFieldAtIndex:0].text isEqualToString:@""])
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReferralAlert" object:[NSNumber numberWithInt: self.referralNum]];
                        
                        [self dismissView];
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

- (void) dismissView{
    
    // initiate user refresh
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        [[PFUser currentUser] fetch];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // initiate user user refresh
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    });
}

- (void)hideTabBar{
    [UIView animateWithDuration:0.5 animations:^{
        self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x, self.tabBarHidden, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
    }];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.button.frame = CGRectMake(self.button.frame.origin.x, self.tabBarHidden, self.button.frame.size.width, self.button.frame.size.height);
    }];
}

- (void)showTabBar {
    [UIView animateWithDuration:0.5 animations:^{
        self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x, self.view.frame.size.height - self.tabBar.frame.size.height, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
    }];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.button.frame = CGRectMake(self.button.frame.origin.x, self.view.frame.size.height - self.tabBar.frame.size.height, self.button.frame.size.width, self.button.frame.size.height);
    }];
    
    [self.tabBar setHidden:NO];
}

- (void) inactiveTabBar
{
    if (self.interactionDisabled)
    {
        self.interactionDisabled = NO;
        [self.tabBar setAlpha:1.0];
        [self.button setAlpha:1.0];
    }
    else
    {
        self.interactionDisabled = YES;
        [self.tabBar setAlpha:0.5];
        [self.button setAlpha:0.5];
    }
}

@end
