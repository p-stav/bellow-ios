//
//  CommentedOut.m
//  Ripple
//
//  Created by Paul Stavropoulos on 2/7/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import "CommentedOut.h"

@implementation CommentedOut

/************ADDTUTORIALRIPPLES
 - (void)addTutorialRipples
 {
 // Ripple 1: Click on a ripple to see map and comments
 Ripple *rippleClick = [[Ripple alloc] init];
 rippleClick.rippleId = @"FakeRippleTap";
 rippleClick.text = @"Tap to see where this ripple has spread. Then navigate back and spread it to finish the tutorial.";
 rippleClick.imageFile = nil;
 rippleClick.imageHeight = 0;
 rippleClick.imageWidth = 0;
 rippleClick.creatorName = @"Ripple Tutorial";
 rippleClick.miniRippleId = @"FakeMiniRipple";
 rippleClick.commentArray = [@[] mutableCopy];
 rippleClick.commentIds = [@[] mutableCopy];
 rippleClick.createdAt = [NSDate date];
 rippleClick.numberPropagated = 4;
 rippleClick.numberComments = 1;
 rippleClick.latitude = 47.62062738016795;
 rippleClick.longitude = -122.3304829644317;
 rippleClick.rippleExposure = 0;
 
 // Ripple 2: Swipe right to propagate
 Ripple *ripplePropagate = [[Ripple alloc] init];
 ripplePropagate.rippleId = @"FakeRipple";
 ripplePropagate.text = @"This is a ripple. Swipe right to spread to people near you!";
 ripplePropagate.imageFile = nil;
 ripplePropagate.imageHeight = 0;
 ripplePropagate.imageWidth = 0;
 ripplePropagate.creatorName = @"Ripple Tutorial";
 ripplePropagate.miniRippleId = @"FakeMiniRipple";
 ripplePropagate.commentArray = [@[] mutableCopy];
 ripplePropagate.commentIds = [@[] mutableCopy];
 ripplePropagate.createdAt = [NSDate date];
 ripplePropagate.numberPropagated = 4;
 ripplePropagate.numberComments = 1;
 ripplePropagate.latitude = 47.62062738016795;
 ripplePropagate.longitude = -122.3304829644317;
 ripplePropagate.rippleExposure = 0;
 
 // Ripple 3: Swipe left to dismiss
 Ripple *rippleDismiss = [[Ripple alloc] init];
 rippleDismiss.rippleId = @"FakeRipple";
 rippleDismiss.text = @"Swipe left to dismiss this ripple.";
 rippleDismiss.imageFile = nil;
 rippleDismiss.imageHeight = 0;
 rippleDismiss.imageWidth = 0;
 rippleDismiss.creatorName = @"Ripple Tutorial";
 rippleDismiss.miniRippleId = @"FakeMiniRipple";
 rippleDismiss.commentArray = [@[] mutableCopy];
 rippleDismiss.commentIds = [@[] mutableCopy];
 rippleDismiss.createdAt = [NSDate date];
 rippleDismiss.numberPropagated = 4;
 rippleDismiss.numberComments = 1;
 rippleDismiss.latitude = 47.62062738016795;
 rippleDismiss.longitude = -122.3304829644317;
 rippleDismiss.rippleExposure = 0;
 
 [self.pendingRipples removeAllObjects];
 [self.pendingRipples addObject:ripplePropagate];
 [self.pendingRipples addObject:rippleDismiss];
 [self.pendingRipples addObject:rippleClick];
 
 [self.tableView reloadData];
 }
 */

/** was in goToMapView

 if ([ripple.rippleId isEqualToString:@"FakeRippleTap"])
 {
 [self ripplePropagated:ripple];
 }
*/

/**was in rippleDeleted and ripplePropagated
 if ([ripple.rippleId isEqualToString:@"FakeRipple"] || [ripple.rippleId isEqualToString:@"FakeRippleTap"])
 {
     if ([self.pendingRipples count] == 0)
     {
     self.isFirstRun = NO;
     self.isFirstRunPostInteractiveTutorial = YES;
     [self updateView];
     [self showStartRipplingAlert];
     }
     
     [self.tableView reloadData];
     return;
 }
}
*/




