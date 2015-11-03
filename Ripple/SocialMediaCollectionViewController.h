//
//  SocialMediaCollectionViewController.h
//  Bellow
//
//  Created by Dan Li on 6/27/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocialMediaTableViewCell.h"

@protocol SocialMediaCollectionControllerDelegate<UIAlertViewDelegate>

- (BOOL) isCurrentUserProfile;
- (NSString *)getUserIdString;
- (void) saveSocialMediaProfile:(NSString *) profileType withHandle:(NSString *) handle;
- (NSDictionary *) getSocialMediaIconToName;

@end

@interface SocialMediaCollectionViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) id<SocialMediaCollectionControllerDelegate>delegate;

@end
