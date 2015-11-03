//
//  PropagateRippleCellDelegate.h
//  Bellow
//
//  Created by Gal Oshri on 11/8/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bellow.h"

@protocol PendingRippleCellDelegate <NSObject>

// indicates that the given item has been deleted
-(void) rippleDismissed:(Bellow *)ripple;

-(void) ripplePropagated:(Bellow *)ripple;

-(void) goToMapView:(Bellow *)ripple withComments:(BOOL)commentsUp;

-(void) goToImageView: (Bellow *)ripple;

- (void) goToUserProfile: (Bellow *)ripple;


@end
