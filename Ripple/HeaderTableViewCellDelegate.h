//
//  HeaderTableViewCellDelegate.h
//  Bellow
//
//  Created by Paul Stavropoulos on 4/23/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HeaderCellDelegate <NSObject>

- (void)dismissTableUnderlay;
- (void)showTableUnderlay;
- (void) passSortMethod:(int)sortMethod passFilterMethod: (int)filterMethod;


@end