/************THIRD SORT OPTION
 
 - (void) thirdSortOption: (id)sender
 {
 if (self.sortMethod != 2)
 {
 self.sortMethod = 2;
 
 // changecolor of uibutton and apply sort
 [self changeColorOfSortOptions:self.sortMethod];
 [self passSortMethod:self.sortMethod passFilterMethod:self.filterMethod];
 }
 }

 UIImageView *thirdSortImage = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 16)/6 - 15, 105, 30, 30)];
 thirdSortImage.image = [UIImage imageNamed:@"grayBox.png"];
 
*/



/**************LEVELCELLL FOR PROFILE PAGE
 LevelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"levelCell" forIndexPath:indexPath];
 
 RippleLevel *level = [self.userLevels objectAtIndex:[indexPath row]];
 cell.levelLabel.text = level.name;
 cell.levelNumber.text = [NSString stringWithFormat:@"Level %d", [indexPath row]+1 ];
 cell.reachLabel.text = [NSString stringWithFormat:@"%dx reach",level.reach];
 cell.pointsLabel.text = [NSString stringWithFormat:@"%d points", level.minScore];
 
 // size label
 UILabel *foo = [[UILabel alloc] init];
 foo.frame =CGRectMake(0, 0, 10.0, 30.0);
 [foo setFont:[UIFont systemFontOfSize:26.0]];
 foo.text = level.name;
 [foo sizeToFit];
 CGSize rippleLevelTextCellSize = foo.frame.size;
 
 cell.levelLabelWidthConstraint.constant = rippleLevelTextCellSize.width;
 [cell.contentView setNeedsUpdateConstraints];
 [cell.contentView layoutIfNeeded];
 [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
 
 if (level.minScore < [[PFUser currentUser][@"score"] intValue])
 {
 cell.backgroundColor = [UIColor whiteColor];
 cell.levelLabel.textColor = [UIColor grayColor];
 cell.reachLabel.textColor = [UIColor grayColor];
 cell.pointsLabel.textColor = [UIColor grayColor];
 cell.levelNumber.textColor = [UIColor grayColor];
 cell.levelNumber.textColor = [UIColor grayColor];
 }
 else
 {
 cell.backgroundColor = [UIColor whiteColor];
 cell.levelLabel.textColor = [UIColor blackColor];
 cell.reachLabel.textColor = [UIColor grayColor];
 cell.pointsLabel.textColor = [UIColor grayColor];
 cell.levelNumber.textColor = [UIColor blackColor];
 }
 
 if ([level.name isEqualToString:[PFUser currentUser][@"reachLevel"]])
 {
 if ([[NSProcessInfo processInfo] respondsToSelector:@selector(isOperatingSystemAtLeastVersion:)])
 cell.backgroundColor = [UIColor colorWithRed:43.0/255.0f green:132.0f/255 blue:219.0f/255 alpha:0.7];
 else
 cell.backgroundColor = [UIColor colorWithRed:43.0/255.0f green:132.0f/255 blue:219.0f/255 alpha:0.6];
 
 cell.levelLabel.textColor = [UIColor whiteColor];
 cell.reachLabel.textColor = [UIColor whiteColor];
 cell.pointsLabel.textColor = [UIColor whiteColor];
 cell.levelNumber.textColor = [UIColor whiteColor];
 }
 */



/**********WE DON'T HAVE FAKERIPPLES GO TO MAP VIEW ANYMORE

 // this is a tutorial ripple. We add stuff
 else
 {
 NSMutableArray *array = [[NSMutableArray alloc] init];
 // add some mini ripples here
 for (int j = 0; j<self.ripple.numberPropagated; j++) {
 MiniRipple *miniRipple = [[MiniRipple alloc] init];
 miniRipple.miniRippleId = @"FakeMiniRipple";
 miniRipple.rippleId = self.ripple.rippleId;
 miniRipple.lastUpdated = [NSDate date];
 
 // make it random sir!
 double randomVal1 = ((double)arc4random() / ARC4RANDOM_MAX) - 0.5;
 double randomVal2 = ((double)arc4random() / ARC4RANDOM_MAX) - 0.5;
 miniRipple.latitude = self.ripple.latitude + randomVal1 / 222 + j*0.01;
 double milesInLongitudeDegree = 69.11 * cos(self.ripple.longitude);
 double longitudeJiggle = randomVal2 / (milesInLongitudeDegree * 1.6 * 2);
 
 miniRipple.longitude = self.ripple.longitude + longitudeJiggle + j*0.01;
 [array addObject:miniRipple];
 }
 self.miniRipples = (NSArray *)array;
 [self addMiniRipplePins];
 
 // add comments here
 Comment *firstComment = [[Comment alloc] init];
 firstComment.createdAt = [NSDate date];
 firstComment.creatorUsername = @"Ripple Tutorial";
 firstComment.commentId = @"FakeComment";
 firstComment.commentText = @"The green circle shows where the ripple started. Each blue circle is a person who has spread this ripple.";
 
 Comment *secondComment= [[Comment alloc] init];
 secondComment.createdAt = [NSDate date];
 secondComment.creatorUsername = @"Ripple Tutorial";
 secondComment.commentId = @"FakeComment";
 secondComment.commentText = @"Go back and spread this Ripple";
 
 [self.commentArray addObject:firstComment];
 // [self.commentArray addObject:secondComment];
 [self grabComments];
 }
 *************/

