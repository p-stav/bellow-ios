//
//  MiniRipple.h
//  Ripple
//
//  Created by Gal Oshri on 10/11/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MiniRipple : NSObject

@property (strong, nonatomic) NSString *rippleId;
@property (strong, nonatomic) NSString *miniRippleId;
@property (strong, nonatomic) NSDate *lastUpdated;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (strong, nonatomic) NSMutableArray *children;
@property (nonatomic) BOOL isFirstWave;
@property (nonatomic) int depth;

@end
