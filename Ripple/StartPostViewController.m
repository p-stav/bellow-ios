//
//  ViewController.m
//  Bellow
//
//  Created by Gal Oshri on 9/10/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import "FacebookService.h"

#import <Social/Social.h>
#import "StartPostViewController.h"
#import "RippleLogInView.h"
#import "RippleSignUpView.h"
#import "BellowService.h"
#import "ImageCropping.h"
#import "TwitterService.h"
#import "Flurry.h"
#import <ParseTwitterUtils/ParseTwitterUtils.h>



@interface StartPostViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *pebbleAnimationImg;
@property (weak, nonatomic) IBOutlet UIButton *rippleImageButton;
@property (weak, nonatomic) IBOutlet UIImageView *rippleImage;
@property (weak, nonatomic) IBOutlet UIButton *deleteImageButton;
@property (weak, nonatomic) IBOutlet UILabel *characterCount;
@property (weak, nonatomic) IBOutlet UIButton *doneEditingButton;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;

@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *instagramButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stoneHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stoneWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraintStoneImg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pebbleBottomConstraint;

@property BOOL keyboardOrNah;
@property BOOL isEditing;
@property BOOL postToTwitterOrNah;
@property BOOL postToInstagramOrNah;
@property BOOL postToFacebookOrNah;

// @property BOOL postToFbOrNah;
@property (strong, nonatomic) NSMutableArray *rippleCircles;
@property (strong, nonatomic) UIImage *originalImage;
@property (strong, nonatomic) NSArray *tableData;
@property float originalbottomConstraintStoneButton;
@property float originalRippleBackgroundViewHeight;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;



// @property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraintStoneButton;
@end

@implementation StartPostViewController

NSString *defaultString;
UIImagePickerController *picker;



- (IBAction)unwindToStartRippleView:(UIStoryboardSegue *)segue {
    
    /* if ([segue.identifier isEqualToString:@"UnwindToCameraAfterSnipe"])
    {
        if ([segue.sourceViewController isKindOfClass:[SnipeSubmitView class]])
        {
            SnipeSubmitView *ssv = (SnipeSubmitView *)segue.sourceViewController;
            self.goToGameId = ssv.selectedGameId;
        }
    } 
    */
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rippleTextView.delegate = self;
    self.isEditing = NO;
    
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    if ([userData objectForKey:@"defaultRippleString"] != nil)
        defaultString = [NSString stringWithString:[userData objectForKey:@"defaultRippleString"]];
    else
        defaultString = @"Start a ripple";
    
    
    [Flurry logEvent:@"View_Start"];
    
    
    // prepare buttons.
    [self.twitterButton setAlpha:0.4];
    [self.instagramButton setAlpha:0.4];
    [self.facebookButton setAlpha:0.4];
    [self.rippleImage setHidden:YES];
    [self.deleteImageButton setHidden:YES];
    
    self.originalbottomConstraintStoneButton = self.bottomConstraintStoneImg.constant;
    
    //hide fb and insta for now
    [self.instagramButton setHidden:YES];
    [self.facebookButton setHidden:YES];
    
    // set paragraph spacing for text view, and assign defaulstring to text of it
    self.rippleTextView.text = defaultString;
    self.rippleTextView.layoutManager.delegate = self;
    self.rippleTextView.textAlignment = NSTextAlignmentLeft;
    [self createRippleCircles];
    
    
    // set responder for keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardFrameDidChange:)
                                                 name:UIKeyboardWillChangeFrameNotification object:nil];
    [self.characterCount setHidden:YES];
    [self.doneEditingButton setHidden:YES];
    
    [PFAnalytics trackEvent:@"StartARippleLoaded" dimensions:nil];
    
    // remove twitter account ***DANGER***
    /*
    [PFTwitterUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
        if (!error && succeeded) {
            NSLog(@"The user is no longer associated with their Twitter account.");
        }
    }];
    */
    
    // remove facebook  account ***DANGER***
    /*
    [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser]];
    */
    
    // set bools to correct value
    self.postToTwitterOrNah = NO;
    self.postToFacebookOrNah = NO;
    self.postToInstagramOrNah = NO;
    self.keyboardOrNah = NO;
    self.isEditing = NO;
}