/****** MYRIPPLE CELL FOR HOME PAGE****
- (MyRippleCell *)setMyRippleCell:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath
{
[tableView registerNib:[UINib nibWithNibName:@"MyRippleCell" bundle:nil] forCellReuseIdentifier:@"MyRippleCell"];
MyRippleCell *cell = (MyRippleCell *)[tableView dequeueReusableCellWithIdentifier:@"MyRippleCell" forIndexPath:indexPath];
cell.rippleMainView.layer.cornerRadius = 5.0;

Ripple *ripple = [self.selectedRippleArray objectAtIndex:[indexPath row]];

cell.selectionStyle = UITableViewCellSelectionStyleNone;
cell.ripple = nil;
cell.ripple = ripple;
cell.delegate = self;
cell.rippleTextView.text = [NSString stringWithString:ripple.text];
[cell.rippleTextView setFont:[UIFont fontWithName:@"Avenir" size:16.0]];
[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

// usernamelabel work
[cell.usernameLabel setTitle:cell.ripple.creatorName forState:UIControlStateNormal];
CGSize stringSize = [cell.ripple.creatorName sizeWithAttributes:[NSDictionary dictionaryWithObject:NSFontAttributeName forKey:[UIFont fontWithName:@"Avenir-Heavy" size:17]]];

cell.usernameLabelWidthConstraint.constant = stringSize.width + 3;

// set username and city
if (cell.ripple.city)
{
// set city label hidden
[cell.cityLabel setHidden:NO];
cell.cityLabel.text = cell.ripple.city;
}
else
[cell.cityLabel setHidden:YES];

// spread count
NSDictionary *boldAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Avenir-Heavy" size:13], NSFontAttributeName, nil];
NSAttributedString *rippledText;
if (cell.ripple.numberPropagated == 1)
rippledText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"spread %d time", cell.ripple.numberPropagated] attributes:boldAttributes];
else
rippledText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"spread %d times", cell.ripple.numberPropagated] attributes:boldAttributes];
[cell.numberPropagatedLabel setAttributedText:rippledText];


cell.numberOfCommentsLabel.text = [NSString stringWithFormat:@"%d", ripple.numberComments];

// set timestampLabel
NSTimeInterval timeInterval = [cell.ripple.createdAt timeIntervalSinceNow];
cell.timestamp.text = [NSString stringWithFormat:@"%@", [self.timeIntervalFormatter stringForTimeInterval:timeInterval]];


// set text top constraint if  have image
if (cell.ripple.imageFile)
{
// image work!
[cell.outerImageView setHidden:NO];
[cell.outerImageViewWidthConstraint setConstant:[UIScreen mainScreen].bounds.size.width - 28];
[cell.rippleImageView setHidden:NO];
cell.rippleImageView.image = [UIImage imageNamed:@"grayBox.png"];

cell.rippleImageView.file = (PFFile *)cell.ripple.imageFile;

// determine smaller side, set equal to larger side
CGFloat heightRatio = (float) cell.ripple.imageHeight / cell.ripple.imageWidth;
cell.rippleImageViewWidthConstraint.constant = cell.outerImageView.frame.size.width;

CGFloat cellImageHeight;
if (cell.outerImageViewWidthConstraint.constant*heightRatio <=350)
{
cell.outerImageViewHeightConstraint.constant = cell.outerImageViewWidthConstraint.constant*heightRatio;
cellImageHeight = cell.outerImageViewHeightConstraint.constant;
}

else
{
cell.outerImageViewHeightConstraint.constant = 350;
cellImageHeight = 350;
}


// load image + set position from top for image
cell.rippleImageViewHeightConstraint.constant = cell.outerImageView.frame.size.width*heightRatio;

[cell.rippleImageView loadInBackground];
cell.topTextViewConstraint.constant = 8 + cellImageHeight;

// place spreadCommentView on image
cell.spreadCommentViewTopConstraint.constant = cellImageHeight - 27;

// find textview height
CGSize maximumSize = CGSizeMake(self.tableView.frame.size.width- 35.0, 9999);

UIFont *myFont = [UIFont fontWithName:@"AvenirNext-Regular" size:16.0];
NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:myFont, NSFontAttributeName,nil];
NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];

CGRect textSize =  [cell.ripple.text boundingRectWithSize:maximumSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:context];

cell.textViewHeightConstraint.constant = textSize.size.height + 30;

// change color of spreadCommentView items
[cell.spreadCommentView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.85]];
[cell.numberPropagatedLabel setTextColor:[UIColor whiteColor]];
[cell.numberOfCommentsLabel setTextColor:[UIColor whiteColor]];
[cell.commentsImage setImage:[UIImage imageNamed:@"comments.png"]];

// remove borders
[cell.rippleTextView.layer setBorderWidth:0.0];
}

// we don't have an image
else
{
cell.rippleImageView.hidden = YES;
cell.rippleImageView.image = nil;
cell.topTextViewConstraint.constant = 8;


// find textview height
CGSize maximumSize = CGSizeMake(self.tableView.frame.size.width- 28.0, 9999);

UIFont *myFont = [UIFont fontWithName:@"AvenirNext-Regular" size:16.0];
NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:myFont, NSFontAttributeName,nil];
NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];

CGRect textSize =  [cell.ripple.text boundingRectWithSize:maximumSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:context];

cell.textViewHeightConstraint.constant = textSize.size.height + 65;


// place spreadCommentView there
cell.spreadCommentViewTopConstraint.constant = textSize.size.height + 41;

// add small border to this
[cell.rippleTextView.layer setBorderColor:[[UIColor colorWithWhite:0.9 alpha:1.0] CGColor]];
[cell.rippleTextView.layer setBorderWidth:1.0];
cell.rippleTextView.layer.cornerRadius = 5.0;

// change color of spreadCommentView items
[cell.spreadCommentView setBackgroundColor:[UIColor clearColor]];
[cell.numberPropagatedLabel setTextColor:[UIColor blackColor]];
[cell.numberOfCommentsLabel setTextColor:[UIColor blackColor]];
[cell.commentsImage setImage:[UIImage imageNamed:@"commentsBlack.png"]];

}

// update constraints
[cell setNeedsUpdateConstraints];
[cell layoutIfNeeded];

cell.accessoryType = UITableViewCellAccessoryNone;
cell.selectionStyle = UITableViewCellSelectionStyleNone;

// add shadow
cell.rippleMainView.layer.shadowOffset = CGSizeMake(0,0);
cell.rippleMainView.layer.shadowRadius = 2;
cell.rippleMainView.layer.shadowOpacity = 0.1;
cell.rippleMainView.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.rippleMainView.bounds].CGPath;


return cell;

}
*/

