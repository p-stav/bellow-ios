//
//  PropagateRippleTableViewCell.m
//  Bellow
//
//  Created by Paul Stavropoulos on 11/8/14.
//  Copyright (c) 2514 Kefi Labs. All rights reserved.
//

#import "PendingRippleCell.h"

@implementation PendingRippleCell

CGPoint _originalCenter;
BOOL _deleteOnDragRelease;
BOOL _propagateOnDragRelease;

- (void)awakeFromNib
{
    // add a pan recognizer
    UIPanGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    recognizer.delegate = self;
    [self addGestureRecognizer:recognizer];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
        return NO;

    return YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.layer removeAllAnimations];
    
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    UIView *hitView = [self hitTest:location withEvent:event];
    if (hitView == self.rippleImageView)
    {
        // redirect to image viewer.
        [self.delegate goToImageView:self.currentRipple];
    }
    
    else if (hitView != self.contentView)
    {
        [self.delegate goToMapView:self.currentRipple withComments:NO];
        return;
    }
}


#pragma mark - horizontal pan gesture methods
-(BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
        return NO;
   // else if (gestureRecognizer isKindOfClass:[])
    CGPoint translation = [gestureRecognizer translationInView:[self superview]];
    // Check for horizontal gesture
    if (fabs(translation.x) > fabs(translation.y)) {
        return YES;
    }
    
    // otherwise, it's a touch
    return NO;
}

-(void)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    // make sure we're not inactive tutorial cells
    if (self.rippleMainView.alpha != 1.0)
        return;
    
    // 1
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // if the gesture has just started, record the current centre location
        _originalCenter = self.center;
    }
    
    // 2
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        // translate the center
        CGPoint translation = [recognizer translationInView:self];
        self.center = CGPointMake(_originalCenter.x + translation.x, _originalCenter.y);
        
        // change alpha for dismissing
        if (translation.x < 0)
        {
            if (fabs(translation.x) < self.frame.size.width/3.5)
            {
                self.dismissImageView.alpha = 0.3;
                [self.dismissLabel setAlpha:0.3];
            }
            else
            {
                self.dismissImageView.alpha = 1.0;
                [self.dismissLabel setAlpha:1.0];
            }
            
            //[self.dismissButton.layer setZPosition:1];
            //[self.spreadButton.layer setZPosition:0];
        }
        
        else if (translation.x > 0)
        {
            if (fabs(translation.x) < self.frame.size.width/3.5)
            {
                self.propagateImageView.alpha = 0.3;
                self.reachSpreadLabel.alpha = 0.3;
            }
            else
            {
                self.propagateImageView.alpha = 1.0;
                self.reachSpreadLabel.alpha = 1.0;
            }
            
            //[self.dismissButton.layer setZPosition:0];
            //[self.spreadButton.layer setZPosition:1];
        }
        
        else
        {
            self.propagateImageView.alpha = 1.0;
            self.dismissImageView.alpha = 1.0;
            self.dismissView.alpha = 1.0;
            self.propagateView.alpha = 1.0;
            self.reachSpreadLabel.alpha = 1.0;
        }

        // change constraints of buttons
         
        /*if(fabs(translation.x) >= self.frame.size.width / 3.5)
        {
            self.dismissButtonRightConstaint.constant = 25;
            self.spreadButtonLeftConstraint.constant = 25;
        }
        else
        {
            self.dismissButtonRightConstaint.constant = 25*(fabs(translation.x) / (self.frame.size.width/3.5));
            self.spreadButtonLeftConstraint.constant =  25*(fabs(translation.x) / (self.frame.size.width/3.5));
        }
        */
        // determine whether the item has been dragged far enough to initiate a delete / complete
        _deleteOnDragRelease = translation.x < -1 * self.frame.size.width / 4;
        _propagateOnDragRelease = translation.x  > self.frame.size.width / 4;
    }

    // 3
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        // the frame this cell would have had before being dragged
        CGRect originalFrame = CGRectMake(0, self.frame.origin.y, self.bounds.size.width, self.bounds.size.height);
        
        // actions to take; check that we're not in the tutorial
        if (_deleteOnDragRelease && (![self.currentRipple.rippleId isEqualToString:@"FakeRippleSpread"] && ![self.currentRipple.rippleId isEqualToString:@"FakeRippleTap"]))
            [self dismissRipple];
        
        else if (_propagateOnDragRelease && (![self.currentRipple.rippleId isEqualToString:@"FakeRippleDismiss"] && ![self.currentRipple.rippleId isEqualToString:@"FakeRippleTap"]))
            [self spreadRipple];
        
         else {
            // if the item is not being deleted, snap back to the original location
            [UIView animateWithDuration:0.2 animations:^{
                self.frame = originalFrame;

            }];
        }
    }
}

- (IBAction)spreadRippleFromButton:(id)sender {
    [self spreadRipple];
}

- (IBAction)deleteRippleFromButton:(id)sender {
    [self dismissRipple];
}