- (IBAction)startRippleSwipe:(UISwipeGestureRecognizer *)sender {
    [self startRipple:nil];
}


- (IBAction)startRipple:(UIButton *)sender
{
    if ([self.characterCount.text intValue] >= 0)
    {
        // notification center to goToFourthTab
        [[NSNotificationCenter defaultCenter] postNotificationName:@"goToProfile" object:nil];
        
        // series of checks to make sure we don't ripple dumb things
        // don't ripple nothing or space
        if (([self.rippleTextView.text isEqualToString:@" "] || [self.rippleTextView.text isEqualToString:@""] || [self.rippleTextView.text isEqualToString:@"  "] || [self.rippleTextView.text isEqualToString:@"   "] || [self.rippleTextView.text isEqualToString:defaultString]))
        {
            UIAlertView *needTextAlert = [[UIAlertView alloc] initWithTitle:@"Empty ripple" message:@"You must enter text!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [needTextAlert show];
            return;
        }
        
        if (self.postToTwitterOrNah)
        {
            [self sendTweet];
            
        }
        
        else
            [self rippleAnimation];
        
       
        
        [self endEditing];
        
        
        
        

        // user settings to determine if sent first ripple
        // 1 = just sent first Bellow, 2 = already sent it
        NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
        
        NSNumber *sentFirstRipple = [userData objectForKey:@"sentFirstRipple"];
        int sentFirstRippleCheck = [sentFirstRipple intValue];
        
        if (sentFirstRippleCheck < 17)
        {
            [userData setObject:[NSNumber numberWithInteger:(sentFirstRippleCheck + 1)] forKey:@"sentFirstRipple"];
            [userData synchronize];

        }
        
        // started ripple analytics
        [PFAnalytics trackEvent:@"RippleStarted" dimensions:nil];
        [Flurry logEvent:@"Ripple_Started"];
    }
}

- (void)rippleAnimation
{
    double jumpTime = 0.5;
    double sinkTime = 0.8;
    
    self.rippleTextView.alpha = 0;
    self.dismissButton.alpha = 0;
    self.rippleButton.alpha = 0;
    self.pebbleAnimationImg.hidden = NO;
    
    [UIView animateWithDuration:jumpTime animations:^{
        // edit bottom constraint of the stone. IOS 7 and IOS 8 respond differently...
        if ([[NSProcessInfo processInfo] respondsToSelector:@selector(isOperatingSystemAtLeastVersion:)])
            self.bottomConstraintStoneImg.constant = [UIScreen mainScreen].bounds.size.height - 100 - self.rippleButton.frame.size.height/2;
        else
            self.bottomConstraintStoneImg.constant = [UIScreen mainScreen].bounds.size.height - 100 - self.rippleButton.frame.size.height;
        
        [self.view layoutIfNeeded];
    }];
    
    [UIView animateKeyframesWithDuration:jumpTime/2.0 delay:0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
            self.pebbleAnimationImg.transform = CGAffineTransformMakeScale(1.2, 1.2);
        } completion:^(BOOL finished) {
            // NOOP
        }];
    
    [UIView animateKeyframesWithDuration:jumpTime/2.0 delay:jumpTime/2.0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
            self.pebbleAnimationImg.transform = CGAffineTransformMakeScale(1/1.2, 1/1.2);
        } completion:^(BOOL finished) {
            //NOOP
        }];
    
    [UIView animateKeyframesWithDuration:sinkTime delay:jumpTime - 0.4 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
            self.pebbleAnimationImg.transform = CGAffineTransformMakeScale(0.001, 0.001);
        } completion:^(BOOL finished) {
            //NOOP
        }];
    
    for (int i = 0; i < 5; i++)
    {
        [UIView animateKeyframesWithDuration:1.5 delay:jumpTime + i*0.1 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
            UIView *outerCircle = [self.rippleCircles objectAtIndex:i*2];
            UIView *innerCircle = [self.rippleCircles objectAtIndex:i*2 + 1];
            
            outerCircle.backgroundColor = [UIColor blueColor];
            innerCircle.backgroundColor = [UIColor blackColor];
            
            outerCircle.transform = CGAffineTransformMakeScale(400, 400);
            innerCircle.transform = CGAffineTransformMakeScale(400, 400);
            outerCircle.alpha = 0;
            innerCircle.alpha = 0;
            
        } completion:^(BOOL finished) {
            // reset page
            [self dismissViewControllerAnimated:YES completion:^{
                dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [BellowService startRipple:self.rippleTextView.text withImage:self.originalImage];
                });
            }];
        }];
    }
}

