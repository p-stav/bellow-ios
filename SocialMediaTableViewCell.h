//
//  SocialMediaTableViewCell.h
//  Bellow
//
//  Created by Paul Stavropoulos on 8/3/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SocialMediaTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *profileText;
@property (strong,nonatomic) NSString *profileType;

@end
