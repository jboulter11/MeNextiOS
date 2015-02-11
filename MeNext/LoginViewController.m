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

@interface LoginViewController (){
    NSString* accessToken;
    NSString* userId;
    NSDictionary* postDictionary;
    UIImageView* splashView;
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Misc

-(NSString*)getLaunchImageName
{
    NSString* launchImageName;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if ([UIScreen mainScreen].bounds.size.height == 480) launchImageName = @"LaunchImage-700@2x.png"; // iPhone 4/4s, 3.5 inch screen
        if ([UIScreen mainScreen].bounds.size.height == 568) launchImageName = @"LaunchImage-700-568h@2x.png"; // iPhone 5/5s, 4.0 inch screen
        if ([UIScreen mainScreen].bounds.size.height == 667) launchImageName = @"LaunchImage-800-667h@2x.png"; // iPhone 6, 4.7 inch screen
        if ([UIScreen mainScreen].bounds.size.height == 736) launchImageName = @"LaunchImage-800-Portrait-736h@3x.png"; // iPhone 6+, 5.5 inch screen
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if ([UIScreen mainScreen].scale == 1) launchImageName = @"LaunchImage-700-Portrait~ipad.png"; // iPad 2
        if ([UIScreen mainScreen].scale == 2) launchImageName = @"LaunchImage-700-Portrait@2x~ipad.png"; // Retina iPads
    }
    return launchImageName;
}

- (void)toggleControl:(BOOL) action
{
    _usernameTextField.enabled = action;
    _passwordTextField.enabled = action;
    _loginButton.enabled = action;
    //_registerButton.enabled = action;
}

#pragma mark - Requests

- (void)sendRequest
{
    //send the actual request asyncronously
    AFHTTPSessionManager* manager = _sharedData.sessionManager;
    [manager POST:@"handler.php" parameters:postDictionary success:^(NSURLSessionDataTask *task, id responseObject) {
        if([responseObject[@"status"] isEqualToString:@"success"])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_activityIndicator stopAnimating];
                [self performSegueWithIdentifier:@"LoginSuccess" sender:self];
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
    [splashView removeFromSuperview];
    if(_usernameTextField.text != nil)
    {
        [_passwordTextField becomeFirstResponder];
    }
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
    //NSLog([error description]);
}

#pragma mark - View

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    splashView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    splashView.image = [UIImage imageNamed:[self getLaunchImageName]];
    
    [self.navigationController.view addSubview:splashView];
    [self.navigationController.view bringSubviewToFront:splashView];
    
    if(!_sharedData)
    {
        _sharedData = [[SharedData alloc] init];
    }
    _sharedData.splashView = splashView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:239/255.0 green:35/255.0 blue:53/255.0 alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    //Check the login status of the user
    
    NSString* username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    //user needs to login
    //fill the usernameTextField with current data
    if(username)
    {
        _usernameTextField.text = username;
    }
    
    self.fbLoginView.readPermissions = @[@"email"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    MasterViewController* dst = (MasterViewController*)[segue destinationViewController];
    dst.sharedData = self.sharedData;
}
@end
