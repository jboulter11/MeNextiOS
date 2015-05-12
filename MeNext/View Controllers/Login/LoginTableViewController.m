//
//  LoginViewController.m
//  MeNext
//
//  Created by Jim Boulter on 6/19/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import "LoginTableViewController.h"
#import "MasterViewController.h"
#import "AFNetworking.h"
#import "Masonry.h"
#import "AppDelegate.h"
#import "SharedData.h"
#import <FBSDKLoginKit.h>

@interface LoginTableViewController (){
    NSDictionary* postDictionary;
    
    UIActivityIndicatorView* activityIndicator;
}


@end

@implementation LoginTableViewController
@synthesize actionRegistration;

#pragma mark - Init

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    
    return self;
}

#pragma mark - View

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString* username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    //user needs to login
    //fill the usernameTextField with current data
    if(username)
    {
        usernameTextField.text = username;
    }
    
//    if(usernameTextField.text != nil)
//    {
//        [passwordTextField becomeFirstResponder];
//    }
//    else
//    {
//        [usernameTextField becomeFirstResponder];
//    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Requests

- (void)sendRequest
{
    //send the actual request asyncronously
    [[SharedData sessionManager] POST:@"handler.php" parameters:postDictionary success:^(NSURLSessionDataTask *task, id responseObject) {
        if([responseObject[@"status"] isEqualToString:@"success"])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [activityIndicator stopAnimating];
            });
            [[SharedData appDel] setLogin];
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

#pragma mark - Actions

- (void)loginButtonPressed:(id)sender
{
    [self handleRequest:@"login"];
}

-(void)registerButtonPressed:(id)sender
{
    [self handleRequest:@"register"];
}

#pragma mark - Misc

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
