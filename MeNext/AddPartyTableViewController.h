//
//  AddPartyTableViewController.h
//  MeNext
//
//  Created by Jim Boulter on 10/13/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZBarSDK.h>
#import "SharedData.h"

@interface AddPartyTableViewController : UITableViewController <ZBarReaderDelegate>

@property (strong, nonatomic) SharedData* sharedData;

@end
