//
//  SocialMediaCollectionView.h
//  Bellow
//
//  Created by Paul Stavropoulos on 11/9/15.
//  Copyright © 2015 Kefi Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SocialMediaCollectionControllerDelegate<UIAlertViewDelegate>

- (BOOL) isCurrentUserProfile;
- (NSString *)getUserIdString;
- (void) saveSocialMediaProfile:(NSString *) profileType withHandle:(NSString *) handle;
- (NSDictionary *) getSocialMediaIconToName;

@end



@interface SocialMediaCollectionView : UICollectionViewController<UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) id<SocialMediaCollectionControllerDelegate>delegate;

@end
