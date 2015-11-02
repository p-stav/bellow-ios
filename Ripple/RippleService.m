//
//  RippleService.m
//  Ripple
//
//  Created by Gal Oshri on 9/11/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import "RippleService.h"
#import <Parse/Parse.h>
#import "MiniRipple.h"
#import "RippleLevel.h"
#import "RipplePoint.h"
#import "Comment.h"
#import <AddressBook/AddressBook.h>
#import "Notification.h"
#import "AGPushNoteView.h"
#import "PointsViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@implementation RippleService

+(int) checkUsername:(NSString *)username
{
     NSDictionary *response = [PFCloud callFunction:@"checkUsername" withParameters:@{@"username":username}];
    
    return [response[@"check"] intValue];
}

+ (void)startRipple:(NSString *)text withImage:(UIImage *)rippleImage
{
    PFObject *ripple = [PFObject objectWithClassName:@"Ripple"];

    ripple[@"creator"] = [PFUser currentUser];
    ripple[@"creatorName"] = [PFUser currentUser].username;
    ripple[@"receiverIds"] = @[[PFUser currentUser].objectId];
    ripple[@"numPropagated"] = [NSNumber numberWithInt:-1];
    PFGeoPoint *location = [PFUser currentUser][@"location"];
    ripple[@"startLocation"] = location;
    
    // content
    ripple[@"text"] = text;
    
    PFRelation *rippleReceivers = [ripple relationForKey:@"receivers"];
    [rippleReceivers addObject:[PFUser currentUser]];
    
    // reverse location
    PFGeoPoint *pfgeopoint = [PFUser currentUser][@"location"];
    CLLocation *point = [[CLLocation alloc] initWithLatitude:pfgeopoint.latitude longitude:pfgeopoint.longitude];
    
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:point completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks && placemarks.count > 0)
        {
            CLPlacemark *placemark = placemarks[0];
            NSDictionary *addressDictionary = placemark.addressDictionary;
            NSString *country = [addressDictionary objectForKey:(NSString *)kABPersonAddressCountryKey];
            NSString *state = [addressDictionary objectForKey:(NSString *)kABPersonAddressStateKey];
            
            NSString *city = [addressDictionary objectForKey:(NSString *)kABPersonAddressCityKey];
            NSLog(@"%@ %@", city, country);
            
            if (city != nil)
                ripple[@"city"] = city;
            if (country != nil)
                ripple[@"country"] = country;
            if (state != nil)
                ripple[@"state"] = state;
            
        }
        
        
        // add image if it's there
        PFFile *imageFile;
        if (rippleImage)
        {
            NSData *rippleImageData;
            float scale;
            
            if (rippleImage.size.width*rippleImage.size.height > 8000000)
            {
                if (rippleImage.size.width > rippleImage.size.height)
                {
                    scale = rippleImage.size.height/rippleImage.size.width;
                }
                else
                {
                    scale = rippleImage.size.width/rippleImage.size.height;
                }
                
                CGSize newSize;
                
                if (rippleImage.size.width > rippleImage.size.height)
                {
                    float width = sqrtf(8000000*rippleImage.size.width/rippleImage.size.height);
                    newSize = CGSizeMake(width, width*scale);
                }
                else
                {
                    float height = sqrtf(8000000*rippleImage.size.height/rippleImage.size.width);
                    newSize  = CGSizeMake(height*scale,height);
                }
                
                UIGraphicsBeginImageContext(newSize);
                [rippleImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
                UIImage *temp = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                rippleImageData = UIImageJPEGRepresentation(temp, 0.4);
                ripple[@"imageHeight"] = [NSNumber numberWithFloat:newSize.height];
                ripple[@"imageWidth"] = [NSNumber numberWithFloat:newSize.width];
                
                imageFile = [PFFile fileWithName:[NSString stringWithFormat:@"rippleImage.jpg"] data:rippleImageData];
                ripple[@"image"] = imageFile;
            }
            
            
            
            else
            {
                rippleImageData = UIImageJPEGRepresentation(rippleImage, 0.4);
                ripple[@"imageHeight"] = [NSNumber numberWithFloat:rippleImage.size.height];
                ripple[@"imageWidth"] = [NSNumber numberWithFloat:rippleImage.size.width];
                imageFile = [PFFile fileWithName:[NSString stringWithFormat:@"rippleImage.jpg"] data:rippleImageData];
                ripple[@"image"] = imageFile;
            }
        }
        
        
        // start creating newRipple
        Ripple *newRipple = [[Ripple alloc] init];
        newRipple.text = ripple[@"text"];
        newRipple.creatorName = ripple[@"creatorName"];
        newRipple.creatorId = [PFUser currentUser].objectId;
        newRipple.numberPropagated = 0;
        PFGeoPoint *location = ripple[@"startLocation"];
        newRipple.latitude = [location latitude];
        newRipple.longitude = [location longitude];
        newRipple.createdAt = ripple.createdAt;
        newRipple.imageFile = ripple[@"image"];
        
        if (ripple[@"image"])
        {
            newRipple.imageHeight = [ripple[@"imageHeight"] floatValue];
            newRipple.imageWidth = [ripple[@"imageWidth"] floatValue];
        }
        newRipple.numberComments = 0;
        newRipple.rippleExposure = 0;
        newRipple.state = ripple[@"state"];
        newRipple.country = ripple[@"country"];
        newRipple.city = ripple[@"city"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NewRippleStart" object:newRipple];
        
        
        [ripple saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            newRipple.rippleId = ripple.objectId;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NewRippleEnd" object:newRipple];
            
            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [PFCloud callFunction:@"spreadNearbyAndFollowers" withParameters:@{@"rippleId" : ripple.objectId}];
            });
        }];
    }];
    
    if (![PFUser currentUser][@"sentFirstRipple"]) {
        [[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:@"sentFirstRipple"];
        [[PFUser currentUser] saveEventually];
    }
    
    
}

