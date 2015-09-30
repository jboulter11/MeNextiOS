//
//  DetailTableViewCell.m
//  MeNext
//
//  Created by Jim Boulter on 6/26/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import "DetailTableViewCell.h"
#import "SharedData.h"

@interface DetailTableViewCell ()
@property (nonatomic) NSDictionary* track;
@end

@implementation DetailTableViewCell
@synthesize imageView;
@synthesize titleTextView;
@synthesize ratingLabel;
@synthesize upVoteButton;
@synthesize downVoteButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        imageView = [[UIImageView alloc] init];
        imageView.layer.cornerRadius = 5;
        imageView.clipsToBounds = YES;
        [imageView setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:imageView];
        
        upVoteButton = [[UIButton alloc] init];
        [upVoteButton setImage:[UIImage imageNamed:@"UpArrow"] forState:UIControlStateNormal];
        [self.contentView addSubview:upVoteButton];
        
        ratingLabel = [[UILabel alloc] init];
        [ratingLabel setFont:[UIFont systemFontOfSize:12]];
        [ratingLabel setTextColor:[UIColor meNextRedColor]];
        [self.contentView addSubview:ratingLabel];
        
        downVoteButton = [[UIButton alloc] init];
        [downVoteButton setImage:[UIImage imageNamed:@"DownArrow"] forState:UIControlStateNormal];
        [self.contentView addSubview:downVoteButton];
        
        titleTextView = [[UITextView alloc] init];
        [titleTextView setFont:[UIFont systemFontOfSize:12]];
        [titleTextView setEditable:NO];
        [self.contentView addSubview:titleTextView];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).with.offset(10);
            //make.top.equalTo(self.contentView.mas_top);
            //make.bottom.equalTo(self.contentView.mas_bottom);
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.width.equalTo(@120);
            make.height.equalTo(@67.5);
        }];
        
        [upVoteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right).with.offset(-10);
            make.top.equalTo(self.contentView.mas_top).with.offset(10);
            make.height.equalTo(@24);
            make.width.equalTo(@45);
        }];
        
        [ratingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(upVoteButton.mas_centerX);
            make.centerY.equalTo(self.contentView.mas_centerY);
        }];
        
        [downVoteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right).with.offset(-10);
            make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-10);
            make.height.equalTo(@24);
            make.width.equalTo(@45);
        }];
        
        [titleTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView.mas_right).with.offset(5);
            make.right.equalTo(upVoteButton.mas_left).with.offset(-5);
            make.top.equalTo(self.contentView.mas_top);
            make.bottom.equalTo(self.contentView.mas_bottom);
        }];
    }
    return self;
}

-(void)configureForIndexPath:(NSIndexPath*)indexPath withTrack:(NSDictionary*)track
{
    self.track = track;
    
    NSString* songTitle = track[@"title"];
    self.titleTextView.text = songTitle.kv_decodeHTMLCharacterEntities;
    
    [self.ratingLabel setText:track[@"rating"]];
    
    //Make string to get thumbnail
    NSMutableString* thumbnailURL = [NSMutableString stringWithString:@"https://i.ytimg.com/vi/"];
    [thumbnailURL appendString:track[@"youtubeId"]];
    [thumbnailURL appendString:@"/mqdefault.jpg"];
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:thumbnailURL]];
    
    NSString* rating = track[@"userRating"];
    if(!(rating == (id)[NSNull null] || rating.length == 0))
    {
        if([rating isEqualToString:@"1"])
        {
            [self.upVoteButton setImage:[UIImage imageNamed:@"UpArrowColor"] forState:UIControlStateNormal];
            [self.downVoteButton setImage:[UIImage imageNamed:@"DownArrow"] forState:UIControlStateNormal];
        }
        else if([rating isEqualToString:@"-1"])
        {
            [self.upVoteButton setImage:[UIImage imageNamed:@"UpArrow"] forState:UIControlStateNormal];
            [self.downVoteButton setImage:[UIImage imageNamed:@"DownArrowColor"] forState:UIControlStateNormal];
        }
        else
        {
            [self.upVoteButton setImage:[UIImage imageNamed:@"UpArrow"] forState:UIControlStateNormal];
            [self.downVoteButton setImage:[UIImage imageNamed:@"DownArrow"] forState:UIControlStateNormal];
        }
    }
}

@end
