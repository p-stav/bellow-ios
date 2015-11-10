//
//  SocialMediaCollectionView.m
//  Bellow
//
//  Created by Paul Stavropoulos on 11/9/15.
//  Copyright © 2015 Kefi Labs. All rights reserved.
//

#import "SocialMediaCollectionView.h"
#import "WebViewViewController.h"
#import <Parse/Parse.h>
#import "SocialMediaCollectionViewCell.h"

@interface SocialMediaCollectionView ()
@property (nonatomic) BOOL performSegue;
@property (strong, nonatomic) NSDictionary *socialMediaIconToName;
@end

@implementation SocialMediaCollectionView
static NSString * const reuseIdentifier = @"SocialMediaCollection";
BOOL isCurrentUserProfile;
NSDictionary *socialMediaIcons;


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"WebViewSegue"]) {
        WebViewViewController *wvc = (WebViewViewController *)segue.destinationViewController;
        NSString *profileType = (NSString *) sender;
        NSString *url;
        NSString *handle = socialMediaIcons[profileType];
        
        if([profileType isEqualToString:@"Website"])
        {
            url = handle;
            
            self.performSegue = YES;
        }
        
        else if ([profileType isEqualToString:@"Twitter"])
        {
            url = [NSString stringWithFormat:
                   @"http://twitter.com/%@", handle];
            
            self.performSegue = YES;
        }
        
        else if ([profileType isEqualToString:@"Instagram"]) {
            url = [NSString stringWithFormat:
                   @"http://instagram.com/%@", handle];
        }
        
        wvc.url = [NSURL URLWithString:url];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    socialMediaIcons = nil;
    isCurrentUserProfile = [self.delegate isCurrentUserProfile];
    
    self.socialMediaIconToName= [_delegate getSocialMediaIconToName];
    
    if (!isCurrentUserProfile)
    {
        NSString *userId = [self.delegate getUserIdString];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // grab accessibleProfiles
            PFQuery *user = [PFQuery queryWithClassName:@"_User"];
            [user selectKeys:@[@"accessibleProfiles"]];
            PFUser *userObject = (PFUser *)[user getObjectWithId:userId];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary* profileToHandle = userObject[@"accessibleProfiles"];
                NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc] init];
                
                for(NSString *key in profileToHandle)
                {
                    if(![[profileToHandle objectForKey:key] isEqualToString:@""])
                        [userDictionary setObject:profileToHandle[key] forKey:key];
                }
                
                socialMediaIcons = userDictionary;
                [self.collectionView reloadData];
            });
        });
    }
    else
        socialMediaIcons = self.socialMediaIconToName;
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
}


#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return socialMediaIcons.count;
}

- (SocialMediaCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SocialMediaCollectionViewCell *cell = (SocialMediaCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    UIImage *image;
    NSArray *allAccountTypes = [socialMediaIcons allKeys];
    cell.profileType =  allAccountTypes[[indexPath row]];
    
    image = [UIImage imageNamed:self.socialMediaIconToName[cell.profileType]];
    [cell.socialMediaImage setImage:image];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *allAccountTypes = [socialMediaIcons allKeys];
    NSString *profileType =  allAccountTypes[[indexPath row]];
    
    
    [self iconTapped:profileType];

    return YES;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(40,40);
}

- (void)iconTapped:(NSString *)profileType {
    
    if([_delegate isCurrentUserProfile]) {
        // If we're on the current user's profile, allow the user to enter their social media information
        
        if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:profileType message:[NSString stringWithFormat:@"Set your %@ handle", profileType] preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                if(![profileType isEqualToString: @"Website"])
                    textField.placeholder = @"Enter your profile name";
                else
                    textField.text = @"http://";
                
                // If the user has configured that profile handle, display the handle as the default text
                if([PFUser currentUser][@"accessibleProfiles"] != nil && [[PFUser currentUser][@"accessibleProfiles"][profileType] length] !=0)
                    
                    textField.text = [PFUser currentUser][@"accessibleProfiles"][profileType];
            }];
            
            
            
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                 NSString *handle = ((UITextField *)[alertController.textFields objectAtIndex:0]).text;
                 [_delegate saveSocialMediaProfile: profileType withHandle: handle];
                 
                 [self.collectionView reloadData];
             }];
            
            UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [alertController dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [alertController addAction:ok];
            [alertController addAction:cancel];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else
        {
            UIAlertView *alertController = [[UIAlertView alloc] initWithTitle:profileType message:[NSString stringWithFormat:@"Set your %@ handle:", profileType]  delegate:self cancelButtonTitle:@"Cancel"otherButtonTitles:@"OK", nil];
            
            // textfield
            alertController.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField *textField = [alertController textFieldAtIndex:0];
            
            if(![profileType isEqualToString: @"Website"])
                textField.placeholder = @"Enter your profile name";
            else
                textField.text = @"www.";
            
            // If the user has configured that profile handle, display the handle as the default text
            if(socialMediaIcons != nil && [socialMediaIcons[profileType] length] != 0) {
                textField.text = socialMediaIcons[profileType];
            }
            
            [alertController show];
        }
        
    } else {
        NSString *handle = socialMediaIcons[profileType];
        
        if([profileType isEqualToString:@"Website"])
        {
            [self performSegueWithIdentifier:@"WebViewSegue" sender:profileType];
        }
        
        else if ([profileType isEqualToString:@"Twitter"])
        {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?screen_name=%@",handle]]])
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?screen_name=%@",handle]]];
                
            }
            else
            {
                [self performSegueWithIdentifier:@"WebViewSegue" sender:profileType];
            }
        }
        
        else if ([profileType isEqualToString:@"Instagram"]) {
            
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"instagram://user?username=%@",handle]]])
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"instagram://user?username=%@",handle]]];
            else {
                [self performSegueWithIdentifier:@"WebViewSegue" sender:profileType];
            }
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        UITextField *input = [alertView textFieldAtIndex:0];
        NSString *handle = input.text;
        [_delegate saveSocialMediaProfile:alertView.title withHandle: handle];
        
        [self.collectionView reloadData];
    }
}

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

/*
 // Uncomment this method to specify if the specified item should be highlighted during tracking
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
 }
 */

@end