+ (void)propagateRipple:(Ripple *)ripple
{
    // Propagate ripple
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        [PFCloud callFunction:@"spreadRippleTEST" withParameters:@{@"rippleId" : ripple.rippleId}];
        
        /*
         dispatch_async( dispatch_get_main_queue(), ^{
         // Add code here to update the UI/send notifications based on the
         // results of the background processing
         }); 
        */
    });
    
    // Complete mini-ripple
    PFObject *miniRippleObject = [PFObject objectWithoutDataWithClassName:@"MiniRipple"
                                                             objectId:ripple.miniRippleId];
    miniRippleObject[@"isPropagated"] = [NSNumber numberWithBool:YES];
    miniRippleObject[@"location"] = [PFUser currentUser][@"location"];
    [miniRippleObject saveInBackground];
}

+ (void)propagateSwipeableRipple:(Ripple *)ripple
{
    // Propagate ripple
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [PFCloud callFunction:@"spreadSwipeableRipple" withParameters:@{@"rippleId" : ripple.rippleId}];
        [PFCloud callFunction:@"spreadRippleTEST" withParameters:@{@"rippleId" : ripple.rippleId}];
        
    });
}

+ (NSMutableArray *)getPendingRipples:(int)skipItems
{
    NSArray *rippleJsonObjects = [PFCloud callFunction:@"getPendingRipplesBatch" withParameters:@{@"skip":[NSNumber numberWithInt:skipItems]}];
    
    NSMutableArray *rippleArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *rippleJson in rippleJsonObjects)
    {
        Ripple *ripple = [self rippleJsonToRipple:rippleJson];
        [rippleArray addObject:ripple];
    }
    
    return rippleArray;
}

+ (NSMutableArray *)getMyRipples:(int)skipItems withSortMethod:(int)sortMethod
{
    NSArray *rippleJsonObjects = [PFCloud callFunction:@"getMyRipples" withParameters:@{@"skip":[NSNumber numberWithInt:skipItems], @"sortMethod":[NSNumber numberWithInt:sortMethod]}];
    
    NSMutableArray *rippleArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *rippleJson in rippleJsonObjects)
    {
        Ripple *ripple = [self rippleJsonToRipple:rippleJson];
        [rippleArray addObject:ripple];
    }
   
        return rippleArray;
}


