//
//  TrendingCollectionViewCell.h
//  Bellow
//
//  Created by Paul Stavropoulos on 10/4/15.
//  Copyright © 2015 Kefi Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "Bellow.h"

@interface TrendingCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *masterView;
@property (weak, nonatomic) IBOutlet PFImageView *rippleImageView;
@property (weak, nonatomic) IBOutlet UITextView *rippleTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageWidthConstraint;

@property (strong, nonatomic) Bellow *ripple;
@end
