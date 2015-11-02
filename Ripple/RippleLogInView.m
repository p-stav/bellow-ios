//
//  KefiLogInView.m
//  Kefi
//
//  Created by Gal Oshri on 6/15/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "RippleLogInView.h"
#import <QuartzCore/QuartzCore.h>

@interface RippleLogInView ()

@end

@implementation RippleLogInView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.logInView.backgroundColor = [UIColor colorWithRed:43.0f/255 green:132.0f/255 blue:219/255.0f alpha:1.0];
    
    // create label for logo
    UILabel *logoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,-30,150, 50)];
    [logoLabel setFont:[UIFont fontWithName:@"Avenir" size:40.0]];
    logoLabel.text = @"Ripple";
    logoLabel.textColor = [UIColor whiteColor];
    logoLabel.textAlignment = NSTextAlignmentCenter;
    [self.logInView setLogo:logoLabel];
    [self.logInView.passwordForgottenButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if (!self.isFirstRun)
    {
        [self.logInView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
        [self.logInView.signUpButton setBackgroundImage:nil forState:UIControlStateHighlighted];
        [self.logInView.signUpButton setBackgroundColor:[UIColor colorWithRed:23/255.0 green:93/255.0 blue:195/255.0 alpha:1.0]];
    }
    else
    {
        [self.logInView.signUpButton setHidden:YES];
    }
    

    [self.logInView.logInButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.logInButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.logInView.logInButton setBackgroundColor:[UIColor colorWithRed:23/255.0 green:93/255.0 blue:195/255.0 alpha:1.0]];
    
    
    // Remove text shadow
    CALayer *layer = self.logInView.usernameField.layer;
    layer.shadowOpacity = 0.0;
    layer = self.logInView.passwordField.layer;
    layer.shadowOpacity = 0.0;
    layer = self.logInView.logInButton.layer;
    layer.shadowOpacity = 0.0;
    layer = self.logInView.signUpButton.layer;
    layer.shadowOpacity = 0.0;
    layer.shadowOpacity = 0.0;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UILabel *fbT = [[UILabel alloc] initWithFrame:CGRectMake(self.logInView.usernameField.frame.origin.x, self.logInView.facebookButton.frame.origin.y -50, self.logInView.usernameField.frame.size.width, self.logInView.logInButton.frame.size.height)];
    
    [fbT setText:@"Sign up or Login with:"];
    [fbT setTextAlignment:NSTextAlignmentCenter];
    [fbT  setTextColor:[UIColor whiteColor]];
    [self.logInView addSubview:fbT];
    
    
    UILabel *existing = [[UILabel alloc] initWithFrame:CGRectMake(self.logInView.usernameField.frame.origin.x, self.logInView.usernameField.frame.origin.y -40, self.logInView.usernameField.frame.size.width, self.logInView.logInButton.frame.size.height)];
    
    [existing setText:@"Have a username and password?"];
    [existing setTextAlignment:NSTextAlignmentCenter];
    [existing  setTextColor:[UIColor whiteColor]];
    [self.logInView addSubview:existing];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [[self.logInView.usernameField layer] setBorderColor:[[UIColor whiteColor] CGColor]];
    [[self.logInView.passwordField layer] setBorderColor:[[UIColor whiteColor] CGColor]];
    
    [[self.logInView.usernameField layer] setBorderWidth:1.0];
    [[self.logInView.passwordField layer] setBorderWidth:1.0];
    
    //  dismiss button
    [self.logInView.dismissButton setFrame:CGRectMake(self.view.frame.size.width - 45, 35.0f, 25,25)];
    [self.logInView.dismissButton setImage:[UIImage imageNamed:@"dismissButtonGray.png"] forState:UIControlStateNormal];
    [self.logInView.dismissButton setImage:[UIImage imageNamed:@"dismissButtonGray.png"] forState:UIControlStateHighlighted];
    
    // move pwd and username fields down
    self.logInView.usernameField.frame = CGRectMake(self.logInView.center.x - (self.logInView.frame.size.width-40)/2, self.logInView.usernameField.frame.origin.y - 35.0, self.logInView.usernameField.frame.size.width-40, self.logInView.usernameField.frame.size.height);
    self.logInView.passwordField.frame = CGRectMake(self.logInView.passwordField.center.x - (self.logInView.frame.size.width - 40)/2, self.logInView.passwordField.frame.origin.y - 33.0, self.logInView.passwordField.frame.size.width-40, self.logInView.passwordField.frame.size.height);
    self.logInView.logInButton.frame = CGRectMake(self.logInView.logInButton.center.x - (self.logInView.frame.size.width - 40)/2, self.logInView.logInButton.frame.origin.y - 45, self.logInView.logInButton.frame.size.width-40, self.logInView.logInButton.frame.size.height);
    self.logInView.logo.frame = CGRectMake(self.logInView.logo.frame.origin.x, self.logInView.logo.frame.origin.y - 45, self.logInView.logo.frame.size.width, self.logInView.logo.frame.size.height);
    
    self.logInView.passwordForgottenButton.frame = CGRectMake(self.logInView.passwordForgottenButton.frame.origin.x, self.logInView.passwordForgottenButton.frame.origin.y - 50, self.logInView.passwordForgottenButton.frame.size.width, self.logInView.passwordForgottenButton.frame.size.height);
    
    self.logInView.facebookButton.frame = CGRectMake(self.logInView.facebookButton.frame.origin.x, self.logInView.facebookButton.frame.origin.y -20, self.logInView.facebookButton.frame.size.width, self.logInView.facebookButton.frame.size.height);
    self.logInView.twitterButton.frame = CGRectMake(self.logInView.twitterButton.frame.origin.x, self.logInView.twitterButton.frame.origin.y -20, self.logInView.twitterButton.frame.size.width, self.logInView.twitterButton.frame.size.height);
    
    [self.logInView.signUpButton setTitle:@"Sign Up with Email" forState:UIControlStateNormal];
    //self.logInView.signUpButton.frame = CGRectMake(self.logInView.passwordField.center.x - (self.logInView.frame.size.width - 40)/2, self.logInView.signUpButton.frame.origin.y, self.logInView.logInButton.frame.size.width-40, self.logInView.signUpButton.frame.size.height);
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.logInView.dismissButton setHidden:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.logInView.dismissButton setHidden:NO];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}
@end
