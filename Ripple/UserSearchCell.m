//
//  UserSearchCell.m
//  Ripple
//
//  Created by Paul Stavropoulos on 8/12/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import "UserSearchCell.h"
#import "RippleService.h"

@implementation UserSearchCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)didPressFollower:(id)sender {
    if (self.isFollowing)
    {
        self.isFollowing = NO;
        [self.followerImage setImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
        [[PFUser currentUser][@"following"] removeObject:self.objectId];
        [RippleService removeFromFollowingNumber:self.objectId];
        
    }
    else
    {
        self.isFollowing = YES;
        [self.followerImage setImage:[UIImage imageNamed:@"following.png"] forState:UIControlStateNormal];
        if ([PFUser currentUser][@"following"] != nil)
            [[PFUser currentUser][@"following"] addObject:self.objectId];
        else
        {
            NSMutableArray *following = [[NSMutableArray alloc] initWithObjects:self.objectId, nil];
            [PFUser currentUser][@"following"]  = following;
        }
        [RippleService addToFollowingNumber:self.objectId];
    }
    
    
    [self.delegate updateFollowing:self.objectId];
    
    [[PFUser currentUser]saveInBackground];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    UIView *hitView = [self hitTest:location withEvent:event];
    
    if (!(hitView == self.followerImage))
    {
        // redirect to image viewer.
        [self.delegate pushUserProfile:self.objectId];
    }
}


@end