- (void)createRippleCircles
{
    self.rippleCircles = [[NSMutableArray alloc] init];

    for (int i = 0; i < 5; i ++)
    {
        
        UIView *outerCircle = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x - 1.1,
                                                                       100 - 1.1,
                                                                       2.2,
                                                                       2.2)];
        outerCircle.alpha = 0.3;
        outerCircle.layer.cornerRadius = 1.1;
        
        
        UIView *innerCircle = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x - 1,
                                                                       100 - 1,
                                                                       2,
                                                                       2)];
        innerCircle.alpha = 0.3;
        innerCircle.layer.cornerRadius = 1;
        
        
        
        
        [self.view addSubview:outerCircle];
        [self.view addSubview:innerCircle];
        
        [self.rippleCircles addObject:outerCircle];
        [self.rippleCircles addObject:innerCircle];
    }

}

#pragma mark - image picker
- (IBAction)didPressAddImageButton:(id)sender
{
    UIActionSheet *pickImageMethod;
    // create aciton sheet
    if (self.originalImage) {
        pickImageMethod = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Remove photo", @"Add from photo Library",@"Take photo", nil];

    }
    else
        pickImageMethod = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photo Library",@"Take Photo", nil];
    
    [pickImageMethod showInView:self.view];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *) Picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    
    // set original image
    self.originalImage = [UIImage imageWithCGImage:[[info objectForKey:UIImagePickerControllerEditedImage] CGImage] scale:1.0 orientation:UIImageOrientationUp];
    
    if(self.originalImage==nil)
        self.originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if(self.originalImage==nil)
        self.originalImage = [info objectForKey:UIImagePickerControllerCropRect];

    [self.view layoutIfNeeded];
    
    

    [self.rippleImage setImage:self.originalImage];
    [self.rippleImage setHidden:NO];
    [self.deleteImageButton setHidden:NO];
    [self.rippleImageButton setHidden:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    picker = [[UIImagePickerController alloc] init];
    [picker setDelegate:self];

    
    if (self.originalImage && buttonIndex == 0)
    {
        [self deleteImageFromRipple:nil];
        return;
    }

    if((buttonIndex != 2 && !self.originalImage) || (buttonIndex != 3 && self.originalImage))
    {
        if((buttonIndex == 1 && !self.originalImage) || (buttonIndex == 2 && self.originalImage))
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            }
        }
        
        if((buttonIndex == 0 && !self.originalImage) || (buttonIndex == 1 && self.originalImage))
        {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (IBAction)deleteImageFromRipple:(id)sender
{
    self.originalImage = nil;
    [self.rippleImage setImage:nil];
    [self.rippleImage setHidden:YES];
    [self.deleteImageButton setHidden:YES];
    [self.rippleImageButton setHidden:NO];
}

#pragma mark - Textview related functions
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    // change characterCount color if need be
    //change color of counter if low
    if ([self.characterCount.text intValue] <= 10)
        self.characterCount.textColor = [UIColor redColor];
    else
        self.characterCount.textColor = [UIColor darkGrayColor];
    
    
    if ([textView.text isEqualToString:defaultString])
        self.characterCount.text = @"200";
    
    else if ([textView.text isEqualToString:@""] && ![text isEqualToString:@""])
        self.characterCount.text = @"199";
    
    else if ([text isEqualToString:@""] && ![self.characterCount.text isEqualToString:@"200"])
    {
        self.characterCount.text = [NSString stringWithFormat:@"%u", 200 - self.rippleTextView.text.length + 1];
        return TRUE;
    }

    else if ([text isEqualToString:@""] && [self.characterCount.text isEqualToString:@"200"])
        return FALSE;
    
    else if ([self.characterCount.text isEqualToString:@"0"])
        return FALSE;
    
    else
        self.characterCount.text = [NSString stringWithFormat:@"%u",(int) 200 - self.rippleTextView.text.length - 1];
    
    return TRUE;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self adjustTextViewHeightWithHeightConstraint:self.rippleButton.frame.origin.y];
}

