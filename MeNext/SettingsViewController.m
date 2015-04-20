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
        [[logoutButton titleLabel] setFont:[UIFont boldSystemFontOfSize:24]];
        [logoutButton setBackgroundColor:[[SharedData sharedData] meNextPurple]];
        [logoutButton addTarget:self action:@selector(logoutButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [[self view] addSubview:logoutButton];
        
        [logoutButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo([self view].mas_left);
            make.right.equalTo([self view].mas_right);
            make.bottom.equalTo([self view].mas_bottom);
            make.height.equalTo(@55);
        }];
    }
    return self;
}

#pragma mark - Actions

- (void)logoutButtonPressed:(id)sender
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sessionId"];
    //[FBSDKLoginManager closeAndClearTokenInformation];
    [[SharedData appDel] setLogout];
}

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //TODO: Add the ability to change the host address from vmutti.com to other servers (low priority)
}

@end
