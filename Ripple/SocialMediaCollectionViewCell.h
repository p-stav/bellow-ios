//
//  SocialMediaCollectionViewCell.h
//  Bellow
//
//  Created by Paul Stavropoulos on 11/9/15.
//  Copyright © 2015 Kefi Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SocialMediaCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *socialMediaImage;
@property (strong,nonatomic) NSString *profileType;

@end
