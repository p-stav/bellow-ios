//
//  UITextView_RippleTextView.m
//  Bellow
//
//  Created by Dan Li on 6/21/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import "MyRippleCellDelegate.h"
#import "MyRippleCell.h"

@interface RippleTextView : UITextView
@end

@implementation RippleTextView

// We need the text selectable so links can be clicked, but we don't actually want any selection occuring
- (BOOL)canBecomeFirstResponder {
    return NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Get a pointer to MyRippleCell 3 levels up
    UIView *view = self.superview;
    view = view.superview;
    view = view.superview;
    
    [view touchesEnded:touches withEvent:event];
}


@end