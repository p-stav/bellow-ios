//
//  ImageViewerViewController.h
//  Ripple
//
//  Created by Paul Stavropoulos on 12/28/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewerViewController : UIViewController<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) id rippleImageFile;
@property (nonatomic) float imageHeight;
@property (nonatomic) float imageWidth;

@end
