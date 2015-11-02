//
//  SwipeableCell.h
//  Ripple
//
//  Created by Paul Stavropoulos on 9/18/15.
//  Copyright © 2015 Kefi Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ripple.h"
#import "SwipeableCellDelegate.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
@interface SwipeableCell : UITableViewCell
@property (strong, nonatomic) Ripple *ripple;

@property (weak, nonatomic) IBOutlet UIView *rippleMainView;
@property (weak, nonatomic) IBOutlet UITextView *rippleTextView;
@property (weak, nonatomic) IBOutlet UIButton *userLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *numPropagatedLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *numberOfCommentsButton;
@property (weak, nonatomic) IBOutlet UIButton *commentsButton;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UIView *outerImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *outerImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet PFImageView *rippleImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topTextViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rippleImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rippleImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet UIView *dismissView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dismissViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dismissViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *dismissImageView;
@property (weak, nonatomic) IBOutlet UIView *propagateView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *propagateViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *propagateViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *propagateImageView;
@property (weak, nonatomic) IBOutlet UILabel *alreadyActedLabel;
@property (weak, nonatomic) IBOutlet UIButton *alreadyActedButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIButton *spreadButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spreadButtonLeftConstraint;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dismissButtonRightConstaint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewUnderDismissViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewUnderPropagateViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightSpreadCommentViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftSpreadCommentViewConStraint;
@property (strong, nonatomic) NSMutableArray *rippleCircles;
@property (weak, nonatomic) IBOutlet UIView *spreadCommentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spreadCommentViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spreadCommentTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *spreadTextLabel;


// The object that acts as delegate for this cell.
@property (nonatomic, assign) id<SwipeableRippleCellDelegate> delegate;
@end
