//
//  Comment.h
//  Bellow
//
//  Created by Paul Stavropoulos on 12/12/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject

@property (strong, nonatomic) NSDate *createdAt;
@property (strong, nonatomic) NSString *creatorUsername;
@property (strong, nonatomic) NSString *creatorId;
@property (strong, nonatomic) NSString *commentText;
@property (strong, nonatomic) NSString *commentId;

@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *city;


@end
