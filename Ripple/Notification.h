//
//  Notification.h
//  Bellow
//
//  Created by Gal Oshri on 4/25/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notification : NSObject

@property (strong, nonatomic) NSString *notificationId;
@property (strong, nonatomic) NSString *text;
@property (nonatomic) BOOL isRead;

@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *rippleId;
@property (strong, nonatomic) NSDate *createdAt;

@end
