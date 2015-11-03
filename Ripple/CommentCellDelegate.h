//
//  CommentCellDelegate.h
//  Bellow
//
//  Created by Paul Stavropoulos on 4/26/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Comment.h"

@protocol CommentTableCellDelegate <NSObject>

- (void) goToUserProfile:(Comment *)comment;

@end