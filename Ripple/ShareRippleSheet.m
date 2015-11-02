//
//  ShareRippleSheet.m
//  Ripple
//
//  Created by Paul Stavropoulos on 2/7/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import "ShareRippleSheet.h"
#import <Parse/Parse.h>

@implementation ShareRippleSheet

+ (UIActivityViewController *)shareRippleSheet:(NSString *)string
{
    UIActivityViewController *shareController;
    
    UIColor *originalTint = [[UINavigationBar appearance] tintColor];
    
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    
    NSString *shareText;
    if (string)
    {
        shareText = string;
    }
    
    else
        shareText = [NSString stringWithFormat:@"Hey, I just downloaded the app Ripple and you should also try it out! Use my referral code \"%@\" to get 200 points when you sign in. Download it on the iOS or Google Play store, or at www.getRipple.io", [PFUser currentUser][@"username"]];
    UIImage *image = [UIImage imageNamed:@"InstagramAdd.png"];
    shareController = [[UIActivityViewController alloc] initWithActivityItems:@[shareText, image] applicationActivities:nil];
    
    [shareController setCompletionHandler:^(NSString *activityType, BOOL completed) {
        NSLog(@"completed dialog - activity: %@ - finished flag: %d", activityType, completed);
        
        [[UINavigationBar appearance] setTintColor:originalTint];
        if (completed)
            [PFAnalytics trackEvent:@"SuccessfullySharedRipple" dimensions:@{@"ActivityType" : activityType}];
        else
            [PFAnalytics trackEvent:@"FailedSharedRipple" dimensions:nil];
    }];
    
    return shareController;
}

@end