+ (NSMutableArray *)getTopRipples:(int)skipItems
{
    NSArray *rippleJsonObjects = [PFCloud callFunction:@"getTopRipples" withParameters:@{@"skip":[NSNumber numberWithInt:skipItems]}];
    NSMutableArray *rippleArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *rippleJson in rippleJsonObjects)
    {
        Ripple *ripple = [self rippleJsonToRipple:rippleJson];
        [rippleArray addObject:ripple];
    }
    
    return rippleArray;
}

+ (NSMutableArray *)getFollowingRipples
{
    NSArray *rippleJsonObjects = [PFCloud callFunction:@"getPendingFollowingRipplesTEST" withParameters:@{}];
    NSMutableArray *rippleArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *rippleJson in rippleJsonObjects)
    {
        Ripple *ripple = [self rippleJsonToRipple:rippleJson];
        [rippleArray addObject:ripple];
    }
    
    return rippleArray;
}

+ (NSMutableArray *)getStoredFollowingRipples:(int)skipItems
{
    NSArray *rippleJsonObjects = [PFCloud callFunction:@"getStoredFollowingRipples" withParameters:@{@"skip":[NSNumber numberWithInt:skipItems]}];
    NSMutableArray *rippleArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *rippleJson in rippleJsonObjects)
    {
        Ripple *ripple = [self rippleJsonToRipple:rippleJson];
        [rippleArray addObject:ripple];
    }
    
    return rippleArray;
}

+ (NSMutableArray *)getPropagatedRipples:(int)skipItems withSortMethod:(int)sortMethod
{
    NSArray *rippleJsonObjects = [PFCloud callFunction:@"getPropagatedRipples" withParameters:@{@"skip":[NSNumber numberWithInt:skipItems], @"sortMethod":[NSNumber numberWithInt:sortMethod]}];
    
    NSMutableArray *rippleArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *rippleJson in rippleJsonObjects)
    {
        Ripple *ripple = [self rippleJsonToRipple:rippleJson];
        [rippleArray addObject:ripple];
    }
    
    return rippleArray;
}

+ (NSMutableArray *)getMyAndPropagatedRipples:(int)skipItems withFilterMethod:(int)filterMethod withSortMethod:(int)sortMethod
{
    NSArray *rippleJsonObjects = [PFCloud callFunction:@"getMyAndPropagatedRipples" withParameters:@{@"skip":[NSNumber numberWithInt:skipItems], @"sortMethod": [NSNumber numberWithInt:sortMethod], @"filterMethod":[NSNumber numberWithInt:filterMethod]}];
    
    NSMutableArray *rippleArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *rippleJson in rippleJsonObjects)
    {
        Ripple *ripple = [self rippleJsonToRipple:rippleJson];
        [rippleArray addObject:ripple];
    }
    
    return rippleArray;
}

+ (void)dismissRipple:(Ripple *)ripple
{
    PFObject *miniRipple = [PFObject objectWithoutDataWithClassName:@"MiniRipple" objectId:ripple.miniRippleId];
    miniRipple[@"isPropagated"] = [NSNumber numberWithBool:NO];
    miniRipple[@"location"] = [PFUser currentUser][@"location"];
    [miniRipple saveInBackground];
    
    // call cloud function to add point
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [PFCloud callFunction:@"dismissRipple" withParameters:@{@"rippleId" : ripple.rippleId}];
    });
}

+ (void)dismissSwipeableRipple:(Ripple *)ripple
{
    // call cloud function to add point
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [PFCloud callFunction:@"dismissRipple" withParameters:@{@"rippleId" : ripple.rippleId}];
        [PFCloud callFunction:@"dismissSwipeableRipple" withParameters:@{@"rippleId" : ripple.rippleId}];
    });
}


