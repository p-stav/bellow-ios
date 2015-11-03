//
//  MyRippleCell.m
//  Bellow
//
//  Created by Gal Oshri on 9/23/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import "MyRippleCell.h"

@implementation MyRippleCell

- (void)awakeFromNib
{
    // Initialization code
    
    // add a pan recognizer
    //UIPanGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    //recognizer.delegate = self;
    //[self addGestureRecognizer:recognizer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
        return NO;
    return YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    UIView *hitView = [self hitTest:location withEvent:event];

    if (![self.rippleImageView isHidden] && hitView == self.rippleImageView)
    {
        // redirect to image viewer.
        [self.delegate goToImageView:self.ripple];
    }
    else
    {
        [self.delegate goToMapView:self.ripple withComments:NO];
        return;
    }
}

- (IBAction)goToProfile:(id)sender {
    [self.delegate goToUserProfile:self.ripple];
}

- (IBAction)didPressCommentNumber:(id)sender {
    [self.delegate goToMapView:self.ripple withComments:YES];
}

- (IBAction)didPressCommentImage:(id)sender {
    [self.delegate goToMapView:self.ripple withComments:YES];
}


@end
