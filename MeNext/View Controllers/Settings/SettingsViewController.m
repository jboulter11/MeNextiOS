//
//  SettingsViewController.m
//  MeNext
//
//  Created by Jim Boulter on 6/12/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "SharedData.h"
#import "Realm.h"

@interface SettingsViewController ()
{
    UIButton* logoutButton;
}

@end

@implementation SettingsViewController

#pragma mark - Init

-(instancetype)init
{
    if(self = [super init])
    {
        [self.view setBackgroundColor:[UIColor whiteColor]];
        
        [self setTitle:@"Settings"];
        
        //Logout Button
        logoutButton = [[UIButton alloc] init];
        [logoutButton setTitle:@"Log out" forState:UIControlStateNormal];
        logoutButton.layer.cornerRadius = 6;
        logoutButton.clipsToBounds = YES;
        [logoutButton setBackgroundColor:[[SharedData sharedData] meNextPurple]];
        [logoutButton addTarget:self action:@selector(logoutButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [[self view] addSubview:logoutButton];
        
        [logoutButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo([self view].mas_left).with.offset(10);
            make.right.equalTo([self view].mas_right).with.offset(-10);
            make.bottom.equalTo([self view].mas_bottom).with.offset(-10);
            make.height.equalTo(@55);
        }];
    }
    return self;
}

#pragma mark - Actions

- (void)logoutButtonPressed:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Log out"
                                                    otherButtonTitles:nil];
    [actionSheet showInView:[self view]];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == actionSheet.destructiveButtonIndex)
    {
        [[SharedData appDel] setLogout];
    }
}

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //TODO: Add the ability to change the host address from vmutti.com to other servers (low priority)
}

@end
