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
}
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet FBLoginView *fbLoginView;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation LoginViewController

#pragma mark - Init

-(instancetype)init
{
    self = [super init];
    
    UIEdgeInsets padding = UIEdgeInsetsMake(10, 10, 10, 10);
    
    [_usernameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo([self view].mas_top).with.offset(padding.top);
        make.left.equalTo([self view].mas_left).with.offset(padding.left);
        make.right.equalTo([self view].mas_right).with.offset(-padding.right);
        make.height.equalTo(@30);
    }];
    
    [_passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_usernameTextField.mas_bottom).with.offset(padding.top);
        make.left.equalTo([self view].mas_left).with.offset(padding.left);
        make.right.equalTo([self view].mas_right).with.offset(-padding.right);
        make.height.equalTo(@30);
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
        _usernameTextField.text = username;
    }
    
    self.fbLoginView.readPermissions = @[@"email"];
    
    if([[SharedData sharedData].splashView isDescendantOfView:self.navigationController.view])
    {
        [[SharedData sharedData].splashView removeFromSuperview];
    }
}

#pragma mark - Requests

- (void)sendRequest
{
    //send the actual request asyncronously
    [[[SharedData sharedData] sessionManager] POST:@"handler.php" parameters:postDictionary success:^(NSURLSessionDataTask *task, id responseObject) {
        if([responseObject[@"status"] isEqualToString:@"success"])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_activityIndicator stopAnimating];
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
                [_activityIndicator stopAnimating];
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
            [_activityIndicator stopAnimating];
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
    if(_usernameTextField.text.length != 0 || _passwordTextField.text.length != 0)
    {
        [self toggleControl:NO];
        
        [_activityIndicator startAnimating];
        
        //SANITIZE INPUTS
        NSMutableString* username = [SharedData sanitizeNSString:_usernameTextField.text];
        NSMutableString* password = [SharedData sanitizeNSString:_passwordTextField.text];
        
        postDictionary = @{@"action":action, @"username":username, @"password":password};
        [self sendRequest];
    }
}



- (IBAction)login:(id)sender
{
    [self handleRequest:@"login"];
}

-(IBAction)reg:(id)sender
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
    if(_usernameTextField.text != nil)
    {
        [_passwordTextField becomeFirstResponder];
    }
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
    //NSLog([error description]);
}

#pragma mark - Misc

- (void)toggleControl:(BOOL) action
{
    _usernameTextField.enabled = action;
    _passwordTextField.enabled = action;
    _loginButton.enabled = action;
    //_registerButton.enabled = action;
}

@end
