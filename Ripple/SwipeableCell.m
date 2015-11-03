    //
//  SwipeableCell.m
//  Bellow
//
//  Created by Paul Stavropoulos on 9/18/15.
//  Copyright © 2015 Kefi Labs. All rights reserved.
//

#import "SwipeableCell.h"
#import "BellowService.h"
#import "Flurry.h"
#import <Parse/Parse.h>
@implementation SwipeableCell

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
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    UIView *hitView = [self hitTest:location withEvent:event];
    if (hitView == self.rippleImageView)
    {
        // redirect to image viewer.
        [self.delegate goToImageView:self.ripple];
    }
    
    else if (hitView != self.contentView)
    {
        [self.delegate goToMapView:self.ripple withComments:NO];
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
    
    if (self.ripple.actedUponState != 0)
    {
        // shake and return no
        CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
        [shake setDuration:0.1];
        [shake setRepeatCount:1];
        [shake setAutoreverses:YES];
        [shake setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([self center].x - 5.0f, [self center].y)]];
        [shake setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([self center].x + 5.0f, [self center].y)]];
        [[self layer] addAnimation:shake forKey:@"position"];
        
        return;
    }

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
                self.spreadReachLabel.alpha = 0.3;
            }
            else
            {
                self.propagateImageView.alpha = 1.0;
                self.spreadReachLabel.alpha = 1.0;
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
        }
        
        // change constraints of buttons
        
    /*
         if(fabs(translation.x) >= self.frame.size.width / 3.5)
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
        
        if (_deleteOnDragRelease)
            [self dismissRipple];
        
        else if (_propagateOnDragRelease)
            [self spreadRipple];
        
        else {
            // if the item is not being deleted, snap back to the original location
             [UIView animateWithDuration:0.2 animations:^{
                self.frame = originalFrame;
            }];
            
        /*
            [UIView animateWithDuration:0.2 animations:^{
                self.dismissButton.frame = CGRectMake(0, 0, self.dismissButton.frame.size.width, self.dismissButton.frame.size.height);
                self.spreadButton.frame = CGRectMake(44, 0, self.spreadButton.frame.size.width, self.spreadButton.frame.size.height);
            }completion:^(BOOL finished) {
                self.dismissButtonRightConstaint.constant = 0;
                self.spreadButtonLeftConstraint.constant = 0;
            }];
        */
        }
    }
}

- (void)dismissRipple
{
    [self.dismissLabel setAlpha:0.0];
    if ([self.ripple.creatorId isEqualToString:[PFUser currentUser].objectId])
        return;
    
    // update Bellow object
    //self.ripple.actedUponState = 2;
    
    if (self.ripple.miniRippleId != nil)
        [BellowService dismissRipple:self.ripple];
    else
        [BellowService dismissSwipeableRipple:self.ripple];
    
    [self.delegate rippleDismissed:self.ripple];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"swipedRipple" object:self.ripple];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"incrementScore" object:nil];
    
    // animate buttons
    [self.dismissImageView setAlpha:1.0];
    [UIView animateWithDuration:0.2 animations:^{
        
        self.frame = CGRectMake(-1*self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        
        //self.dismissButton.frame = CGRectMake( self.buttonsView.frame.size.width/2 - self.dismissButton.frame.size.width/2, self.dismissButton.frame.origin.y, self.dismissButton.frame.size.width, self.dismissButton.frame.size.height);
        
        //self.spreadButton.frame = CGRectMake( self.buttonsView.frame.size.width/2 - self.spreadButton.frame.size.width/2, self.spreadButton.frame.origin.y, self.spreadButton.frame.size.width, self.spreadButton.frame.size.height);
        
        self.dismissButtonRightConstaint.constant = 25;
        self.spreadButtonLeftConstraint.constant = 25;
        [self.spreadButton.layer setZPosition:0];
        [self.dismissButton.layer setZPosition:1.0];
        [self.dismissButton setUserInteractionEnabled:NO];
        [self.spreadButton setAlpha:0.0];
        [self.dismissButton setAlpha:1.0];
        
    }completion:^(BOOL finished) {
        [NSThread sleepForTimeInterval:0.2f];
        
        [self.dismissButton setHidden:YES];
        [self.spreadButton setHidden:YES];

        [self.alreadyActedButton setImage:[UIImage imageNamed:@"alreadyDismissed.png"] forState:UIControlStateNormal];
        [self.alreadyActedButton setHidden:NO];
         //setImage:[UIImage imageNamed:@"dismissRippleIcon.png"] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        }];
    }];
    
}

