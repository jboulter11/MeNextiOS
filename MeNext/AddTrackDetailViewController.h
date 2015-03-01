//
//  AddTrackDetailViewController.h
//  MeNext
//
//  Created by Jim Boulter on 7/11/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddTrackDetailViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel* titleLabel;
@property (strong, nonatomic) IBOutlet UITextView* descTextView;
@property (strong, nonatomic) IBOutlet UIImageView* previewImageView;
@property (strong, nonatomic) NSDictionary* track;
@property (strong, nonatomic) NSString* partyId;
@property (strong, nonatomic) NSString* youtubeId;

@end
