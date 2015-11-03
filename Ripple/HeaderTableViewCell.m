//
//  HeaderTableViewCell.m
//  Bellow
//
//  Created by Paul Stavropoulos on 4/23/15.
//  Copyright (c) 2015 Kefi Labs. All rights reserved.
//

#import "HeaderTableViewCell.h"

@implementation HeaderTableViewCell

- (void)awakeFromNib
{
    // add shadow to filterview
    self.filterView.layer.shadowOffset = CGSizeMake(0, 0);
    self.filterView.layer.shadowRadius = 2;
    self.filterView.layer.shadowOpacity = 0.15;
    self.filterView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.filterView.bounds].CGPath;
    
    // setup sortView
    [self setupSortView];
    
    // bools and values
    self.isChoosingSort = NO;
}


- (void)setupSortView
{
    // setup color of sortbackgroundofbutton and uiview to cover table
    self.sortView = [[UIView alloc] initWithFrame:CGRectMake(0, self.filterView.frame.size.height, [UIScreen mainScreen].bounds.size.width, 170)];
    [self.sortView setAlpha:0.0];
    self.sortView.backgroundColor = [UIColor whiteColor];
    [self.sortView setUserInteractionEnabled:YES];
    
    // add buttons and Labels
    UIButton *sortRecent = [UIButton buttonWithType:UIButtonTypeCustom];
    [sortRecent.titleLabel setFont:[UIFont fontWithName:@"Avenir" size:15]];
    [sortRecent setTitle:@"most recent" forState:UIControlStateNormal];
    [sortRecent setTitleColor:[UIColor colorWithRed:3.0/255.0f green:123.0f/255 blue:255.0f/255 alpha:1.0] forState:UIControlStateNormal];
    [sortRecent setFrame:CGRectMake(10, 30, self.sortView.frame.size.width - 20, 40)];
    [sortRecent addTarget:self action:@selector(firstSortOption) forControlEvents:UIControlEventTouchUpInside];
    [sortRecent setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [sortRecent setUserInteractionEnabled:YES];
    
    UIButton *sortPopular = [UIButton buttonWithType:UIButtonTypeCustom];
    [sortPopular.titleLabel setFont:[UIFont fontWithName:@"Avenir" size:15]];
    [sortPopular setTitle:@"most spread" forState:UIControlStateNormal];
    [sortPopular setTintColor:[UIColor blackColor]];
    [sortPopular setFrame:CGRectMake(10,105, self.sortView.frame.size.width - 20, 40)];
    [sortPopular addTarget:self action:@selector(secondSortOption) forControlEvents:UIControlEventTouchUpInside];
    [sortPopular setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [sortPopular setUserInteractionEnabled:YES];
    [sortPopular setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    // add lines
    //UIImageView *lineTop = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, self.sortView.frame.size.width - 20, 10)];
    //lineTop.image = [UIImage imageNamed:@"line.png"];
    UIImageView *lineSeparate = [[UIImageView alloc] initWithFrame:CGRectMake(10, 80, self.sortView.frame.size.width - 20, 10)];
    lineSeparate.image = [UIImage imageNamed:@"line.png"];
    //UIImageView *lineBottom = [[UIImageView alloc] initWithFrame:CGRectMake(10, 155, self.sortView.frame.size.width - 20, 10)];
    //lineBottom.image = [UIImage imageNamed:@"line.png"];
    //[self.sortView addSubview:lineTop];
    [self.sortView addSubview:lineSeparate];
    //[self.sortView addSubview:lineBottom];
    
    
    // add sort images, and style first iamge
    /*UIImageView *firstSortImage = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 16)/6 - 15, 15, 30, 30)];
     firstSortImage.image = [ImageCropping imageWithImage:[UIImage imageNamed:@"grayBox.png"] scaledToSize:CGSizeMake(30, 30) withColor:[UIColor colorWithRed:43.0/255.0f green:132.0f/255 blue:219.0f/255 alpha:1.0]];
     UIImageView *secondSortImage = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 16)/6 - 15, 60, 30, 30)];
     secondSortImage.image = [UIImage imageNamed:@"grayBox"];
     
     [self.sortView addSubview:firstSortImage];
     [self.sortView addSubview:secondSortImage];
     self.sortImages = [[NSMutableArray alloc] initWithObjects:firstSortImage, secondSortImage, nil];
     
     */
    
    // sort underlay
    self.sortUnderlay = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height + self.frame.origin.y + self.sortView.frame.size.height, [UIScreen mainScreen].bounds.size.width, 800)];
    [self.sortUnderlay setAlpha:0.0];
    [self.sortUnderlay setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
    [self.sortUnderlay setHidden:YES];
    
    // dimiss gesture
    self.dismissSort = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSortView)];
    [self.dismissSort setNumberOfTapsRequired:1];
    [self.dismissSort setDelegate:self];
    
    // add items to view and array
    [self.sortView addSubview:sortRecent];
    [self.sortView addSubview:sortPopular];
    self.sortButtons = [[NSArray alloc] initWithObjects:sortRecent, sortPopular,nil];
    [self addSubview:self.sortView];
    [self addSubview:self.sortUnderlay];
}


- (void) firstSortOption
{
    // dismiss view
    [self dismissSortView];
    
    if (self.sortMethod != 0)
    {
        self.sortMethod = 0;
        
        // chan gecolor of uibutton and apply sort
        [self changeColorOfSortOptions:self.sortMethod];
        [self.delegate passSortMethod:self.sortMethod passFilterMethod:self.filterMethod];
    }
}

