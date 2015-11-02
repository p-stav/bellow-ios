//
//  NotificationsPage.h
//  Ripple
//
//  Created by Gal Oshri on 4/26/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationsPage : UITableViewController

@property (strong, nonatomic) NSArray *notificationArray;

- (void)notificationClickMyRipple:(NSString *)goToRippleId;
- (void)refreshList;

@end
