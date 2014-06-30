//
//  DetailTableViewCell.h
//  MeNext
//
//  Created by Jim Boulter on 6/26/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *text;
@property (weak, nonatomic) IBOutlet UIImageView *image;

@end
