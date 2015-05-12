//
//  InputTableViewCell.m
//  MeNext
//
//  Created by Jim Boulter on 5/12/15.
//  Copyright (c) 2015 Jim Boulter. All rights reserved.
//

#import "InputTableViewCell.h"
#import "Masonry.h"

@implementation InputTableViewCell
@synthesize inputTextField;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        inputTextField = [[UITextField alloc] init];
        [self.contentView addSubview:inputTextField];
        
        UIEdgeInsets padding = UIEdgeInsetsMake(10, 10, 10, 10);
        [inputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView).with.insets(padding);
        }];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

