//
//  SocialMediaCollectionViewController.m
//  Ripple
//
//  Created by Dan Li on 6/27/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import "SocialMediaTableViewCell.h"
#import "SocialMediaCollectionViewController.h"
#import "WebViewViewController.h"
#import <Parse/Parse.h>


@interface SocialMediaCollectionViewController ()
@property (nonatomic) BOOL performSegue;
@property (strong, nonatomic) NSDictionary *socialMediaIconToName;

@end

@implementation SocialMediaCollectionViewController

static NSString * const reuseIdentifier = @"MyCell";
BOOL isCurrentUserProfile;
NSDictionary *socialMediaIcons;


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
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


- (IBAction)iconTapped:(NSString *)profileType {
    
    if([_delegate isCurrentUserProfile]) {
        // If we're on the current user's profile, allow the user to enter their social media information

        if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:profileType
                                                                                 message:[NSString stringWithFormat:@"Set your %@ handle", profileType]
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        

        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            if(![profileType isEqualToString: @"Website"])
                textField.placeholder = @"Enter your profile name";
            else
                textField.text = @"http://";
        
            // If the user has configured that profile handle, display the handle as the default text
            if([PFUser currentUser][@"accessibleProfiles"] != nil && [[PFUser currentUser][@"accessibleProfiles"][profileType] length] !=0)
                
                textField.text = [PFUser currentUser][@"accessibleProfiles"][profileType];
        }];
        
            
            
            UIAlertAction *ok = [UIAlertAction
                                       actionWithTitle:@"Ok"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSString *handle = ((UITextField *)[alertController.textFields objectAtIndex:0]).text;
                                           [_delegate saveSocialMediaProfile: profileType withHandle: handle];
                                           
                                           [self.tableView reloadData];
                                       }];
            UIAlertAction* cancel = [UIAlertAction
                                     actionWithTitle:@"Cancel"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
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
                [self.tableView reloadData];
            });
        });
    }
    else
        socialMediaIcons = self.socialMediaIconToName;
    
    
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return socialMediaIcons.count;
}

- (SocialMediaTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    SocialMediaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    UIImage *image;
    NSArray *allAccountTypes = [socialMediaIcons allKeys];
    cell.profileType =  allAccountTypes[[indexPath row]];
    
    image = [UIImage imageNamed:self.socialMediaIconToName[cell.profileType]];
    [cell.profileImage setImage:image];
    
    NSString *handle;
    if (!isCurrentUserProfile)
        handle = socialMediaIcons[cell.profileType];
    else
        handle = [PFUser currentUser][@"accessibleProfiles"][cell.profileType];
    
    if([handle isEqualToString:@""] || handle == nil)
        cell.profileText.text = [NSString stringWithFormat:@"Add your %@",cell.profileType];
    
    else
        cell.profileText.text = handle;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *allAccountTypes = [socialMediaIcons allKeys];
    NSString *profileType =  allAccountTypes[[indexPath row]];
    
    
    [self iconTapped:profileType];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex == 1)
    {
        UITextField *input = [alertView textFieldAtIndex:0];
        NSString *handle = input.text;
        [_delegate saveSocialMediaProfile:alertView.title withHandle: handle];
        
        [self.tableView reloadData];
    }
}

@end
