//
//  TwitterService.h
//  Ripple
//
//  Created by Paul Stavropoulos on 2/3/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterService : NSObject

+ (void)sendTweet:(NSString *)tweetText withImage:(UIImage *)tweetImage;

@end
