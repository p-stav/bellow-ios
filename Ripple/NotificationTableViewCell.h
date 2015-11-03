//
//  NotificationTableViewCell.h
//  Bellow
//
//  Created by Paul Stavropoulos on 4/26/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Notification.h"

@interface NotificationTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *notificationText;
@property (weak, nonatomic) IBOutlet UIImageView *notificationImage;
@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;

@property (strong,nonatomic) Notification *notification; 

@end
