//
//  ImageViewerViewController.m
//  Ripple
//
//  Created by Paul Stavropoulos on 12/28/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import "ImageViewerViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface ImageViewerViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;

@property (nonatomic, strong) PFImageView *imageView;
@property CGRect originalRect;
@property CGFloat originalZoomScale;
@end

@implementation ImageViewerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.delegate = self;
    
    CGSize imageSize = CGSizeMake(self.imageWidth, self.imageHeight);
    
    // set up image
    self.imageView = [[PFImageView alloc] init];
    self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=imageSize};
    [self.scrollView addSubview:self.imageView];
    self.scrollView.contentSize = imageSize;
    self.originalRect = self.imageView.frame;

    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.file = (PFFile *)self.rippleImageFile;
    [self.imageView loadInBackground];
    
    // set up gesture recognizers
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    doubleTapRecognizer.delaysTouchesBegan = YES;
    [self.scrollView addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [self.scrollView addGestureRecognizer:twoFingerTapRecognizer];
    
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewOneFingerTap:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.numberOfTouchesRequired = 1;
    singleTapRecognizer.delaysTouchesBegan = YES;
    [self.scrollView addGestureRecognizer:singleTapRecognizer];
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeUp)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeDown)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    
    // [self.view addGestureRecognizer:swipeUp];
    [self.view addGestureRecognizer:swipeDown];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // minimum zoom
    CGFloat scaleWidth =[UIScreen mainScreen].bounds.size.width / self.imageWidth;
    CGFloat scaleHeight = [UIScreen mainScreen].bounds.size.height / self.imageHeight;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    self.scrollView.minimumZoomScale = minScale;
    
    // maximum zoom
    self.scrollView.maximumZoomScale = 1.0f;
    self.scrollView.zoomScale = minScale;
    
    // center image
    [self centerScrollViewContents];
    self.originalZoomScale = self.scrollView.zoomScale;
    [self.exitButton setHidden:NO];
}

- (void) centerScrollViewContents
{
    CGSize boundsSize = [UIScreen mainScreen].bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height + 20) / 2.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

// you zoom in to that point
- (void)scrollViewDoubleTapped: (id)sender
{
    if (self.scrollView.zoomScale == self.originalZoomScale)
    {
        UITapGestureRecognizer *recognizer = sender;
        
        // get point in question where they double tapped
        CGPoint pointInView = [recognizer locationInView:self.imageView];
        
        // change zoome scale
        CGFloat newZoomScale = self.scrollView.zoomScale * 1.5f;
        newZoomScale = MIN(newZoomScale, self.scrollView.maximumZoomScale);
        
        // set up frame and zoom to it
        CGSize scrollViewSize = self.scrollView.bounds.size;
        CGFloat w = scrollViewSize.width / newZoomScale;
        CGFloat h = scrollViewSize.height / newZoomScale;
        CGFloat x = pointInView.x - (w / 2.0f);
        CGFloat y = pointInView.y - (h / 2.0f);
        CGRect rectToZoomTo = CGRectMake(x, y, w, h);
        [self.scrollView zoomToRect:rectToZoomTo animated:YES];
    }
}

// pinch zoom
- (void)scrollViewTwoFingerTapped: (id) sender
{
   
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.scrollView.zoomScale / 2.0f;
    newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale);
    [self.scrollView setZoomScale:newZoomScale animated:YES];
}

// zoom out all the way
- (void)scrollViewOneFingerTap: (id) sender
{
    // get original zoom
    if (self.scrollView.zoomScale != self.originalZoomScale)
        [self.scrollView zoomToRect:self.originalRect animated:YES];
    [self.exitButton setHidden:NO];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma Mark - uiscrollview methods
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    // Return the view that you want to zoom
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so you need to re-center the contents
    if (scrollView.zoomScale == self.originalZoomScale)
        [self.exitButton setHidden:NO];
    
    else
        [self.exitButton setHidden:YES];
    
     [self centerScrollViewContents];
}


- (IBAction)exitButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didSwipeUp
{
    if (self.scrollView.zoomScale == self.originalZoomScale)
        [self exitButtonPressed:self];
}

- (void)didSwipeDown
{
    if (self.scrollView.zoomScale == self.originalZoomScale)
        [self exitButtonPressed:self];
}

@end
