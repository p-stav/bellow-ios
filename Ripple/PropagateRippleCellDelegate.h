//
//  PropagateRippleCellDelegate.h
//  Ripple
//
//  Created by Gal Oshri on 11/8/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ripple.h"

@protocol PendingRippleCellDelegate <NSObject>

// indicates that the given item has been deleted
-(void) rippleDismissed:(Ripple *)ripple;

-(void) ripplePropagated:(Ripple *)ripple;

-(void) goToMapView:(Ripple *)ripple withComments:(BOOL)commentsUp;

-(void) goToImageView: (Ripple *)ripple;

- (void) goToUserProfile: (Ripple *)ripple;


@end