- (void)spreadRipple
{
    [self.spreadReachLabel setAlpha:0.0];
    
    if ([self.ripple.creatorId isEqualToString:[PFUser currentUser].objectId])
        return;
    
    // update ripple object
    if (self.ripple.miniRippleId != nil)
        [BellowService propagateRipple:self.ripple];
    else
        [BellowService propagateSwipeableRipple:self.ripple];
    
    [self.delegate ripplePropagated:self.ripple];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"swipedRipple" object:self.ripple];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"incrementScore" object:nil];

    
    //animate buttons
    [self.propagateImageView setAlpha:1.0];
    self.ripple.actedUponState = 1;
    
    // incrmeent spread number
    [self.numPropagatedLabel setText:[NSString stringWithFormat:@"spread %d times", self.ripple.numberPropagated]];
    
    // animate cell all the way over
    [UIView animateWithDuration:0.2 animations:^{
        // animate frams to spread
        self.frame = CGRectMake(self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        
        //self.dismissButton.frame = CGRectMake( self.buttonsView.frame.size.width/2 - self.dismissButton.frame.size.width/2, self.dismissButton.frame.origin.y, self.dismissButton.frame.size.width, self.dismissButton.frame.size.height);
        
        //self.spreadButton.frame = CGRectMake( self.buttonsView.frame.size.width/2 - self.spreadButton.frame.size.width/2, self.spreadButton.frame.origin.y, self.spreadButton.frame.size.width, self.spreadButton.frame.size.height);
        
        
        self.dismissButtonRightConstaint.constant = 25;
        self.spreadButtonLeftConstraint.constant = 25;
        [self.spreadButton.layer setZPosition:1.0];
        [self.spreadButton.layer setZPosition:0];
        [self.spreadButton setUserInteractionEnabled:NO];
        [self.spreadButton setAlpha:1.0];
        [self.dismissButton setAlpha:0.0];
    }completion:^(BOOL finished) {

        [UIView animateWithDuration:0.3 animations:^{
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
            [self.propagateImageView setHidden:YES];
            [self.spreadButton setHidden:YES];
            [self.dismissButton setHidden:YES];
             //:[UIImage imageNamed:@"propagateButton.png"] forState:UIControlStateNormal];
            
            [self.alreadyActedButton setImage:[UIImage imageNamed:@"alreadySpread.png"] forState:UIControlStateNormal];
            [self.alreadyActedButton setHidden:NO];
            
            // move cell back
            [UIView animateWithDuration:0.2 animations:^{
                self.frame = CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
            }];
        }];
        
    
    }];
}


-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    // go to URL view
    NSLog(@"hi");
    
    return NO;
    
}


#pragma mark - button methods
- (IBAction)spreadRippleFromButton:(id)sender {
    [self spreadRipple];
}

- (IBAction)deleteRippleFromButton:(id)sender {
    [self dismissRipple];
}

- (IBAction)didPressActedUponButton:(id)sender {
    
    if (self.ripple.actedUponState == 1)
    {
        [self.alreadyActedLabel setText:@"You already spread this ripple"];
        [self.alreadyActedLabel setTextColor:[UIColor colorWithRed:3.0/255.0f green:123.0f/255 blue:255.0f/255 alpha:1.0]];
    }
    
    else if(self.ripple.actedUponState == 2)
    {
        [self.alreadyActedLabel setText:@"You already dismissed this ripple"];
        [self.alreadyActedLabel setTextColor:[UIColor colorWithRed:1.0f green:89.0f/255 blue:120.0f/255 alpha:1.0]];
    }
    
    [self.alreadyActedLabel setAlpha:0.0];
    [self.alreadyActedButton setAlpha:0.0];
    [self.alreadyActedLabel setHidden:NO];
    [self.commentsButton setHidden:YES];
    [self.numberOfCommentsButton setHidden:YES];
    [self.spreadTextLabel setHidden:YES];
    [self.numPropagatedLabel setHidden:YES];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.alreadyActedLabel setAlpha:1.0];

    }completion:^(BOOL finished) {
        [NSThread sleepForTimeInterval:1.0f];
        [UIView animateWithDuration:0.3 animations:^{
            [self.alreadyActedLabel setAlpha:0.0];
        }completion:^(BOOL finished) {
            [self.alreadyActedLabel setHidden:YES];
            [self.alreadyActedLabel setAlpha:1.0];
            [self.alreadyActedButton setAlpha:1.0];
            
            [self.commentsButton setHidden:NO];
            [self.numberOfCommentsButton setHidden:NO];
            [self.spreadTextLabel setHidden:NO];
            [self.numPropagatedLabel setHidden:NO];
        }];
    }];
}

- (IBAction)didPressCommentButton:(id)sender {
    [self.delegate goToMapView:self.ripple withComments:YES];
    
}

- (IBAction)didPressCommentLabelButton:(id)sender {
    [self.delegate goToMapView:self.ripple withComments:YES];
}

- (IBAction)didPressUser:(id)sender {
    [self.delegate goToUserProfile:self.ripple];
}
@end
