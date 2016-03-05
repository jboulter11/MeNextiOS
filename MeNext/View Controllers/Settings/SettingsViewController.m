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
#import "Realm/Realm.h"

@interface SettingsViewController ()
@property UIButton* bugReportButton;
@property UIButton* logoutButton;
@end

@implementation SettingsViewController
@synthesize bugReportButton, logoutButton;

#pragma mark - Init

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        [self.view setBackgroundColor:[UIColor whiteColor]];
        
        [self setTitle:@"Settings"];
        
        //Bug reporting
        bugReportButton = [[UIButton alloc] init];
        [bugReportButton setTitle:@"Report a bug" forState:UIControlStateNormal];
        bugReportButton.layer.cornerRadius = 6;
        bugReportButton.clipsToBounds = YES;
        [bugReportButton setBackgroundColor:[UIColor meNextChicagoColor]];
        [bugReportButton addTarget:self action:@selector(bugReportButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [[self view] addSubview:bugReportButton];
        
        //Logout Button
        logoutButton = [[UIButton alloc] init];
        [logoutButton setTitle:@"Log out" forState:UIControlStateNormal];
        logoutButton.layer.cornerRadius = 6;
        logoutButton.clipsToBounds = YES;
        [logoutButton setBackgroundColor:[UIColor meNextPurpleColor]];
        [logoutButton addTarget:self action:@selector(logoutButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [[self view] addSubview:logoutButton];
        
        UIEdgeInsets padding = UIEdgeInsetsMake(10, 10, -10, -10);
        
        [bugReportButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).with.offset(padding.top);
            make.left.equalTo(self.view.mas_left).with.offset(padding.left);
            make.right.equalTo(self.view.mas_right).with.offset(padding.right);
            make.height.equalTo(@55);
        }];
        
        [logoutButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo([self view].mas_left).with.offset(padding.left);
            make.right.equalTo([self view].mas_right).with.offset(padding.right);
            make.bottom.equalTo([self view].mas_bottom).with.offset(padding.bottom);
            make.height.equalTo(@55);
        }];
    }
    return self;
}

#pragma mark - Actions

-(void)bugReportButtonPressed:(id)sender
{
    NSURL* url = [NSURL URLWithString:@"mailto:jboulter11@gmail.com?subject=MeNext%20iOS%20Bug&body=Please%20provide%20details%20about%20the%20bug.%0A----------------------------------------%0A%0A----------------------------------------%0AWhat%20can%20I%20do%20to%20make%20it%20happen%20for%20me%20too?%0A----------------------------------------%0A%0A----------------------------------------%0A"];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)logoutButtonPressed:(id)sender
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Are you sure?"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Log out" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[SharedData appDel] setLogout];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //TODO: Add the ability to change the host address from vmutti.com to other servers (low priority)
}

@end
