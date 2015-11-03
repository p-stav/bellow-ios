//
//  SwipeableCellDelegate.h
//  Bellow
//
//  Created by Paul Stavropoulos on 9/18/15.
//  Copyright © 2015 Kefi Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bellow.h"

@protocol SwipeableRippleCellDelegate <NSObject>

// indicates that the given item has been deleted
-(void) rippleDismissed:(Bellow *)ripple;

-(void) ripplePropagated:(Bellow *)ripple;

-(void) goToMapView:(Bellow *)ripple withComments:(BOOL)commentsUp;

-(void) goToImageView: (Bellow *)ripple;

- (void) goToUserProfile: (Bellow *)ripple;


@end

