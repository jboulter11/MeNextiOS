//
//  DetailViewController.h
//  MeNext
//
//  Created by Jim Boulter on 6/8/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UISplitViewControllerDelegate, NSURLSessionDelegate>

@property id party;

@end
