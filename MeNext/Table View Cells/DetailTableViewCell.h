//
//  DetailTableViewCell.h
//  MeNext
//
//  Created by Jim Boulter on 6/26/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "NSString+HTML.h"

@interface DetailTableViewCell : UITableViewCell

@property (nonatomic) UIImageView* imageView;
@property (nonatomic, readonly) NSDictionary *track;
@property UITextView* titleTextView;
@property UILabel* ratingLabel;
@property UIButton* upVoteButton;
@property UIButton* downVoteButton;

-(void)configureForIndexPath:(NSIndexPath*)indexPath withTrack:(NSMutableArray*)tracks;


@end
