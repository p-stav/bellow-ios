//
//  BellowService.h
//  Ripple
//
//  Created by Gal Oshri on 9/11/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ripple.h"
#import <Parse/Parse.h>

@interface BellowService : NSObject

+ (int)checkUsername:(NSString *)username;

+ (void)startRipple:(NSString *)text withImage: (UIImage *)rippleImage;

+ (void)propagateRipple:(Ripple *)ripple;

+ (void)propagateSwipeableRipple:(Ripple *)ripple;

+ (NSMutableArray *)getPendingRipples:(int)skipItems;

+ (NSMutableArray *)getMyRipples:(int)skipItems withSortMethod: (int)sortMethod;

+ (NSMutableArray *)getTopRipples:(int)skipItems;

+ (NSMutableArray *)getFollowingRipples;

+ (NSMutableArray *)getStoredFollowingRipples: (int)skipItems;

+ (NSMutableArray *)getPropagatedRipples:(int)skipItems withSortMethod: (int)sortMethod;


+ (void)dismissRipple:(Ripple *)ripple;

+ (void)dismissSwipeableRipple:(Ripple *)ripple;

+ (NSArray *)getMiniRipples:(Ripple *)ripple;

+ (NSArray *)getMiniRipplesGraph:(NSString *)rippleId;

+ (void)deleteRipple:(Ripple *)ripple;

+ (NSMutableArray *)getRippleComments:(Ripple *)ripple;

+ (void) addComment:(NSString *)commentText forRipple:(Ripple *)ripple;

// Return YES if settings were updated
+ (BOOL)getSettings;

+ (NSArray *)getRippleLevels;

+ (void)flagRipple:(NSString *)rippleId;

+ (NSArray *)getPointMethods;

+ (PFUser *)getUser:(NSString *)userId;

+ (NSMutableArray *)getUserRipples:(int)skipItems forUser: (NSString *) userId;

+ (NSArray *)getNotifications;

+ (int) getNotificationBadgeNumber;

+ (void)sawAllNotifications;

+ (Ripple *)getRipple:(NSString *)rippleId;

+ (void)completeNotification:(NSString *)notificationId;

+ (int)acceptReferral:(NSString *)token;

+ (NSMutableArray *)getSearchResults:(NSString *)searchText;

+ (NSMutableArray *)getFollowingUsers;

+ (void) addToFollowingNumber: (NSString *) userId;

+ (void) removeFromFollowingNumber: (NSString *) userId;

+ (void) getEmailFromFacebook;

+ (void) getEmailFromTwitter;

@end