- (void) adjustTextViewHeightWithHeightConstraint:(float)heightConstraint
{
    if ([self.rippleTextView.text isEqualToString:defaultString])
        self.textViewHeightConstraint.constant = 99;
    
    else if (self.rippleTextView.contentSize.height + self.rippleTextView.frame.origin.y <= heightConstraint + 5)
    {
        CGRect textFrame = self.rippleTextView.frame;
        textFrame.size.height = self.rippleTextView.contentSize.height + 10;
        self.textViewHeightConstraint.constant = textFrame.size.height + 10;
        [self.rippleTextView setScrollEnabled:NO];
    }
    
    else if (self.isEditing == NO && self.rippleTextView.contentSize.height + self.rippleTextView.frame.origin.y >= heightConstraint)
    {
        self.textViewHeightConstraint.constant = heightConstraint - self.rippleTextView.frame.origin.y - 5;
        [self.rippleTextView setShowsVerticalScrollIndicator:YES];
    }

    [self.view updateConstraints];
    [self.rippleTextView setScrollEnabled:YES];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    // set sizing options
    [self adjustTextViewHeightWithHeightConstraint:self.rippleButton.frame.origin.y];
    
    self.isEditing = YES;
    // self.rippleTextView.backgroundColor = [[UIColor alloc] initWithWhite:0.0 alpha:0.5];
    //call selector to dismiss keyboard code if it is present
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchEventOnView:)];
    [tapRecognizer setNumberOfTapsRequired:1];
    [tapRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapRecognizer];
    
    // get rid of text
    if ([self.rippleTextView.text isEqualToString:defaultString])
        self.rippleTextView.text = @"";
    self.rippleTextView.textColor = [UIColor blackColor];
    
    
}

- (void)touchEventOnView: (id) sender
{
    [self endEditing];

    // remove gesture
    UITapGestureRecognizer *gestureRecognizer = sender;
    [self.view removeGestureRecognizer:gestureRecognizer];
    
}


- (IBAction)doneEditingPressed:(id)sender {
    [self endEditing];
}

- (void)endEditing
{
    if (self.isEditing )
    {
        self.isEditing = NO;
        
        [self.view endEditing:YES];
        
        // if text is "", set to default
        if ([self.rippleTextView.text isEqualToString:@""] || [self.rippleTextView.text isEqualToString:@" "] ||[self.rippleTextView.text isEqualToString:@"\n"])
        {
            self.rippleTextView.text = defaultString;
            self.rippleTextView.textColor = [UIColor darkGrayColor];
        }
        
        [self adjustTextViewHeightWithHeightConstraint:self.rippleImageButton.frame.origin.y];
    }
}

- (void)keyboardFrameDidChange:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    CGRect kKeyBoardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // if there is now a keyboard
    if (!self.keyboardOrNah)
    {
        [self.characterCount setHidden:NO];
        [self.doneEditingButton setHidden:NO];
        //[self.ImageShown setHidden:YES];
        
        // move up textview for more space
        [UIView animateWithDuration:0.4 animations:^{
            //[self.dismissButton setHidden:YES];
            // move up textview for more space
            self.rippleTextView.frame = CGRectMake(0,22, self.rippleTextView.frame.size.width, self.rippleTextView.frame.size.height);
            
            // stone and stone label reset
            self.rippleButton.frame = CGRectMake(self.rippleButton.frame.origin.x, self.view.frame.size.height - kKeyBoardFrame.origin.y - 2 - self.rippleButton.frame.size.height, self.rippleButton.frame.size.width, self.rippleButton.frame.size.height);
            self.pebbleBottomConstraint.constant = self.view.frame.size.height - kKeyBoardFrame.origin.y + 10;
        }];
        
        [self.view updateConstraints];
        [self.view layoutIfNeeded];
    }
    
    else
    {
        [self.characterCount setHidden:YES];
        [self.doneEditingButton setHidden:YES];
        
        [UIView animateWithDuration:0.4 animations:^{
            self.pebbleBottomConstraint.constant = self.originalbottomConstraintStoneButton;
        } completion:^(BOOL finished) {
            // NOOP
        }];
        
        [self.view layoutIfNeeded];
    }
    
    self.keyboardOrNah = !self.keyboardOrNah;
}

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect
{
    return 00.0;
}

