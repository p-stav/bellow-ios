//
//  FacebookService.m
//  Bellow
//
//  Created by Paul Stavropoulos on 4/2/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.

/*
#import "FacebookService.h"



@implementation FacebookService

+ (void)postMessage:(NSString *)message withImage:(UIImage *)image
{
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
    {
        
        
        FBRequest *request;
        NSString *status = message;
        
        // if (image != nil)
        
        request = [FBRequest requestForPostStatusUpdate:status];
        
        // Send request to Facebook
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            // handle response
           if(error)
               NSLog(@"Error: %@", error);
            else
                NSLog(@"posted to facebook");
        }];
    }

}

@end
*/