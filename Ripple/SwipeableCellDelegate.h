//
//  SwipeableCellDelegate.h
//  Ripple
//
//  Created by Paul Stavropoulos on 9/18/15.
//  Copyright © 2015 Kefi Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ripple.h"

@protocol SwipeableRippleCellDelegate <NSObject>

// indicates that the given item has been deleted
-(void) rippleDismissed:(Ripple *)ripple;

-(void) ripplePropagated:(Ripple *)ripple;

-(void) goToMapView:(Ripple *)ripple withComments:(BOOL)commentsUp;

-(void) goToImageView: (Ripple *)ripple;

- (void) goToUserProfile: (Ripple *)ripple;


@end

