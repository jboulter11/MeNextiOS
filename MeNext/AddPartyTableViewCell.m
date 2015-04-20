//
//  AddPartyTableViewCell.m
//  MeNext
//
//  Created by Jim Boulter on 10/13/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import "AddPartyTableViewCell.h"
#import "SharedData.h"

@implementation AddPartyTableViewCell
@synthesize textField;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        textField = [[UITextField alloc] init];
        [textField setPlaceholder:@"ID"];
        [self.contentView addSubview:textField];
        
        [textField setReturnKeyType:UIReturnKeyJoin];
        
        [textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView).with.insets(UIEdgeInsetsMake(0, 10, 0, 10));
        }];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
