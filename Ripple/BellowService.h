//
//  BellowService.h
//  Bellow
//
//  Created by Gal Oshri on 9/11/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bellow.h"
#import <Parse/Parse.h>

@interface BellowService : NSObject

+ (int)checkUsername:(NSString *)username;

+ (void)startRipple:(NSString *)text withImage: (UIImage *)rippleImage;

+ (void)propagateRipple:(Bellow *)ripple;

+ (void)propagateSwipeableRipple:(Bellow *)ripple;

+ (NSMutableArray *)getPendingRipples:(int)skipItems;

+ (NSMutableArray *)getMyRipples:(int)skipItems withSortMethod: (int)sortMethod;

+ (NSMutableArray *)getTopRipples:(int)skipItems;

+ (NSMutableArray *)getFollowingRipples;

+ (NSMutableArray *)getStoredFollowingRipples: (int)skipItems;

+ (NSMutableArray *)getPropagatedRipples:(int)skipItems withSortMethod: (int)sortMethod;


+ (void)dismissRipple:(Bellow *)ripple;

+ (void)dismissSwipeableRipple:(Bellow *)ripple;

+ (NSArray *)getMiniRipples:(Bellow *)ripple;

+ (NSArray *)getMiniRipplesGraph:(NSString *)rippleId;

+ (void)deleteRipple:(Bellow *)ripple;

+ (NSMutableArray *)getRippleComments:(Bellow *)ripple;

+ (void) addComment:(NSString *)commentText forRipple:(Bellow *)ripple;

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

+ (Bellow *)getRipple:(NSString *)rippleId;

+ (void)completeNotification:(NSString *)notificationId;

+ (int)acceptReferral:(NSString *)token;

+ (NSMutableArray *)getSearchResults:(NSString *)searchText;

+ (NSMutableArray *)getFollowingUsers;

+ (void) addToFollowingNumber: (NSString *) userId;

+ (void) removeFromFollowingNumber: (NSString *) userId;

+ (void) getEmailFromFacebook;

+ (void) getEmailFromTwitter;

@end