+ (NSArray *)getMiniRipples:(Ripple *)ripple
{
    PFQuery *miniRippleQuery = [PFQuery queryWithClassName:@"MiniRipple"];
    PFObject *rippleObject = [PFObject objectWithoutDataWithClassName:@"Ripple" objectId:ripple.rippleId];
    
    [miniRippleQuery whereKey:@"ripple" equalTo:rippleObject];
    [miniRippleQuery whereKey:@"isPropagated" equalTo:[NSNumber numberWithBool:YES]];
    
    NSArray *miniRippleObjects = [miniRippleQuery findObjects];
    
    NSMutableArray *miniRipples = [[NSMutableArray alloc] init];
    
    for (PFObject *miniRippleObject in miniRippleObjects)
    {
        MiniRipple *miniRipple = [[MiniRipple alloc] init];
        
        miniRipple.rippleId = ripple.rippleId;
        miniRipple.miniRippleId = miniRippleObject.objectId;
        miniRipple.lastUpdated = miniRippleObject.updatedAt;
        PFGeoPoint *location = miniRippleObject[@"location"];
        miniRipple.latitude = [location latitude];
        miniRipple.longitude = [location longitude];
        
        [miniRipples addObject:miniRipple];
    }
    return miniRipples;
}

+ (NSArray *)getMiniRipplesGraph:(NSString *)rippleId
{
    NSArray *graphArray = [PFCloud callFunction:@"getMiniRipplesGraph" withParameters:@{@"rippleId" : rippleId}];
    
    NSMutableArray *miniRippleGraph = [[NSMutableArray alloc] init];
    
    for (NSDictionary *miniRippleObject in graphArray)
    {
        MiniRipple *miniRipple = [[MiniRipple alloc] init];
        
        miniRipple.rippleId = [NSString stringWithString:rippleId];
        miniRipple.miniRippleId = miniRippleObject[@"miniRippleId"];
        // miniRipple.lastUpdated =
        PFGeoPoint *location = miniRippleObject[@"geoPoint"];
        miniRipple.latitude = [location latitude];
        miniRipple.longitude = [location longitude];
        
        miniRipple.children = [[NSMutableArray alloc] init];
        [miniRipple.children addObjectsFromArray:miniRippleObject[@"children"]];
        miniRipple.isFirstWave = [miniRippleObject[@"isFirstWave"] boolValue];
        
        [miniRippleGraph addObject:miniRipple];
    }
    return miniRippleGraph;
}

+ (void)deleteRipple:(Ripple *)ripple
{
    [PFCloud callFunction:@"deleteRipple" withParameters:@{@"rippleId" : ripple.rippleId}];
}

+ (NSMutableArray *)getRippleComments:(Ripple *)ripple
{
    NSMutableArray *commentArray = [[NSMutableArray alloc] init];
    
    // make call to cloud code
    NSMutableArray *comments  = [PFCloud callFunction:@"getCommentsForRipple" withParameters:@{@"rippleId" : ripple.rippleId}];


    // create comments and add to ripple commmentArray
    for (PFObject *commentObject in comments)
    {
        Comment *comment = [[Comment alloc]init];
        comment.commentId = commentObject[@"id"];
        comment.commentText = commentObject[@"comment"];
        comment.createdAt = commentObject[@"createdAt"];
        comment.creatorUsername = commentObject[@"username"];
        comment.creatorId = commentObject[@"userId"];
        
        if (commentObject[@"country"] != nil)
        {
            comment.country = commentObject[@"country"];
            comment.city = commentObject[@"city"];
            comment.state = commentObject[@"state"];    
        }
        
        [commentArray addObject:comment];
    }
    
    // return comment Array
    return commentArray;
    
}