#pragma mark - press social media buttons
- (IBAction)didPressTwitter:(id)sender
{
    if (!self.postToTwitterOrNah)
    {
        if (![PFTwitterUtils isLinkedWithUser:[PFUser currentUser]])
        {
            self.activityIndicator.hidden = NO;
            [self.activityIndicator startAnimating];
            [PFTwitterUtils linkUser:[PFUser currentUser] block:^(BOOL succeeded, NSError *error) {
                self.activityIndicator.hidden = YES;
                [self.activityIndicator stopAnimating];
                if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]])
                {
                    
                    NSLog(@"Woohoo, user logged in with Twitter!");
                    self.postToTwitterOrNah = YES;
                    [self.twitterButton setAlpha:1.0];
                }
            }];
        }
        
        else
        {
            self.postToTwitterOrNah = YES;
            [self.twitterButton setAlpha:1.0];
        }
    }
    
    else
    {
        self.postToTwitterOrNah = NO;
        [self.twitterButton setAlpha:0.4];
    }
}


- (IBAction)didPressFacebook:(id)sender {
    if(!self.postToFacebookOrNah)
    {
        self.postToFacebookOrNah = YES;
        [self.facebookButton setAlpha:1.0];
    }
    
    else
    {
        self.postToFacebookOrNah = NO;
        [self.facebookButton setAlpha:0.4];
    }
}


- (IBAction)didPressInstagram:(id)sender {
    if(!self.postToInstagramOrNah)
    {
        self.postToInstagramOrNah = YES;
        [self.instagramButton setAlpha:1.0];
    }
    
    else
    {
        self.postToInstagramOrNah = NO;
        [self.instagramButton setAlpha:0.4];
    }
}


/*
 - (void) postFbMessage
{
    if (!self.postToFbOrNah)
    {
        self.postToFbOrNah = YES;
        
        if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
        {
            //sign up with facebook!
            [PFFacebookUtils linkUser:[PFUser currentUser] permissions:@[@"publish_actions"] block:^(BOOL succeeded, NSError *error) {
                if(succeeded)
                {
                    NSLog(@"woohoo, loggedin w/ fb");
                    [self redisplayTable];
                }
                else
                    NSLog(@"%@", error);
            }];
        }
        
        [self redisplayTable];
    }
    
    else
    {
        self.postToFbOrNah = NO;
        [self redisplayTable];
    }
}
*/

- (void)sendTweet
{
    if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]])
    {
        
        NSString *fullTweetText = [NSString stringWithFormat:@"%@ - Shared on Bellow @rippleMeThis", self.rippleTextView.text];
        
        if ([fullTweetText length] >= 140 || (self.originalImage && [fullTweetText length] >= 117 ))
        {
            SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweetSheet setInitialText:fullTweetText];
            
            if (self.originalImage)
            {
                [tweetSheet addImage:self.originalImage];
            }
            
            [self presentViewController:tweetSheet animated:YES completion:nil];
            
            tweetSheet.completionHandler = ^(SLComposeViewControllerResult result)
            {
                BOOL cancelledOrNah = NO;
                switch(result)
                {
                        //  This means the user cancelled without sending the Tweet
                    case SLComposeViewControllerResultCancelled:
                        cancelledOrNah = YES;
                        break;
                        //  This means the user hit 'Send'
                    case SLComposeViewControllerResultDone:
                        break;
                }
                
                if (!cancelledOrNah)
                {
                    [self rippleAnimation];
                }
            };
        }
        
        else
        {
            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [TwitterService sendTweet:fullTweetText withImage:self.originalImage];
            });
            [self rippleAnimation];
        }
        
        // log tweet
        [PFAnalytics trackEvent:@"SentRippleToTwitter" dimensions:nil];
        [Flurry logEvent:@"Ripple_Tweeted"];
    }
}

/*
- (void)sendFbMessage
{
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
    {
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [FacebookService postMessage:self.rippleTextView.text withImage:self.originalImage];
        });
    }
}
*/
- (IBAction)dismissModalView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
