//
//  DetailTableViewCell.m
//  MeNext
//
//  Created by Jim Boulter on 6/26/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import "AddTrackTableViewCell.h"
#import "SharedData.h"

@interface AddTrackTableViewCell ()
@property (nonatomic) NSDictionary* track;
@end

@implementation AddTrackTableViewCell
@synthesize imageView;
@synthesize titleTextView;
@synthesize addTrackButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        imageView = [[UIImageView alloc] init];
        imageView.layer.cornerRadius = 5;
        imageView.clipsToBounds = YES;
        [imageView setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:imageView];
        
        addTrackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:addTrackButton];
        
        titleTextView = [[UITextView alloc] init];
        [titleTextView setFont:[UIFont systemFontOfSize:12]];
        [titleTextView setEditable:NO];
        [self.contentView addSubview:titleTextView];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).with.offset(10);
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.width.equalTo(@120);
            make.height.equalTo(@67.5);
        }];
        
        [addTrackButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right).with.offset(-10);
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.height.equalTo(@22);
            make.width.equalTo(@32);
        }];
        
        [titleTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView.mas_right).with.offset(5);
            make.right.equalTo(addTrackButton.mas_left).with.offset(-5);
            make.top.equalTo(self.contentView.mas_top);
            make.bottom.equalTo(self.contentView.mas_bottom);
        }];
    }
    return self;
}

-(void)configureForIndexPath:(NSIndexPath*)indexPath withButtonImageNamed:(NSString*)name
{
    
}
@end