+ (void) addComment:(NSString *)commentText forRipple:(Ripple *)ripple;
{
    // reverse location
    PFGeoPoint *pfgeopoint = [PFUser currentUser][@"location"];
    CLLocation *point = [[CLLocation alloc] initWithLatitude:pfgeopoint.latitude longitude:pfgeopoint.longitude];
    
    NSString __block *country = nil;
    NSString __block *state = nil;
    NSString __block *city = nil;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"rippleId"] = ripple.rippleId;
    params[@"commentText"] = commentText;
    params[@"creatorUsername"] = [PFUser currentUser].username;
    params[@"creatorId"] = [PFUser currentUser].objectId;
    
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:point completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks && placemarks.count > 0)
        {
            CLPlacemark *placemark = placemarks[0];
            NSDictionary *addressDictionary = placemark.addressDictionary;
            country = [addressDictionary objectForKey:(NSString *)kABPersonAddressCountryKey];
            state = [addressDictionary objectForKey:(NSString *)kABPersonAddressStateKey];
            
            city = [addressDictionary objectForKey:(NSString *)kABPersonAddressCityKey];
            //NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            //NSString *cityEN = [usLocale displayNameForKey: NSLocaleIdentifier value: city];
            
            
            if (city != nil)
                params[@"city"] = city;
            if (country != nil)
                params[@"country"] = country;
            if (state != nil)
                params[@"state"] = state;
            
        }
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [PFCloud callFunction:@"addCommentToRipple" withParameters:params];
        });
        
    }];
    
}

+ (Ripple *)rippleJsonToRipple:(NSDictionary *)rippleJson;
{
    Ripple *ripple = [[Ripple alloc] init];
    ripple.rippleId = rippleJson[@"rippleId"];
    ripple.miniRippleId = rippleJson[@"miniRippleId"];
    ripple.text = rippleJson[@"text"];
    ripple.creatorName = rippleJson[@"creatorName"];
    ripple.numberPropagated = [rippleJson[@"numPropagated"] intValue];
    ripple.createdAt = rippleJson[@"createdAt"];
    PFGeoPoint *geoPoint = rippleJson[@"geoPoint"];
    ripple.latitude = [geoPoint latitude];
    ripple.longitude = [geoPoint longitude];
    
    // get image
    PFFile *imageFile = rippleJson[@"image"];
    ripple.imageFile = imageFile;
    
    if (rippleJson[@"image"])
    {
        ripple.imageHeight = [rippleJson[@"imageHeight"] floatValue];
        ripple.imageWidth = [rippleJson[@"imageWidth"] floatValue];
    }
    
    if (rippleJson[@"creatorId"])
        ripple.creatorId = rippleJson[@"creatorId"];
    
    if (rippleJson[@"rippleExposure"])
        ripple.rippleExposure = [rippleJson[@"rippleExposure"] intValue];
    else
        ripple.rippleExposure = 0;
    
    // grab comment number
    if (rippleJson[@"numberOfComments"])
    {
        ripple.numberComments =[rippleJson[@"numberOfComments"] intValue];
        ripple.commentIds =rippleJson[@"commentIds"];
    }
    else
        ripple.numberComments = 0;
    
    if (rippleJson[@"city"])
        ripple.city = rippleJson[@"city"];
    
    if (rippleJson[@"country"])
        ripple.country = rippleJson[@"country"];
    
    if (rippleJson[@"isActedUpon"])
        ripple.actedUponState = [rippleJson[@"isActedUpon"] integerValue];
    
    if ([rippleJson[@"isFollowing"] intValue] == 1)
        ripple.isFollowingUser = YES;
    else
        ripple.isFollowingUser = NO;
    

    return ripple;
}


#pragma mark - Get Settings
+ (BOOL)getSettings;
{
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    
    NSDate *lastUpdated = [userData objectForKey:@"lastUpdated"];
    NSDate *currentDate = [NSDate date];
    NSNumber *updateInterval = [userData objectForKey:@"updateInterval"];
    
    // if we recently updated, return
    if (lastUpdated != nil)
    {
        NSTimeInterval secondsSinceUpdate = [currentDate timeIntervalSinceDate:lastUpdated];
        double numberOfDays = secondsSinceUpdate / 86400.0;
        if (updateInterval != nil)
        {
            if (numberOfDays < [updateInterval doubleValue])
                return NO;
        }
    }
    
    [PFConfig getConfig];
     
    NSString *defaultRippleString = [PFConfig currentConfig][@"defaultRippleString"];
    [userData setObject:defaultRippleString forKey:@"defaultRippleString"];
    
    NSString *defaultNoPendingRipplesString = [PFConfig currentConfig][@"defaultNoPendingRipplesString"];
    [userData setObject:defaultNoPendingRipplesString forKey:@"defaultNoPendingRipplesString"];
    
    NSNumber *newUpdateInterval = [PFConfig currentConfig][@"updateInterval"];
    [userData setObject:newUpdateInterval forKey:@"updateInterval"];
    
    [userData setObject:[NSDate date] forKey:@"lastUpdated"];
    
    [userData synchronize];
    
    return YES;
}