/********SHADOW COMMENTS PAGE
 // set shadow for innerTopTableViewHeader and moreInfoBottomView
 self.innerTopTableViewHeader.layer.shadowOffset = CGSizeMake(0,0);
 self.innerTopTableViewHeader.layer.shadowRadius = 11;
 self.innerTopTableViewHeader.layer.shadowOpacity = 1.0;
 self.innerTopTableViewHeader.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.innerTopTableViewHeader.bounds].CGPath;
 self.innerTopTableViewHeader.userInteractionEnabled = NO;
 
 self.moreInfoBottomView.layer.shadowOffset = CGSizeMake(0,0);
 self.moreInfoBottomView.layer.shadowRadius = 11;
 self.moreInfoBottomView.layer.shadowOpacity = 1.0;
 self.moreInfoBottomView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.moreInfoBottomView.bounds].CGPath;
 self.moreInfoBottomView.userInteractionEnabled = NO;

 
//////INNER SHADOW OF COMMENT CELL
 // inner inner cell view
 cell.innerInnerCellView.layer.shadowOffset = CGSizeMake(0,0);
 cell.innerInnerCellView.layer.shadowRadius = 11;
 cell.innerInnerCellView.layer.shadowOpacity = 1.0;
 cell.innerInnerCellView.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.innerInnerCellView.bounds].CGPath;
 cell.innerInnerCellView.userInteractionEnabled = NO;
 cell.selectionStyle = UITableViewCellSelectionStyleNone;
*/




