//
//  AppDelegate.m
//  Bellow
//
//  Created by Gal Oshri on 9/10/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "TabBarController.h"
#import "AGPushNoteView.h"
#import "HomePage.h"

#import "Flurry.h"
#import "NotificationsPage.h"
#import "MapView.h"
#import "BellowService.h"
#import <ParseCrashReporting/ParseCrashReporting.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/ParseFacebookUtilsV4.h>
#import <ParseTwitterUtils/ParseTwitterUtils.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>



#define ARC4RANDOM_MAX      0x100000000

@implementation AppDelegate

@synthesize locationManager;
BOOL isLaunch;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // access keys from .pList and config file
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *twitterClientId = [info objectForKey:@"TwitterClientID"];
    NSString *twitterClientSecret = [info objectForKey:@"TwitterClientSecret"];
    NSString *parseClientId = [info objectForKey:@"ParseClientID"];
    NSString *parseClientSecret = [info objectForKey:@"ParseClientSecret"];
    NSString *flurryId = [info objectForKey:@"FlurryAppID"];
    
    [ParseCrashReporting enable];
    [Parse setApplicationId:parseClientId clientKey:parseClientSecret];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [Flurry logEvent:@"App_Open"];
    [PFTwitterUtils initializeWithConsumerKey:twitterClientId consumerSecret:twitterClientSecret];
    [Flurry startSession:flurryId];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    // fabric
    [Fabric with:@[[Crashlytics class]]];

    

    // only start monitoring significant location changes when have finished tutorial
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    NSNumber *isTutorialDone = [userData objectForKey:@"isTutorialDone"];
    
    if ([isTutorialDone boolValue])
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager = locationManager;
        
        if ([CLLocationManager locationServicesEnabled]) {
            // Find the current location
            #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
                // Being compiled with a Base SDK of iOS 8 or later
                // Now do a runtime check to be sure the method is supported
                if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                    [self.locationManager requestAlwaysAuthorization];
                } else {
                    // No such method on this device - do something else as needed
                }
            #else
                // Being compiled with a Base SDK of iOS 7.x or earlier
                // No such method - do something else as needed
            #endif
            
            [locationManager startMonitoringSignificantLocationChanges];
        }
    }
    
    isLaunch = YES;
    
    //navigation bar set color and text color (we actually show an image of a blue bar)
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"barImage.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

    // Deal with push notification
    if (launchOptions != nil)
    {
        // Extract the notification data
        NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        
        
        // strings
        NSString *rippleId;
        NSString *goToView;
        
        if ([notificationPayload valueForKey:@"rippleId"] != nil)
            rippleId = [notificationPayload objectForKey:@"rippleId"];
        
        if ([notificationPayload valueForKey:@"goTo"] != nil)
             goToView = [notificationPayload objectForKey:@"goTo"];
        
        // if have rippleId, we are going to a specific ripple in myrippleTVC
        if (rippleId != nil)
        {
            NSString *rippleId = [notificationPayload objectForKey:@"rippleId"];
            [self goToMyRipple:rippleId];
            NSLog(@"we got into here");
        }
        
        // if we are going to MyRipplesTVC
        else if ([goToView isEqualToString:@"MyRipplesViewController"])
        {
            [self goToMyRipple:nil];
        }
    }

    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global"];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // grab objects from userInfo
    NSString *rippleId = [userInfo objectForKey:@"rippleId"];
    NSString *goToView = [userInfo objectForKey:@"goTo"];
    
    
    
    // if the app is in the background
    if (!self.isInForeground)
    {
        [PFPush handlePush:userInfo];
        
        // new ripples push
        if ([goToView isEqualToString:@"PropagateRippleTableViewController"])
            [self presentInitialController];
        
        // update to network score
        else if ([goToView isEqualToString:@"MyRipplesViewController"])
            [self presentProfilePage];
        
        // rippleId is present, and update on a ripple you had
        else
            [self goToMyRipple:rippleId];

    }
    
    // else we are in the app
    else
    {
         NSDictionary *message = [userInfo objectForKey:@"aps"];
        [AGPushNoteView showWithNotificationMessage:message[@"alert"]];
        
        [AGPushNoteView setMessageAction:^(NSString *message) {
            // ditto same code above
            
            // new ripples push
            if ([goToView isEqualToString:@"PropagateRippleTableViewController"])
                [self presentInitialController];
            
            // update to network score
            else if ([goToView isEqualToString:@"MyRipplesViewController"])
                [self presentProfilePage];
            
            // rippleId is present, and update on a ripple you had
            else
                [self goToMyRipple:rippleId];
        }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshNotificationsBadge" object:nil];
    }
}

-(void) presentInitialController
{
    // we received push notifications for new ripples, and want to show
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    [tabController setSelectedIndex:0];
}

- (void)presentProfilePage
{
    // we received push notifications for new ripples, and want to show
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    [tabController setSelectedIndex:4];
}


- (void) goToMyRipple: (NSString *)rippleId
{
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    [tabController setSelectedIndex:3];
    
    UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        Bellow *ripple = [BellowService getRipple:rippleId];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            MapView *rmv = [mainstoryboard instantiateViewControllerWithIdentifier:@"RippleMapView"];
            rmv.ripple = ripple;
            
            NotificationsPage *np =  (NotificationsPage *)[[tabController viewControllers] objectAtIndex:3];
            [(UINavigationController *)np pushViewController:rmv animated:YES];
        });
    });
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //Only applies when in foreground otherwise it is very significant changes
    
    if ([CLLocationManager locationServicesEnabled]) {
        // Only monitor significant changes
        [locationManager stopMonitoringSignificantLocationChanges];
        
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        // Being compiled with a Base SDK of iOS 8 or later
        // Now do a runtime check to be sure the method is supported
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        } else {
            // No such method on this device - do something else as needed
        }
        #else
        // Being compiled with a Base SDK of iOS 7.x or earlier
        // No such method - do something else as needed
        #endif
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
    
    self.isInForeground = NO;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    self.isInForeground = YES;
    
    if (isLaunch)
    {
        isLaunch = NO;
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AppToForeground" object:nil];
    }
    
    // FB lines
    [FBSDKAppEvents activateApp];
        //  [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    
    // set applciation number on parse to 0
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0)
    {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [locations lastObject];
    self.location = [locations lastObject];
    
    if ([PFUser currentUser])
    {
        double randomVal1 = ((double)arc4random() / ARC4RANDOM_MAX) - 0.5;
        double randomVal2 = ((double)arc4random() / ARC4RANDOM_MAX) - 0.5;
        double latitudeJiggle = randomVal1 / 222;
        double milesInLongitudeDegree = 69.11 * cos(self.location.coordinate.longitude);
        double longitudeJiggle = randomVal2 / (milesInLongitudeDegree * 1.6 * 2);
        
        // If we're running in the background, run sendBackgroundLocationToServer
        PFGeoPoint *point = [PFGeoPoint
                             geoPointWithLatitude:self.location.coordinate.latitude + latitudeJiggle
                             longitude:self.location.coordinate.longitude + longitudeJiggle];
        
        // jiggle location
        
        
        [[PFUser currentUser] setObject:point forKey:@"location"];
        [[PFUser currentUser] saveInBackground];
    
    }
}

@end
