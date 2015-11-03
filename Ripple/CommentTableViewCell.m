//
//  CommentTableViewCell.m
//  Bellow
//
//  Created by Paul Stavropoulos on 12/13/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import "CommentTableViewCell.h"

@implementation CommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)didTouchUsername:(id)sender {
    [self.delegate goToUserProfile:self.comment];
}

@end