- (void) secondSortOption
{
    // dismiss view
    [self dismissSortView];

    if (self.sortMethod != 1)
    {
        self.sortMethod = 1;
        
        // changecolor of uibutton and apply sort
        [self changeColorOfSortOptions:self.sortMethod];
        [self.delegate passSortMethod:self.sortMethod passFilterMethod:self.filterMethod];
    }
}

- (IBAction)filterByStarted
{
    if (self.filterMethod != 0)
    {

        self.filterMethod = 0;
        [self.delegate passSortMethod:self.sortMethod passFilterMethod:self.filterMethod];
    }
}

- (IBAction)filterBySpread
{
    if (self.filterMethod != 1)
    {
        self.filterMethod = 1;
        [self.delegate passSortMethod:self.sortMethod passFilterMethod:self.filterMethod];
    }
}

- (void) changeColorOfFilterMethods: (int)filterMethod
{
    
    
    self.filterMethod = filterMethod;
    if (filterMethod == 0)
    {
        [self.filterSpread setTitleColor:[UIColor colorWithWhite:0.0 alpha:0.5] forState:UIControlStateNormal];
        [self.filterStarted setTitleColor:[UIColor colorWithWhite:0.0 alpha:1.0] forState:UIControlStateNormal];
        
        [self.leftMineCarat setHidden:NO];
        [self.rightSpreadCarat setHidden:YES];
    }
    
    else
    {
        [self.filterStarted setTitleColor:[UIColor colorWithWhite:0.0 alpha:0.5] forState:UIControlStateNormal];
        [self.filterSpread setTitleColor:[UIColor colorWithWhite:0.0 alpha:1.0] forState:UIControlStateNormal];
        
        [self.leftMineCarat setHidden:YES];
        [self.rightSpreadCarat setHidden:NO];
    }
}

- (void)changeColorOfSortOptions: (int)sortMethod
{
    self.sortMethod = sortMethod;
    for (int i=0; i<[self.sortButtons count]; i++)
    {
        UIButton *button = self.sortButtons[i];
        if (i == sortMethod)
        {
            // change color of button
            [button setTitleColor:[UIColor colorWithRed:3.0/255.0f green:123.0f/255 blue:255.0f/255 alpha:1.0] forState:UIControlStateNormal];
            
            // change color of image
            /*
             UIImageView *sortImageView = self.sortImages[i];
             sortImageView.image = [ImageCropping imageWithImage:sortImageView.image scaledToSize:CGSizeMake(30, 30) withColor:[UIColor colorWithRed:43.0/255.0f green:132.0f/255 blue:219.0f/255 alpha:1.0]];
             self.sortImages[i] = sortImageView;
             */
            
            // style sort button
            [self.sortButton setTitle:button.titleLabel.text forState:UIControlStateNormal];
            
        }
        
        else
        {
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            /*
             UIImageView *sortImageView = self.sortImages[i];
             sortImageView.image = [ImageCropping imageWithImage:sortImageView.image scaledToSize:CGSizeMake(30, 30) withColor:[UIColor blackColor]];
             self.sortImages[i] = sortImageView;
             */
        }
    }
 
    
}


- (IBAction)caratPressedSort:(id)sender
{
    [self pressedSort:sender];
}

- (IBAction)pressedSort:(id)sender
{
    if (self.isChoosingSort)
    {
        self.isChoosingSort = NO;
        [self dismissSortView];
    }
    
    else
    {

        // bool, and underlay
        self.isChoosingSort = YES;
        [self.sortUnderlay setHidden:NO];
        
        // show actionsheet
        UIAlertView *pickSort = [[UIAlertView alloc] initWithTitle:@"sort by:" message:nil delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"most recent", @"most spread", nil];
    
        [pickSort show];
        

        /*
        [self.sortView setHidden:NO];
        [UIView animateWithDuration:0.3 animations:^{
            self.sortView.frame = CGRectMake(0,self.filterView.frame.size.height + self.filterView.frame.origin.y, [UIScreen mainScreen].bounds.size.width, 170);
            [self.sortView setAlpha:1.0];
            
            [self.sortUnderlay setFrame:CGRectMake(0,self.sortView.frame.origin.y + self.sortView.frame.size.height, self.frame.size.width, 800)];

            [self.sortUnderlay setAlpha:1.0];
            [self.sortUnderlay addGestureRecognizer:self.dismissSort];
         
        }];*/
        
        [self.delegate showTableUnderlay];
    }
}

- (void)dismissSortView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.sortView.frame = CGRectMake(0,self.filterView.frame.origin.y, [UIScreen mainScreen].bounds.size.width, 110);
        [self.sortView setHidden:YES];
        
        [self.sortView setAlpha:0.0];
        [self.sortUnderlay setHidden:YES];
        [self.sortUnderlay setAlpha:0.0];
        [self.sortUnderlay removeGestureRecognizer:self.dismissSort];
    }];

    [self.delegate dismissTableUnderlay];
    self.isChoosingSort = NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            NSLog(@"Cancel");
            break;
        case 1:
            [self firstSortOption];
            break;
        case 2:
            [self secondSortOption];
        default:
            break;
            // terms of service, feedback, privacy policy,
    }
}

@end
