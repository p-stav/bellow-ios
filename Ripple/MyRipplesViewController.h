//
//  MyRipplesViewController.h
//  Ripple
//
//  Created by Gal Oshri on 9/23/14.
//  Copyright (c) 2014 Kefi Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface MyRipplesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

-(IBAction)showActionSheet:(id)sender;

@end
