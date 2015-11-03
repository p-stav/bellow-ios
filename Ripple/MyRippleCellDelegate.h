//
//  MyRippleCellDelegate.h
//  Bellow
//
//  Created by Paul Stavropoulos on 4/4/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bellow.h"


@protocol ActedRippleCellDelegate <NSObject>

-(void) goToMapView:(Bellow *)ripple withComments:(BOOL)commentsUp;
-(void) goToImageView: (Bellow *)ripple;
- (void) goToUserProfile: (Bellow *)ripple;

@end
