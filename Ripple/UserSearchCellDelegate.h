//
//  UserSearchCellDelegate.h
//  Bellow
//
//  Created by Paul Stavropoulos on 8/12/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bellow.h"


@protocol UserSearchDelegate <NSObject>

-(void) pushUserProfile:(NSString *)userId;
-(void) updateFollowing: (NSString *)userId;

@end
