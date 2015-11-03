//
//  KefiSignUpView.m
//  Kefi
//
//  Created by Gal Oshri on 6/15/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "RippleSignUpView.h"

@interface RippleSignUpView ()

@end

@implementation RippleSignUpView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.signUpView.backgroundColor = [UIColor colorWithRed:43.0f/255 green:132.0f/255 blue:219/255.0f alpha:1.0];
     
    // create label for logo
    UILabel *logoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,150, 50)];
    [logoLabel setFont:[UIFont fontWithName:@"Avenir" size:40.0]];
    logoLabel.text = @"Bellow";
    logoLabel.textColor = [UIColor whiteColor];
    logoLabel.textAlignment = NSTextAlignmentCenter;
    [self.signUpView setLogo:logoLabel];
    
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.signUpView.signUpButton setBackgroundColor:[UIColor colorWithRed:23/255.0 green:93/255.0 blue:195/255.0 alpha:1.0]];
    
    // Remove text shadow
    CALayer *layer = self.signUpView.usernameField.layer;
    layer.shadowOpacity = 0.0;
    layer = self.signUpView.passwordField.layer;
    layer.shadowOpacity = 0.0;
    layer = self.signUpView.signUpButton.layer;
    layer.shadowOpacity = 0.0;
    layer = self.signUpView.emailField.layer;
    layer.shadowOpacity = 0.0;
    
    /*
    // Set buttons appearance
    [self.logInView.facebookButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.facebookButton setImage:nil forState:UIControlStateHighlighted];
    [self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"facebook_down.png"] forState:UIControlStateHighlighted];
    [self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"facebook.png"] forState:UIControlStateNormal];
    [self.logInView.facebookButton setTitle:@"" forState:UIControlStateNormal];
    [self.logInView.facebookButton setTitle:@"" forState:UIControlStateHighlighted];
     
    [self.logInView.twitterButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.twitterButton setImage:nil forState:UIControlStateHighlighted];
    [self.logInView.twitterButton setBackgroundImage:[UIImage imageNamed:@"twitter.png"] forState:UIControlStateNormal];
    [self.logInView.twitterButton setBackgroundImage:[UIImage imageNamed:@"twitter_down.png"] forState:UIControlStateHighlighted];
    [self.logInView.twitterButton setTitle:@"" forState:UIControlStateNormal];
    [self.logInView.twitterButton setTitle:@"" forState:UIControlStateHighlighted];
     
    [self.logInView.signUpButton setTitle:@"" forState:UIControlStateNormal];
    [self.logInView.signUpButton setTitle:@"" forState:UIControlStateHighlighted];
    */
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // additionall field
    self.signUpView.additionalField.frame = CGRectMake(self.signUpView.center.x - (self.signUpView.frame.size.width - 40)/2, [UIScreen mainScreen].bounds.size.height-140, self.signUpView.frame.size.width - 40, self.signUpView.emailField.frame.size.height);
    
    // textview to explain referral code
    UITextView *referralText = [[UITextView alloc] init];
    referralText.frame = CGRectMake(self.signUpView.additionalField.frame.origin.x, self.signUpView.additionalField.frame.origin.y - 30, self.signUpView.additionalField.frame.size.width, 30);
    
    [referralText setEditable:NO];
    [referralText setSelectable:NO];
    [referralText setScrollEnabled:NO];
    
    [referralText setText:@"Have a referral code?"];
    [referralText setTextColor:[UIColor whiteColor]];
    [referralText setBackgroundColor:[UIColor clearColor]];
    [referralText setFont:[UIFont fontWithName:@"Avenir-Roman" size:13.0]];
    
    [self.signUpView addSubview:referralText];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [[self.signUpView.usernameField layer] setBorderColor:[[UIColor whiteColor] CGColor]];
    [[self.signUpView.passwordField layer] setBorderColor:[[UIColor whiteColor] CGColor]];
    [[self.signUpView.emailField layer] setBorderColor:[[UIColor whiteColor] CGColor]];
    
    [[self.signUpView.usernameField layer] setBorderWidth:1.0];
    [[self.signUpView.passwordField layer] setBorderWidth:1.0];
    [[self.signUpView.emailField layer] setBorderWidth:1.0];
    
    self.signUpView.usernameField.frame = CGRectMake(self.signUpView.center.x - (self.signUpView.frame.size.width - 40)/2, self.signUpView.usernameField.frame.origin.y - 25.0, self.signUpView.usernameField.frame.size.width - 40, self.signUpView.usernameField.frame.size.height);
    self.signUpView.passwordField.frame = CGRectMake(self.signUpView.center.x - (self.signUpView.frame.size.width - 40)/2, self.signUpView.passwordField.frame.origin.y - 15 , self.signUpView.passwordField.frame.size.width - 40, self.signUpView.passwordField.frame.size.height);
    self.signUpView.emailField.frame = CGRectMake(self.signUpView.center.x - (self.signUpView.frame.size.width - 40)/2, self.signUpView.emailField.frame.origin.y - 5 , self.signUpView.emailField.frame.size.width - 40, self.signUpView.emailField.frame.size.height);
    self.signUpView.signUpButton.frame = CGRectMake(self.signUpView.center.x - (self.signUpView.frame.size.width - 40)/2, [UIScreen mainScreen].bounds.size.height-80, self.signUpView.frame.size.width - 40, self.signUpView.signUpButton.frame.size.height);
    self.signUpView.logo.frame = CGRectMake(self.signUpView.logo.frame.origin.x, self.signUpView.logo.frame.origin.y - 40, self.signUpView.logo.frame.size.width, self.signUpView.logo.frame.size.height);
    
    // place holders
    self.signUpView.emailField.placeholder = @"Email";
    self.signUpView.additionalField.placeholder = @"Referral Code (optional)";
    
    // dismiss button
    [self.signUpView.dismissButton setFrame:CGRectMake(self.view.frame.size.width - 45, 35.0f, 25,25)];
    [self.signUpView.dismissButton setImage:[UIImage imageNamed:@"dismissButtonGray.png"] forState:UIControlStateNormal];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.signUpView.dismissButton setHidden:YES];
    [self.signUpView.logo setHidden:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.signUpView.dismissButton setHidden:NO];
    [self.signUpView.logo setHidden:NO];
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}


@end
