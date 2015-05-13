//
//  LoginTableViewController.m
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
    NSDictionary* postDictionary;
    
    UIActivityIndicatorView* activityIndicator;
}
@property UITextField* usernameTextField;
@property UITextField* passwordTextField;
@property UITextField* confirmTextField;
@property UIView* baseView;
@property UIView* divider1;
@property UIView* divider2;
@property UIButton* continueButton;
@property UIButton* xButton;
@property UIImageView* backgroundImageView;

@end

@implementation LoginViewController
@synthesize actionRegistration;
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize confirmTextField;
@synthesize baseView;
@synthesize divider1;
@synthesize divider2;
@synthesize continueButton;
@synthesize xButton;
@synthesize backgroundImageView;

#pragma mark - Init

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        
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
    
    if(usernameTextField.text != nil)
    {
        [passwordTextField becomeFirstResponder];
    }
    else
    {
        [usernameTextField becomeFirstResponder];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Background ImageView
    backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Turntable"]];
    [backgroundImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.view addSubview:backgroundImageView];
    
    //Back Button
    xButton = [[UIButton alloc] init];
    [xButton setImage:[UIImage imageNamed:@"X"] forState:UIControlStateNormal];
    [xButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:xButton];
    
    //View Containing TextFields
    baseView = [[UIView alloc] init];
    baseView.backgroundColor = [UIColor whiteColor];
    baseView.layer.cornerRadius = 6;
    baseView.clipsToBounds = YES;
    [self.view addSubview:baseView];
    
    //Button to Log in / Register
    continueButton = [[UIButton alloc] init];
    continueButton.backgroundColor = (actionRegistration ? [[SharedData sharedData] meNextPurple] : [[SharedData sharedData] meNextRed]);
    continueButton.layer.cornerRadius = 6;
    continueButton.clipsToBounds = YES;
    continueButton.titleLabel.text = (actionRegistration ? @"Sign up" : @"Log in");
    [self.view addSubview:continueButton];
    
    //Username
    usernameTextField = [[UITextField alloc] init];
    usernameTextField.placeholder = @"Username";
    [baseView addSubview:usernameTextField];
    
    //Divider between username and password
    divider1 = [[UIView alloc] init];
    divider1.backgroundColor = [UIColor lightGrayColor];
    [baseView addSubview:divider1];
    
    //Password
    passwordTextField = [[UITextField alloc] init];
    passwordTextField.placeholder = @"Password";
    [baseView addSubview:passwordTextField];
    
    if(actionRegistration)
    {
        //Divider between password and confirm
        divider2 = [[UIView alloc] init];
        divider2.backgroundColor = [UIColor lightGrayColor];
        [baseView addSubview:divider2];
        
        //Confirm Password
        confirmTextField = [[UITextField alloc] init];
        confirmTextField.placeholder = @"Password";
        [baseView addSubview:confirmTextField];
    }
    
    [backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo([self view]);
    }];
    
    [xButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(20);
        make.left.equalTo(self.view.mas_left);
        make.height.equalTo(@44);
        make.width.equalTo(@44);
    }];
    
    [baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view.mas_centerY).with.offset(-self.view.bounds.size.height/4);
        make.left.equalTo(self.view.mas_left).with.offset(40);
        make.right.equalTo(self.view.mas_right).with.offset(-40);
        make.height.equalTo((actionRegistration ? @167 : @112));
    }];
    
    [continueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).with.offset(40);
        make.right.equalTo(self.view.mas_right).with.offset(-40);
        make.top.equalTo(baseView.mas_bottom).with.offset(10);
        make.height.equalTo(@55);
    }];
    
    [usernameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(baseView.mas_top);
        make.left.equalTo(baseView.mas_left).with.offset(10);
        make.right.equalTo(baseView.mas_right).with.offset(-10);
        make.height.equalTo(@55);
    }];
    
    [divider1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(usernameTextField.mas_bottom);
        make.left.equalTo(usernameTextField.mas_left);
        make.right.equalTo(usernameTextField.mas_right);
        make.height.equalTo(@1);
    }];
    
    [passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(divider1.mas_bottom);
        make.left.equalTo(baseView.mas_left).with.offset(10);
        make.right.equalTo(baseView.mas_right).with.offset(-10);
        make.height.equalTo(@55);
    }];
    
    if(actionRegistration)
    {
        [divider2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(passwordTextField.mas_bottom);
            make.left.equalTo(passwordTextField.mas_left);
            make.right.equalTo(passwordTextField.mas_right);
            make.height.equalTo(@1);
        }];
        
        [confirmTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(divider1.mas_bottom);
            make.left.equalTo(baseView.mas_left).with.offset(10);
            make.right.equalTo(baseView.mas_right).with.offset(-10);
            make.height.equalTo(@55);
        }];
    }
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
        });
        [alert show];
    }];
}

- (void)handleRequest:(NSString*)action
{
    //only proceed if we have credentials for login
    if(usernameTextField.text.length != 0 || passwordTextField.text.length != 0)
    {
        [activityIndicator startAnimating];
        
        //SANITIZE INPUTS
        NSMutableString* username = [SharedData sanitizeNSString:usernameTextField.text];
        NSMutableString* password = [SharedData sanitizeNSString:passwordTextField.text];
        
        postDictionary = @{@"action":action, @"username":username, @"password":password};
        [self sendRequest];
    }
}

#pragma mark - Actions

-(void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

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