+ (NSArray *)getRippleLevels
{
    PFQuery *rippleLevelQuery = [PFQuery queryWithClassName:@"Level"];
    [rippleLevelQuery orderByAscending:@"minScore"];
    rippleLevelQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
    rippleLevelQuery.maxCacheAge = 60 * 60 * 24 * 2; // 2 days
    NSArray *rippleLevelObjects = [rippleLevelQuery findObjects];
    
    NSMutableArray *rippleLevels = [[NSMutableArray alloc] init];
    RippleLevel *level;
    
    for (PFObject *rippleLevelObject in rippleLevelObjects)
    {
        level = [[RippleLevel alloc] init];
        level.name = [NSString stringWithString:rippleLevelObject[@"name"]];
        level.minScore = [rippleLevelObject[@"minScore"] intValue];
        level.reach = [rippleLevelObject[@"reach"] intValue];
        
        [rippleLevels addObject:level];
    }
    
    return rippleLevels;
}

+ (void) flagRipple:(NSString *)rippleId
{
    PFObject *flag = [PFObject objectWithClassName:@"Flag"];
    
    PFObject *ripple = [PFObject objectWithoutDataWithClassName:@"Ripple" objectId:rippleId];
    flag[@"ripple"] = ripple;
    [flag incrementKey:@"numFlagged"];
    [flag saveInBackground];
}

+ (NSArray *)getPointMethods
{
    PFQuery *ripplePointQuery = [PFQuery queryWithClassName:@"Point"];
    [ripplePointQuery orderByAscending:@"points"];
    ripplePointQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
    ripplePointQuery.maxCacheAge = 60 * 60 * 24 * 2; // 2 days
    NSArray *ripplePointObjects = [ripplePointQuery findObjects];
    
    NSMutableArray *ripplePoints = [[NSMutableArray alloc] init];
    RipplePoint *point;

    for (PFObject *ripplePointObject in ripplePointObjects)
    {
        point = [[RipplePoint alloc] init];
        point.event = [NSString stringWithFormat:@"A ripple of yours spread %d times", [ripplePointObject[@"spread"] intValue]];
        point.points = [ripplePointObject[@"points"] intValue];
        [ripplePoints addObject:point];
    }
    
    NSArray *ripplePointsFromService = [[NSArray alloc] initWithArray:ripplePoints];
    return ripplePointsFromService;
}

+ (PFUser *)getUser:(NSString *)userId
{
    PFUser *user = [PFQuery getUserObjectWithId:userId];
    return user;
}

+ (NSMutableArray *)getUserRipples:(int)skipItems forUser:(NSString *)userId
{
    NSArray *rippleJsonObjects = [PFCloud callFunction:@"getMyRipples" withParameters:@{@"skip":[NSNumber numberWithInt:skipItems], @"profileUser":userId}];
    
    NSMutableArray *rippleArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *rippleJson in rippleJsonObjects)
    {
        Ripple *ripple = [self rippleJsonToRipple:rippleJson];
        [rippleArray addObject:ripple];
    }
    
    return rippleArray;
}
    
