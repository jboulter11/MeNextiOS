//
//  InitialViewController.m
//  MeNext
//
//  Created by Jim Boulter on 5/12/15.
//  Copyright (c) 2015 Jim Boulter. All rights reserved.
//

#import "InitialViewController.h"
#import "LoginViewController.h"
#import "SharedData.h"
#import "InputTableViewCell.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit.h>

@interface InitialViewController ()
{
    UIButton* fbLoginButton;
    UIButton* loginButton;
    UIButton* registerButton;
    UIImageView* backgroundImageView;
    UIImageView* logoImageView;
}

@end

@implementation InitialViewController

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        //[self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        
        //Make it so the next VC won't have a back button title
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationItem setBackBarButtonItem:backButtonItem];
        
        [[self view] setBackgroundColor:[UIColor whiteColor]];
        
        //Background ImageView
        backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Turntable"]];
        [backgroundImageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.view addSubview:backgroundImageView];
        
        //Logo ImageView
        logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Vertical"]];
        logoImageView.layer.cornerRadius = 6;
        [logoImageView setClipsToBounds:YES];
        [self.view addSubview:logoImageView];
        
        //Register Button
        registerButton = [[UIButton alloc] init];
        [registerButton setTitle:@"Sign up" forState:UIControlStateNormal];
        [registerButton setBackgroundColor:[UIColor meNextPurpleColor]];
        [registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [registerButton.layer setCornerRadius:6];
        
        [registerButton addTarget:self action:@selector(reg:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:registerButton];
        
        //Custom Login With Facebook Button
        fbLoginButton = [[UIButton alloc] init];
        [fbLoginButton setTitle:@"Log in with Facebook" forState:UIControlStateNormal];
        [fbLoginButton setBackgroundColor:[UIColor fbBlueColor]];
        [fbLoginButton.layer setCornerRadius:6];
        
        [fbLoginButton addTarget:self action:@selector(fbLogin:) forControlEvents:UIControlEventTouchUpInside];
        [[self view] addSubview:fbLoginButton];
        
        //Login With Email Button
        loginButton = [[UIButton alloc] init];
        [loginButton setTitle:@"Log in" forState:UIControlStateNormal];
        [loginButton setBackgroundColor:[UIColor meNextRedColor]];
        [loginButton.layer setCornerRadius:6];
        
        [loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
        [[self view] addSubview:loginButton];
        
        //MASONRY
        UIEdgeInsets padding = UIEdgeInsetsMake(10, 10, -10, -10);
        
        [backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo([self view]);
        }];
        
        [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo([self view].mas_centerX);
            make.centerY.equalTo([self view].mas_centerY).with.offset(-[self view].bounds.size.height/4);
            make.height.equalTo(@150);
            make.width.equalTo(@150);
        }];
        
        [registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo([self view].mas_left).with.offset(padding.left);
            make.right.equalTo([self view].mas_centerX).with.offset(padding.right/2);
            make.bottom.equalTo([self view].mas_bottom).with.offset(padding.bottom);
            make.height.equalTo(@55);
        }];
        
        [loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo([self view].mas_centerX).with.offset(padding.left/2);
            make.right.equalTo([self view].mas_right).with.offset(padding.right);
            make.bottom.equalTo([self view].mas_bottom).with.offset(padding.bottom);
            make.height.equalTo(@55);
        }];
        
        [fbLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo([self view].mas_left).with.offset(padding.left);
            make.right.equalTo([self view].mas_right).with.offset(padding.right);
            make.bottom.equalTo(loginButton.mas_top).with.offset(padding.bottom);
            make.height.equalTo(@55);
        }];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)fbLogin:(id)sender
{
    [[SharedData fbLoginManager] logInWithReadPermissions:@[@"email"]
                                       fromViewController:self
                                                 handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                                     if(!error && ![result isCancelled])
                                                     {
                                                         //We're logged in
                                                         [[SharedData appDel] setLogin];
                                                     }
                                                     else
                                                     {
                                                         UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Could not log into facebook"
                                                                                                                         message:[error localizedDescription]
                                                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                                                         
                                                         [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                                                         [self presentViewController:alert animated:YES completion:nil];
                                                     }
                                                 }];
}

- (void)pushWithRegistration:(BOOL)actionRegistration
{
    LoginViewController* vc = [[LoginViewController alloc] init];
    vc.actionRegistration = actionRegistration;
    
    //    [UIView transitionWithView:self.view
    //                      duration:0.3
    //                       options:UIViewAnimationOptionTransitionCrossDissolve
    //                    animations:^{[self.navigationController pushViewController:vc animated:NO];}
    //                    completion:nil];
    
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)login:(id)sender
{
    //Present loginvc with only two fields
    [self pushWithRegistration:NO];
}

- (void)reg:(id)sender
{
    //present loginvc with all necessary fields for registration
    [self pushWithRegistration:YES];
}

@end
