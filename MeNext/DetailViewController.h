//
//  DetailViewController.h
//  MeNext
//
//  Created by Jim Boulter on 6/8/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedData.h"

@interface DetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISplitViewControllerDelegate, NSURLSessionDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UITableView* tableView;

@property (strong, nonatomic) SharedData* sharedData;

@end
