//
//  MasterViewController.h
//  MeNext
//
//  Created by Jim Boulter on 6/8/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedData.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, NSURLSessionDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) SharedData* sharedData;

@end
