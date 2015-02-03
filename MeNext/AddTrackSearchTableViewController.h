//
//  AddTrackSearchTableViewController.h
//  MeNext
//
//  Created by Jim Boulter on 7/11/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedData.h"

@interface AddTrackSearchTableViewController : UITableViewController <UISearchBarDelegate>

@property (strong, nonatomic) SharedData* sharedData;
@property (strong, nonatomic) NSString* partyId;

@end
