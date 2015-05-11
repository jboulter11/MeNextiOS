//
//  AddTrackTableViewCell.h
//  MeNext
//
//  Created by Jim Boulter on 7/11/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddTrackTableViewCell : UITableViewCell
@property (nonatomic) UIImageView* imageView;
@property (nonatomic, readonly) NSDictionary *track;
@property UITextView* titleTextView;
@property UIButton* addTrackButton;

@end