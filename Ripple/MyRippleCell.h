//
//  MyRippleCell.h
//  Bellow
//
//  Created by Gal Oshri on 9/23/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bellow.h"
#import <Parse/Parse.h>
#import "MyRippleCellDelegate.h"
#import <ParseUI/ParseUI.h>

@interface MyRippleCell : UITableViewCell

@property (strong, nonatomic) Bellow *ripple;

@property (strong, nonatomic) IBOutlet UITextView *rippleTextView;
@property (strong, nonatomic) IBOutlet UILabel *numberPropagatedLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestamp;
@property (strong, nonatomic) IBOutlet UIButton *usernameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usernameLabelWidthConstraint;

@property (weak, nonatomic) IBOutlet UIButton *numberOfCommentsButton;
@property (weak, nonatomic) IBOutlet UIButton *commentsButton;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topTextViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spreadCommentViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *spreadCommentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cityLabelWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightSpreadCommentViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftSpreadCommentViewConStraint;


@property (weak, nonatomic) IBOutlet UIView *outerImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *outerImageViewHeightConstraint;
@property (strong, nonatomic) IBOutlet PFImageView *rippleImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rippleImageViewWidthConstraint; 
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rippleImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *outerImageViewWidthConstraint;

@property (weak, nonatomic) IBOutlet UIView *rippleMainView;


// acting delegate
@property (nonatomic, assign) id<ActedRippleCellDelegate> delegate;


// @property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *leftSideRippleExposureCount;
// @property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *rightSideRippleExposureCount;


@end
