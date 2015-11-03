//
//  Bellow.h
//  Bellow
//
//  Created by Gal Oshri on 9/14/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bellow : NSObject

@property (strong, nonatomic) NSString *rippleId;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) id imageFile;
@property (nonatomic) float imageHeight;
@property (nonatomic) float imageWidth;
@property (strong, nonatomic) NSString *creatorName;
@property (strong, nonatomic) NSString *creatorId;
@property (strong, nonatomic) NSString *miniRippleId;
@property (strong, nonatomic) NSMutableArray *commentArray;
@property (strong, nonatomic) NSMutableArray *commentIds;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *city;
@property (nonatomic) BOOL isFollowingUser;
    
@property (strong, nonatomic) NSDate *createdAt;
@property (nonatomic) int numberPropagated;
@property (nonatomic) int numberComments;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) int rippleExposure;
@property (nonatomic) int actedUponState;


@end
