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
@property UIButton* bugReportButton;
@property UIButton* logoutButton;
@end

@implementation SettingsViewController
@synthesize bugReportButton, logoutButton;

#pragma mark - Init

-(instancetype)init
{
    if(self = [super init])
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
    NSString* email = [[NSString stringWithFormat:
                        @"mailto:jboulter11@gmail.com?subject=MeNext iOS Bug&body=Please provide details about the bug.\n----------------------------------------\n\n----------------------------------------\nWhat can I do to make it happen for me too?\n----------------------------------------\n\n----------------------------------------\n"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

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