+ (NSArray *)getNotifications
{
    PFQuery *notificationQuery = [PFQuery queryWithClassName:@"Notification"];
    PFUser *currentUser = [PFUser currentUser];
    
    [notificationQuery whereKey:@"user" equalTo:currentUser];
    notificationQuery.limit = 25;
    [notificationQuery orderByDescending:@"createdAt"];
    
    NSArray *notificationObjects = [notificationQuery findObjects];
    
    
    
    NSMutableArray *notifications = [[NSMutableArray alloc] init];
    
    for (PFObject *notificationObject in notificationObjects)
    {
        Notification *notification = [[Notification alloc] init];
        notification.text = notificationObject[@"text"];
        notification.createdAt = notificationObject.createdAt;
        notification.notificationId = notificationObject.objectId;
        notification.isRead = [notificationObject[@"isRead"] boolValue];
        
        notification.type = notificationObject[@"type"];
        
        if ([notification.type isEqualToString:@"Ripple"] || [notification.type isEqualToString:@"Comment"])
            notification.rippleId = notificationObject[@"rippleId"];
        
        [notifications addObject:notification];
    }
    
    return notifications;
}

+ (int)getNotificationBadgeNumber
{
    PFQuery *notificationQuery = [PFQuery queryWithClassName:@"Notification"];
    
    int numberUnread = 0;
    
    if ([PFUser currentUser])
    {
        PFUser *currentUser = [PFUser currentUser];
        
        [notificationQuery whereKey:@"user" equalTo:currentUser];
        [notificationQuery whereKey:@"isSeen" equalTo:[NSNumber numberWithBool:NO]];
        notificationQuery.limit = 25;
        numberUnread = (int) [notificationQuery countObjects];

    }
    
    return numberUnread;

}

+ (void)sawAllNotifications
{
    PFQuery *notificationQuery = [PFQuery queryWithClassName:@"Notification"];
    PFUser *currentUser = [PFUser currentUser];
    
    [notificationQuery whereKey:@"user" equalTo:currentUser];
    [notificationQuery whereKey:@"isSeen" equalTo:[NSNumber numberWithBool:NO]];
    
    NSArray *notificationObjects = [notificationQuery findObjects];
   
    for (PFObject *notificationObject in notificationObjects)
        notificationObject[@"isSeen"] = [NSNumber numberWithBool:YES];

    [PFObject saveAll:notificationObjects];
}

+ (Ripple *)getRipple:(NSString *)rippleId {
    
    Ripple *ripple = [[Ripple alloc] init];
    NSDictionary *rippleObject = [PFCloud callFunction:@"getRippleForPush" withParameters:@{@"rippleId":rippleId}];
    
    if (rippleObject)
        ripple = [self rippleJsonToRipple:rippleObject];
    
    return ripple;
}

+ (void)completeNotification:(NSString *)notificationId {
    PFQuery *query = [PFQuery queryWithClassName:@"Notification"];
    
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:notificationId block:^(PFObject *notification, NSError *error) {
        // Now let's update it with some new data. In this case, only cheatMode and score
        notification[@"isRead"] = @YES;
        [notification saveInBackground];
        
    }];
    
}

+ (int)acceptReferral:(NSString *)token
{
    
    NSDictionary *response = [PFCloud callFunction:@"acceptReferral" withParameters:@{@"token":token}];
    
    return [response[@"scoreIncrease"] intValue];
}


+ (NSMutableArray *)getSearchResults:(NSString *)searchText
{
     NSMutableArray *userResults = [PFCloud callFunction:@"getUserSearchResults" withParameters:@{@"searchTerm":searchText}];
    return userResults;
}


#pragma mark - follower/following
+ (NSMutableArray *)getFollowingUsers
{
    NSMutableArray *userResults = [PFCloud callFunction:@"getFollowingUsers" withParameters:@{}];
    return userResults;
}

+ (void) addToFollowingNumber:(NSString *)userId
{   
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [PFCloud callFunction:@"addToFollowingNumber" withParameters:@{@"userId":userId}];
    });
}

+ (void) removeFromFollowingNumber:(NSString *)userId
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [PFCloud callFunction:@"removeFromFollowingNumber" withParameters:@{@"userId":userId}];
    });
}

+ (void) getEmailFromFacebook
{
    // get email from facebook
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"id,name,email"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             
             // put email
             if ([PFUser currentUser].email == nil)
             {
                 [[PFUser currentUser] setEmail:result[@"email"]];
                 [[PFUser currentUser] saveInBackground];
             }
             
         }];
    }
}

+ (void) getEmailFromTwitter
{
    
}

@end
