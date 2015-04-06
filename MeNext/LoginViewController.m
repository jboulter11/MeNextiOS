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
#import <FBSDKLoginKit.h>

@interface LoginViewController (){
    NSDictionary* postDictionary;
    
    //UI
    UIButton* registerButton;
    UIButton* loginButton;
    UIButton* fbLoginButton;
    UITextField* passwordTextField;
    UITextField* usernameTextField;
    UITextField* confirmTextField;
    UIImageView* splash;
    UIActivityIndicatorView* activityIndicator;
    
    UIButton* buttonToAnimate;
}


@end

@implementation LoginViewController

#pragma mark - Init

-(instancetype)init
{
    self = [super init];
    
    //TODO:add obeserver for animating button up with keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    //Navigation Bar
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MeNextLogo.png"]];
    
    //White Background
    [[self view] setBackgroundColor:[UIColor whiteColor]];
    
    
    //Username
    usernameTextField = [[UITextField alloc] init];
    usernameTextField.placeholder = @"username";

    
    //Password
    passwordTextField = [[UITextField alloc] init];
    passwordTextField.placeholder = @"password";
    
    //Confirm
    confirmTextField = [[UITextField alloc] init];
    confirmTextField.placeholder = @"confirm";
    
    //LoginButton
    loginButton = [[UIButton alloc] init];
    [loginButton setTitle:@"Log In" forState:UIControlStateNormal];
    [[loginButton titleLabel] setFont:[UIFont boldSystemFontOfSize:24]];
    [loginButton setBackgroundColor:[[SharedData sharedData] meNextRed]];
    [loginButton addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:loginButton];
    
    //Custom Login With Facebook Button
    fbLoginButton = [[UIButton alloc] init];
    [fbLoginButton setTitle:@"Log in with Facebook" forState:UIControlStateNormal];
    [[fbLoginButton titleLabel] setFont:[UIFont boldSystemFontOfSize:24]];
    [fbLoginButton setBackgroundColor:[[SharedData sharedData] fbBlue]];
    [fbLoginButton addTarget:self action:@selector(fbLogin:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:fbLoginButton];
    
    //Register Button
    registerButton = [[UIButton alloc] init];
    [registerButton setTitle:@"Register" forState:UIControlStateNormal];
    [[registerButton titleLabel] setFont:[UIFont boldSystemFontOfSize:24]];
    [registerButton setBackgroundColor:[[SharedData sharedData] meNextPurple]];
    [registerButton addTarget:self action:@selector(registerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:registerButton];
    
    //Splash
    splash = [[SharedData sharedData] splashView];
    [self.view addSubview:splash];
    
    //Constraints
    
    [fbLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo([self view].mas_left);
        make.right.equalTo([self view].mas_right);
        make.bottom.equalTo(loginButton.mas_top);
        make.height.equalTo(@55);
    }];
    
    [loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
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
    
    [splash mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(loginButton.mas_top);
    }];
    
    [self.view bringSubviewToFront:splash];
    [self.view bringSubviewToFront:fbLoginButton];
    [self.view bringSubviewToFront:loginButton];
    [self.view bringSubviewToFront:registerButton];
    
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
    
    //Remove splash
    //[[SharedData sharedData].splashView removeFromSuperview];
    
    [self toggleControl:YES];
}

#pragma mark - User Input Views

-(void) showUserInputControls
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [splash removeFromSuperview];
    
    [[self view] addSubview:usernameTextField];
    [[self view] addSubview:passwordTextField];
    
    UIEdgeInsets padding = UIEdgeInsetsMake(10, 10, -10, -10);
    
    [usernameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo([self view].mas_top).with.offset(padding.top);
        make.left.equalTo([self view].mas_left).with.offset(padding.left);
        make.right.equalTo([self view].mas_right).with.offset(padding.right);
        make.height.equalTo(@30);
    }];

    [passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(usernameTextField.mas_bottom).with.offset(padding.top);
        make.left.equalTo([self view].mas_left).with.offset(padding.left);
        make.right.equalTo([self view].mas_right).with.offset(padding.right);
        make.height.equalTo(@30);
    }];

    if(buttonToAnimate == registerButton)
    {
        [[self view] addSubview:confirmTextField];
        [confirmTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(passwordTextField.mas_bottom).with.offset(padding.top);
            make.left.equalTo([self view].mas_left).with.offset(padding.left);
            make.right.equalTo([self view].mas_right).with.offset(padding.right);
            make.height.equalTo(@30);
        }];
    }
    
    [usernameTextField becomeFirstResponder];
}

-(void) hideUserInputControl
{
    [usernameTextField removeFromSuperview];
    [passwordTextField removeFromSuperview];
    [confirmTextField removeFromSuperview];
    
    [self.view addSubview:splash];
}

#pragma mark - Keyboard Animations

- (void)keyboardWillShow:(NSNotification*)notification
{
    [self moveControls:notification keyboardComingIn:YES];
}

- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    [self moveControls:notification keyboardComingIn:NO];
}

-(void) moveControls:(NSNotification*)notification keyboardComingIn:(BOOL)keyboardComingIn
{
    NSDictionary* notificationInfo = [notification userInfo];
    CGRect keyboardFrame = [[notificationInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
    
    CGRect newButtonFrame = buttonToAnimate.frame;
    NSLog(@"%f", keyboardFrame.origin.y);
    newButtonFrame.origin.y = keyboardFrame.origin.y - buttonToAnimate.frame.size.height * ((!keyboardComingIn && buttonToAnimate==loginButton) ? 2 : 1);
    
    UIViewAnimationOptions options = [[notificationInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16;
    
    [UIView animateWithDuration:[[notificationInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0
                        options:options
                     animations:^{buttonToAnimate.frame = newButtonFrame;}
                     completion:nil];
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

- (void)fbLogin:(id)sender
{
    [[SharedData fbLoginManager] logInWithReadPermissions:@[@"email"]
                                     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                         NSLog(@"FACEBOOK RESULT:%@", [result description]);
                                         if(!error && ![result isCancelled])
                                         {
                                             postDictionary = @{@"action":@"fbLogin", @"accessToken":[result token], @"userId":[[FBSDKAccessToken currentAccessToken] userID]};
                                             [self sendRequest];
                                         }
                                         else
                                         {
                                             UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Could not login with Facebook"
                                                                                             message:@"Try again"
                                                                                            delegate:self
                                                                                   cancelButtonTitle:@"OK"
                                                                                   otherButtonTitles: nil];
                                             [alert show];
                                         }
                                     }];
}

- (void)loginButtonPressed:(id)sender
{
    buttonToAnimate = loginButton;
    [self showUserInputControls];
    [self handleRequest:@"login"];
}

-(void)registerButtonPressed:(id)sender
{
    buttonToAnimate = registerButton;
    [self showUserInputControls];
    [self handleRequest:@"register"];
}

#pragma mark - Misc

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)toggleControl:(BOOL) action
{
    usernameTextField.enabled = action;
    passwordTextField.enabled = action;
    loginButton.enabled = action;
    registerButton.enabled = action;
}

@end
