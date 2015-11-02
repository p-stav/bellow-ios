//
//  StartRippleTableViewCell.h
//  Ripple
//
//  Created by Paul Stavropoulos on 1/27/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartRippleTableViewCell : UITableViewCell
// @property (weak, nonatomic) IBOutlet UIImageView *cellTypeImage;
@property (weak, nonatomic) IBOutlet UILabel *appendLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@property (weak, nonatomic) IBOutlet UIButton *dismissImage;
@property (strong, nonatomic) NSDictionary *cellData;

@end
