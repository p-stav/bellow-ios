//
//  UserSearchHeaderViewCell.m
//  Bellow
//
//  Created by Paul Stavropoulos on 11/4/15.
//  Copyright © 2015 Kefi Labs. All rights reserved.
//

#import "UserSearchHeaderViewCell.h"

@implementation UserSearchHeaderViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.userSearchView setBackgroundColor:[UIColor colorWithRed:0 green:123.0f/255.0 blue:255.0 alpha:1.0]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.delegate goToSearchView];
}



@end
