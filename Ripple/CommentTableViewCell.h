//
//  CommentTableViewCell.h
//  Ripple
//
//  Created by Paul Stavropoulos on 12/13/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import "Comment.h"
#import <UIKit/UIKit.h>
#import "CommentCellDelegate.h"

@interface CommentTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *commentText;
@property (weak, nonatomic) IBOutlet UIButton *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textHeightConstraint;  
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usernameLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *innerCellView;
// @property (weak, nonatomic) IBOutlet UIView *innerInnerCellView;

@property (strong, nonatomic) Comment *comment;

// delegate
@property (nonatomic, assign) id<CommentTableCellDelegate> delegate;

@end
