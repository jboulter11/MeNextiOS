//
//  LoginViewController.m
//  MeNext
//
//  Created by Jim Boulter on 6/19/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import "LoginViewController.h"
#import "MasterViewController.h"
#import "AFNetworking.h"
#import "Masonry.h"
#import "AppDelegate.h"
#import "SharedData.h"

@interface LoginViewController (){
    NSString* accessToken;
    NSString* userId;
    NSDictionary* postDictionary;
    
    //UI
    UIButton *registerButton;
    UIButton *loginButton;
    UIButton* fbLoginButton;
    FBLoginView *fbLoginView;
    UITextField *passwordTextField;
    UITextField *usernameTextField;
    UIActivityIndicatorView *activityIndicator;
}


@end

@implementation LoginViewController

#pragma mark - Init

-(instancetype)init
{
    self = [super init];
    
    //add obeserver for
    
    //Navigation Bar
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MeNextLogo.png"]];
    
    //White Background
    [[self view] setBackgroundColor:[UIColor whiteColor]];
    
    //Username
    usernameTextField = [[UITextField alloc] init];
    usernameTextField.placeholder = @"username";
    [[self view] addSubview:usernameTextField];
    
    //Password
    passwordTextField = [[UITextField alloc] init];
    passwordTextField.placeholder = @"password";
    [[self view] addSubview:passwordTextField];
    
    //LoginButton
    loginButton = [[UIButton alloc] init];
    [loginButton setTitle:@"Log In" forState:UIControlStateNormal];
    [[loginButton titleLabel] setFont:[UIFont boldSystemFontOfSize:24]];
    [loginButton setBackgroundColor:[[SharedData sharedData] meNextRed]];
    [loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:loginButton];
    
    //FB Login View
    fbLoginView = [[FBLoginView alloc] initWithReadPermissions:@[@"email"]];
    [fbLoginView setDelegate:self];
    [[self view] addSubview:fbLoginView];
    
    //Custom Login With Facebook Button
    fbLoginButton = [[UIButton alloc] init];
    [fbLoginButton setTitle:@"Log in with Facebook" forState:UIControlStateNormal];
    [[fbLoginButton titleLabel] setFont:[UIFont boldSystemFontOfSize:24]];
    [fbLoginButton setBackgroundColor:[[SharedData sharedData] fbBlue]];
    [fbLoginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:fbLoginButton];
    
    //Register Button
    registerButton = [[UIButton alloc] init];
    [registerButton setTitle:@"Register" forState:UIControlStateNormal];
    [[registerButton titleLabel] setFont:[UIFont boldSystemFontOfSize:24]];
    [registerButton setBackgroundColor:[[SharedData sharedData] meNextPurple]];
    [loginButton addTarget:self action:@selector(reg:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:registerButton];
    
    //Constraints
    UIEdgeInsets padding = UIEdgeInsetsMake(10, 10, 10, 10);
    
    [usernameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo([self view].mas_top).with.offset(padding.top);
        make.left.equalTo([self view].mas_left).with.offset(padding.left);
        make.right.equalTo([self view].mas_right).with.offset(-padding.right);
        make.height.equalTo(@30);
    }];
    
    [passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(usernameTextField.mas_bottom).with.offset(padding.top);
        make.left.equalTo([self view].mas_left).with.offset(padding.left);
        make.right.equalTo([self view].mas_right).with.offset(-padding.right);
        make.height.equalTo(@30);
    }];
    
    [loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo([self view].mas_left);
        make.right.equalTo([self view].mas_right);
        make.bottom.equalTo(fbLoginButton.mas_top);
        make.height.equalTo(@55);
    }];
    
    [fbLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo([self view].mas_left);
        make.right.equalTo([self view].mas_right);
        make.bottom.equalTo(registerButton.mas_top);
        make.height.equalTo(@55);
    }];
    
    [registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo([self view].mas_left);
        make.right.equalTo([self view].mas_right);
        make.bottom.equalTo([self view].mas_bottom);
        make.height.equalTo(@55);
    }];
    
    return self;
}

#pragma mark - View

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Check the login status of the user
    NSString* username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    //user needs to login
    //fill the usernameTextField with current data
    if(username)
    {
        usernameTextField.text = username;
    }
    
    //Remove splash
    if([[SharedData sharedData].splashView isDescendantOfView:self.navigationController.view])
    {
        [[SharedData sharedData].splashView removeFromSuperview];
    }
    
    [self toggleControl:YES];
}

#pragma mark - Requests

- (void)sendRequest
{
    //send the actual request asyncronously
    [[[SharedData sharedData] sessionManager] POST:@"handler.php" parameters:postDictionary success:^(NSURLSessionDataTask *task, id responseObject) {
        if([responseObject[@"status"] isEqualToString:@"success"])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [activityIndicator stopAnimating];
                ;
            });
        }
        else
        {
            NSString* msg = @"Error logging in";
            if([responseObject[@"errors"][0] isEqualToString:@"bad username/password combination"])
            {
                msg = @"Wrong username or password";
            }
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error Logging In"
                                                            message:msg
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [activityIndicator stopAnimating];
                [self toggleControl:YES];
            });
            [alert show];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error Logging In"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [activityIndicator stopAnimating];
            [self toggleControl:YES];
        });
        [alert show];
    }];
}

- (void)handleRequest:(NSString*)action
{
    if(![action isEqual:@"login"] && ![action isEqual:@"register"])
    {
        //We're logging in with facebook, action string is our access token
        accessToken = action;
        action = @"fbLogin";
        [FBRequestConnection startForMeWithCompletionHandler:
         ^(FBRequestConnection *connection, id result, NSError *error)
         {
             if(!error)
             {
                 userId = (NSString*) result[@"id"];
                 postDictionary = @{@"action":action, @"accessToken":accessToken, @"userId":userId};
                 [self sendRequest];
                 return;
             }
         }];
    }
    
    //only proceed if we have credentials for login
    if(usernameTextField.text.length != 0 || passwordTextField.text.length != 0)
    {
        [self toggleControl:NO];
        
        [activityIndicator startAnimating];
        
        //SANITIZE INPUTS
        NSMutableString* username = [SharedData sanitizeNSString:usernameTextField.text];
        NSMutableString* password = [SharedData sanitizeNSString:passwordTextField.text];
        
        postDictionary = @{@"action":action, @"username":username, @"password":password};
        [self sendRequest];
    }
}

- (void)login:(id)sender
{
    [self handleRequest:@"login"];
}

-(void)reg:(id)sender
{
    [self handleRequest:@"register"];
}

#pragma mark - FB Delagate
//FB DELAGATE METHODS
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    [self handleRequest:[[[FBSession activeSession] accessTokenData] accessToken]];
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    [[[SharedData sharedData] splashView] removeFromSuperview];
    if(usernameTextField.text != nil)
    {
        [passwordTextField becomeFirstResponder];
    }
    else
    {
        [usernameTextField becomeFirstResponder];
    }
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
    //NSLog([error description]);
}

#pragma mark - Misc

- (void)toggleControl:(BOOL) action
{
    usernameTextField.enabled = action;
    passwordTextField.enabled = action;
    loginButton.enabled = action;
    registerButton.enabled = action;
}

@end
