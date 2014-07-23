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

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)sendRequest:(NSString*)action
{
    //TODO: httppost login with the MeNext API
    if(_usernameTextField.text != nil || _passwordTextField.text != nil)//if we have input, go, otherwise ignore
    {
        _usernameTextField.enabled = NO;
        _passwordTextField.enabled = NO;
        _loginButton.enabled = NO;
        _registerButton.enabled = NO;
        
        [_activityIndicator startAnimating];
        
        //SANITIZE INPUTS
        NSMutableString* username = [SharedData sanitizeNSString:_usernameTextField.text];
        NSMutableString* password = [SharedData sanitizeNSString:_passwordTextField.text];
        
        NSDictionary* postDictionary = @{@"action":action, @"username":username, @"password":password};
        
        //send the actual request asyncronously
        AFHTTPSessionManager* manager = _sharedData.sessionManager;
        [manager POST:@"handler.php" parameters:postDictionary success:^(NSURLSessionDataTask *task, id responseObject) {
            [[NSUserDefaults standardUserDefaults] setObject:(NSDictionary*)responseObject[@"token"] forKey:@"sessionId"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_activityIndicator stopAnimating];
                [self performSegueWithIdentifier:@"LoginSuccess" sender:self];
            });
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error Logging In"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            dispatch_async(dispatch_get_main_queue(), ^{[_activityIndicator stopAnimating];});
            [alert show];
        }];
    }
}

- (IBAction)login:(id)sender
{
    [self sendRequest:@"login"];
}

-(IBAction)reg:(id)sender
{
    [self sendRequest:@"register"];
}

-(void)viewWillAppear:(BOOL)animated
{
    if(!_sharedData)
    {
        _sharedData = [[SharedData alloc] init];
    }
    //use the sessionId NSUserDefault.  If it exists, user should be logged in.
    if([[NSUserDefaults standardUserDefaults] stringForKey:@"sessionId"])
    {
        //we're logged in, send the sessionId as the sender
        [self performSegueWithIdentifier:@"LoginSuccess" sender:self];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Check the login status of the user
    
    NSString* username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString* password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    
    //Check if username and password login, else display login objects
    if(!username || !password)
    {
        //user needs to login
        //display login objects
        _usernameTextField.hidden = NO;
        _passwordTextField.hidden = NO;
        _loginButton.hidden = NO;
        _registerButton.hidden = NO;
        _usernameTextField.enabled = YES;
        _passwordTextField.enabled = YES;
        _loginButton.enabled = YES;
        _registerButton.enabled = YES;
        
        //fill the usernameTextField with current data
        if(username)
        {
            _usernameTextField.text = username;
        }
    }
    else
    {
        //make sure login stuff is hidden
        _usernameTextField.hidden = YES;
        _passwordTextField.hidden = YES;
        _loginButton.hidden = YES;
        _registerButton.hidden = YES;
        _usernameTextField.enabled = NO;
        _passwordTextField.enabled = NO;
        _loginButton.enabled = NO;
        _registerButton.enabled = NO;
    }
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