- (IBAction)didPressCommentButton:(id)sender {
    [self.delegate goToMapView:self.currentRipple withComments:YES];

}

- (IBAction)didPressCommentLabelButton:(id)sender {
     [self.delegate goToMapView:self.currentRipple withComments:YES];
}

- (void)dismissRipple
{
    if ([self.currentRipple.rippleId isEqualToString:@"FakeRippleTap"])
        return;
    
    // animate cell all the way over
    [self.dismissLabel setAlpha:0.0];
    [self.dismissImageView setAlpha:1.0];
    [UIView animateWithDuration:0.3 animations:^{
       self.frame = CGRectMake(-1*self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        
        //self.dismissButton.frame = CGRectMake( self.buttonsView.frame.size.width/2 - self.dismissButton.frame.size.width/2, self.dismissButton.frame.origin.y, self.dismissButton.frame.size.width, self.dismissButton.frame.size.height);
        
         //self.spreadButton.frame = CGRectMake( self.buttonsView.frame.size.width/2 - self.spreadButton.frame.size.width/2, self.spreadButton.frame.origin.y, self.spreadButton.frame.size.width, self.spreadButton.frame.size.height);
        
        //self.dismissButtonRightConstaint.constant = 25;
        //self.spreadButtonLeftConstraint.constant = 25;
        [self.spreadButton.layer setZPosition:0];
        [self.dismissButton.layer setZPosition:1.0];
        [self.dismissButton setUserInteractionEnabled:NO];
        [self.spreadButton setAlpha:0.0];
        [self.dismissButton setAlpha:1.0];
        
    }completion:^(BOOL finished) {
        // notify the delegate that this item should be deleted
        [self.delegate rippleDismissed:self.currentRipple];
        [self.dismissButton setImage:[UIImage imageNamed:@"dismissRippleIcon.png"] forState:UIControlStateNormal];
    }];
    
}

- (void)spreadRipple
{
    if ([self.currentRipple.rippleId isEqualToString:@"FakeRippleTap"])
        return;
    
    [self.propagateImageView setAlpha:1.0];
    [self.reachSpreadLabel setAlpha:0.0];
    
    // animate cell all the way over
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        
        //self.dismissButton.frame = CGRectMake( self.buttonsView.frame.size.width/2 - self.dismissButton.frame.size.width/2, self.dismissButton.frame.origin.y, self.dismissButton.frame.size.width, self.dismissButton.frame.size.height);
       
       // self.spreadButton.frame = CGRectMake( self.buttonsView.frame.size.width/2 - self.spreadButton.frame.size.width/2, self.spreadButton.frame.origin.y, self.spreadButton.frame.size.width, self.spreadButton.frame.size.height);


       // self.dismissButtonRightConstaint.constant = 25;
        //self.spreadButtonLeftConstraint.constant = 25;
        [self.spreadButton.layer setZPosition:1.0];
        [self.spreadButton.layer setZPosition:0];
        [self.spreadButton setUserInteractionEnabled:NO];
        [self.spreadButton setAlpha:1.0];
        [self.dismissButton setAlpha:0.0];
    }completion:^(BOOL finished) {
        [self.propagateImageView setHidden:YES];
        [self.spreadButton setImage:[UIImage imageNamed:@"propagateButton.png"] forState:UIControlStateNormal];
    }];
    
    [UIView animateWithDuration:0.5 animations:^{
        // animate circles breh!
        for (int i = 0; i < 3; i++)
        {
            UIView *outerCircle = [self.rippleCircles objectAtIndex:i*2];
            UIView *innerCircle = [self.rippleCircles objectAtIndex:i*2 + 1];
            
            outerCircle.backgroundColor = [UIColor whiteColor];
            innerCircle.backgroundColor = [UIColor whiteColor];
            // outerCircle.backgroundColor = [UIColor colorWithRed:1 green:196/255.0 blue:50/255.0 alpha:1.0];
            
            outerCircle.transform = CGAffineTransformMakeScale(self.frame.size.height/(2*(i+1)), self.frame.size.height/(2.0 * (i +1)));
            innerCircle.transform = CGAffineTransformMakeScale(self.frame.size.height/(2*(i+1)), self.frame.size.height/(2.0 * (i +1)));
            outerCircle.alpha = 0;
            innerCircle.alpha = 0;
        }
    }completion:^(BOOL finished) {
        [self.delegate ripplePropagated:self.currentRipple];
    }];
}


-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    // go to URL view
    NSLog(@"hi");
    
    return NO;
    
}

- (IBAction)didPressUser:(id)sender {
    if (![self.currentRipple.rippleId isEqualToString:@"FakeRippleSpread"] && ![self.currentRipple.rippleId isEqualToString:@"FakeRippleTap"] && ![self.currentRipple.rippleId isEqualToString:@"FakeRippleDismiss"])
        [self.delegate goToUserProfile:self.currentRipple];
}

@end