/************ SHARE BLUE BACKGROUND THING****************
 if (!self.ripple.imageFile)
 {
 // create objects to share, including share image
 UIView *viewToShare = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 900, 500)];
 [viewToShare setBackgroundColor:[UIColor colorWithRed:43.0/255.0f green:132.0f/255 blue:219.0f/255 alpha:1.0]];
 
 UIImageView *rippleLogo = [[UIImageView alloc] initWithFrame:CGRectMake(5, 20, 80, 80)];
 [rippleLogo setImage:[UIImage imageNamed:@"propagateRipple.png"]];
 [viewToShare addSubview:rippleLogo];
 
 UILabel *foundOn = [[UILabel alloc] initWithFrame:CGRectMake(95, 8, 100, 30)];
 foundOn.text = @"found on";
 foundOn.textColor = [UIColor whiteColor];
 [foundOn setBackgroundColor:[UIColor clearColor]];
 [foundOn setFont:[UIFont fontWithName:@"Avenir" size:15.0]];
 [viewToShare addSubview:foundOn];
 
 UILabel *rippleWord = [[UILabel alloc] initWithFrame:CGRectMake(95, 27, 300, 80)];
 rippleWord.text = @"ripple";
 rippleWord.textColor = [UIColor whiteColor];
 [rippleWord setBackgroundColor:[UIColor clearColor]];
 [rippleWord setFont:[UIFont fontWithName:@"Avenir" size:70.0]];
 [viewToShare addSubview:rippleWord];
 
 UITextView *rippleText = [[UITextView alloc] initWithFrame:CGRectMake(25, 150, 850, 250)];
 rippleText.text = self.ripple.text;
 [rippleText setFont:[UIFont fontWithName:@"Avenir" size:35.0]];
 rippleText.textColor = [UIColor whiteColor];
 [rippleText setBackgroundColor:[UIColor clearColor]];
 [viewToShare addSubview:rippleText];
 
 UILabel *rippleSpread = [[UILabel alloc] initWithFrame:CGRectMake(25, 433, 300, 40)];
 
 if (self.ripple.numberPropagated == 1)
 rippleSpread.text = [NSString stringWithFormat:@"spread %d time", self.ripple.numberPropagated];
 else
 rippleSpread.text = [NSString stringWithFormat:@"spread %d times", self.ripple.numberPropagated];
 
 rippleSpread.textColor = [UIColor whiteColor];
 [rippleSpread setBackgroundColor:[UIColor clearColor]];
 [rippleSpread setFont:[UIFont systemFontOfSize:25.0]];
 [viewToShare addSubview:rippleSpread];
 
 UILabel *rippleStartedUsername = [[UILabel alloc] initWithFrame:CGRectMake(25, 463, 300, 30)];
 rippleStartedUsername.text = [NSString stringWithFormat:@"started by %@", self.ripple.creatorName];
 rippleStartedUsername.textColor = [UIColor colorWithRed:205/255.0f green:205.0f/255 blue:205.0f/255 alpha:1.0];
 [rippleStartedUsername setBackgroundColor:[UIColor clearColor]];
 [rippleStartedUsername setFont:[UIFont systemFontOfSize:15.0]];
 [viewToShare addSubview:rippleStartedUsername];
 
 UILabel *rippleURL = [[UILabel alloc] initWithFrame:CGRectMake(670, 433, 260, 40)];
 rippleURL.text = @"getkefi.com/ripple";
 rippleURL.textColor = [UIColor colorWithRed:205/255.0f green:205.0f/255 blue:205.0f/255 alpha:1.0];
 [rippleURL setBackgroundColor:[UIColor clearColor]];
 [rippleURL setFont:[UIFont systemFontOfSize:25.0]];
 [viewToShare addSubview:rippleURL];
 
 UILabel *rippleTwitterHandle = [[UILabel alloc] initWithFrame:CGRectMake(670, 463, 260, 30)];
 rippleTwitterHandle.text = @"@rippleMeThis";
 rippleTwitterHandle.textColor = [UIColor colorWithRed:205/255.0f green:205.0f/255 blue:205.0f/255 alpha:1.0];
 [rippleTwitterHandle setBackgroundColor:[UIColor clearColor]];
 [rippleTwitterHandle setFont:[UIFont systemFontOfSize:15.0]];
 [viewToShare addSubview:rippleTwitterHandle];
 
 
 // turn viewtoshare to an image
 UIGraphicsBeginImageContextWithOptions(viewToShare.bounds.size, viewToShare.opaque, 0.0);
 [viewToShare.layer renderInContext:UIGraphicsGetCurrentContext()];
 UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 NSData *imageData = UIImageJPEGRepresentation(viewImage, 1.0);
 
 // create object array to share
 UIImage *shareImage = [UIImage imageWithData:imageData];
 //NSString *messageBody = @"found this on ripple. ";
 
 NSArray *objectsToShare = @[shareImage];
 
 shareController = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
 }
*/
 
