//
//  StaticProfileTableTableViewController.m
//  Bellow
//
//  Created by Paul Stavropoulos on 2/7/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import "StaticProfileTableTableViewController.h"
#import "ShareRippleSheet.h"
#import <Parse/Parse.h>
#import "BellowService.h"
#import "WebViewViewController.h"

@interface StaticProfileTableTableViewController ()
@property (nonatomic) int referralNum;

@property (strong, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation StaticProfileTableTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setHidden:NO];
    self.navigationController.hidesBarsOnSwipe = NO;
    
    // load up table points
    
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (IBAction)shareButtonPressed:(id)sender
{
    UIActivityViewController *shareController = [ShareRippleSheet shareRippleSheet:nil];
    [self presentViewController:shareController animated:YES completion:nil];
}

- (IBAction)feedbackButtonPressed:(id)sender
{
    NSString *urlString = @"mailto:wellRippleMeThis@gmail.com?subject=Feedback%20On%20Ripple";
    NSURL *url = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)legalButtonPressed:(id)sender
{
    UIActionSheet *legalSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Terms of service", @"Privacy policy", nil];
    // legalSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [legalSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (IBAction)redeemReferralButtonPressed:(id)sender {
    // pop up alert to type in referral code
    
    UIAlertView *referAlert = [[UIAlertView alloc]initWithTitle:@"Referral Code" message:@"Enter a referral code below" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Next", nil];
    referAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [referAlert show];
}
- (IBAction)FAQsPressed:(id)sender {
    //sharae to website
    UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebViewViewController *wvc = [mainstoryboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    wvc.url = [NSURL URLWithString:@"http://www.getripple.io/faq.html"];
    
    [self presentViewController:wvc animated:YES completion:nil];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self performSegueWithIdentifier:@"SegueToTermsOfService" sender:self];
            break;
        case 1:
            [self performSegueWithIdentifier:@"SegueToPrivacyPolicy" sender:self];
            break;
        case 2:
            NSLog(@"Cancel");
        default:
            break;
            // terms of service, feedback, privacy policy,
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.title isEqualToString:@"Woohoo!"])
    {
        if (buttonIndex == 1)
        {
            
            UIActivityViewController *shareController = [ShareRippleSheet shareRippleSheet:nil];
            [self presentViewController:shareController animated:YES completion:nil];
            
        }
    }
    
    else
    {
        if (buttonIndex == 1)
        {
            // run service
            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                self.referralNum = [BellowService acceptReferral:[[alertView textFieldAtIndex:0] text]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // initiate user user refresh
                    if (self.referralNum == 0)
                    {
                        UIAlertView *failedToRefer = [[UIAlertView alloc] initWithTitle:@"Uh Oh!" message:@"Looks like your referral code did not work." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
                        [failedToRefer show];
                    }
                    
                    else if (self.referralNum == -1)
                    {
                        UIAlertView *alreadyUsed = [[UIAlertView alloc]initWithTitle:@"Already referred" message:@"You have already used a referral code." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alreadyUsed show];
                    }
                    
                    else
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReferralAlert" object:[NSNumber numberWithInt: self.referralNum]];
                        
                        //UIAlertView *referralPoints = [[UIAlertView alloc] initWithTitle:@"Woohoo!" message:[NSString stringWithFormat:@"You've just earned %d points. Invite your friends to earn more", self.referralNum] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Invite", nil];
                        
                        //[referralPoints show];
                    }
                    
                });
            });
        }
    }
}


@end
