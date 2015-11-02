//
//  MyRippleCellDelegate.h
//  Ripple
//
//  Created by Paul Stavropoulos on 4/4/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ripple.h"


@protocol ActedRippleCellDelegate <NSObject>

-(void) goToMapView:(Ripple *)ripple withComments:(BOOL)commentsUp;
-(void) goToImageView: (Ripple *)ripple;
- (void) goToUserProfile: (Ripple *)ripple;

@end
