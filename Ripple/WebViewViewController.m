//
//  WebViewViewController.m
//  Ripple
//
//  Created by Gal Oshri on 10/13/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import "WebViewViewController.h"

@interface WebViewViewController ()
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;

@property (strong, nonatomic) NSTimer *progressTimer;
@property BOOL isDoneLoadingOrNah;
@property BOOL didStartLoadingOrNah;

@end

@implementation WebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.delegate = self;
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:requestObj];
    
    
    self.view.backgroundColor = [UIColor colorWithRed:3.0/255.0f green:123.0f/255 blue:255.0f/255 alpha:1.0];
    
    self.navBar.title = [NSString stringWithFormat:@"%@",self.url];
    
    // set up progress bar
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.01667 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
    self.isDoneLoadingOrNah = NO;
    self.didStartLoadingOrNah = NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)doneWasPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


# pragma Mark - timer
-(void)timerCallback {
    if (self.isDoneLoadingOrNah)
    {
        if (self.progressBar.progress >= 1) {
            self.progressBar.hidden = true;
            [self.progressTimer invalidate];
        }
        
        else
            self.progressBar.progress += 0.01;
    }
    
    else
    {
        self.progressBar.progress += 0.005;
        if (self.progressBar.progress >= 0.90)
            self.progressBar.progress = 0.90;
        
    }
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    if (!self.didStartLoadingOrNah)
    {
        self.progressBar.progress = 0.0;
        self.didStartLoadingOrNah = YES;
    }
    
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.isDoneLoadingOrNah = YES;
}

@end