/* ***********ripple exposure******
 // set the propagatedView circles.
 for (int i = 0; i< [cell.leftSideRippleExposureCount count]; i++)
 {
 [cell.leftSideRippleExposureCount[i] setHidden:YES];
 [cell.rightSideRippleExposureCount[i] setHidden:YES];
 
 if (i < cell.ripple.rippleExposure)
 {
 [cell.leftSideRippleExposureCount[i] setHidden:NO];
 [cell.rightSideRippleExposureCount[i] setHidden:NO];
 }
 }
 
 */



/******************attributted string ***************************
 NSMutableAttributedString *reachDesc = [[NSMutableAttributedString alloc] initWithString:@"Your ripples spread to "];
 NSAttributedString *numString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d people", [self.currentUser[@"reach"] intValue]] attributes:attributes];
 NSAttributedString *nearby = [[NSAttributedString alloc] initWithString:@" nearby"];
 [reachDesc appendAttributedString:numString];
 [reachDesc appendAttributedString:nearby];
 self.reachExplanation.attributedText = reachDesc;
 */




/*****************************profile self.user ---> I think this code is unnecessary******************************
 if (self.user)
 {
 NSMutableAttributedString *largestRipple = [[NSMutableAttributedString alloc] initWithString:@"largest ripple: "];
 NSString *times;
 
 if ([self.currentUser[@"highestPropagated"] intValue] != 1)
 times = [NSString stringWithFormat:@"spread %d times", [self.currentUser[@"highestPropagated"] intValue]];
 else
 times = [NSString stringWithFormat:@"spread %d time", [self.currentUser[@"highestPropagated"] intValue]];
 NSAttributedString *largestNum= [[NSAttributedString alloc] initWithString:times attributes:attributes];
 [largestRipple appendAttributedString:largestNum];
 self.highestPropagatedLabel.attributedText = largestRipple;
 
 // reach stuff
 self.networkScoreLabel.text = [NSString stringWithFormat:@"%d", [self.currentUser[@"reach"] intValue]];
 
 NSMutableAttributedString *reachDesc = [[NSMutableAttributedString alloc] initWithString:@"Ripples spread to "];
 NSAttributedString *numString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d people", [self.currentUser[@"reach"] intValue]] attributes:attributes];
 NSAttributedString *nearby = [[NSAttributedString alloc] initWithString:@" nearby"];
 [reachDesc appendAttributedString:numString];
 [reachDesc appendAttributedString:nearby];
 self.reachExplanation.attributedText = reachDesc;
 
 
 // set table header height
 self.tableHeader.frame = CGRectMake(self.tableHeader.frame.origin.x, self.tableHeader.frame.origin.y, self.tableHeader.frame.size.width, 255);
 [self.tableView setTableHeaderView:self.tableHeader];
 
 [self.highestPropagatedLabel setHidden:NO];
 }
 */






@end
