//
//  LoginViewController.m
//  MeNext
//
//  Created by Jim Boulter on 6/19/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

-(NSMutableString *) sanitizeNSString:(NSString *)string;

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

-(NSMutableString *) sanitizeNSString:(NSString *)string {
    NSMutableString *sanitized = [[string stringByReplacingOccurrencesOfString:@"&" withString:@""] copy];
    sanitized = [[sanitized stringByReplacingOccurrencesOfString:@"=" withString:@""] copy];
    sanitized = [[sanitized stringByReplacingOccurrencesOfString:@"?" withString:@""] copy];
    
    return sanitized;
}

- (IBAction)login:(id)sender
{
    //TODO: httppost login with the MeNext API
    if(_usernameTextField.text != nil || _passwordTextField.text != nil)//if we have input, go, otherwise ignore
    {
        _usernameTextField.enabled = NO;
        _passwordTextField.enabled = NO;
        _loginButton.enabled = NO;
        _registerButton.enabled = NO;
        
        [_activityIndicator startAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        //SANITIZE INPUTS
        NSMutableString* username = [self sanitizeNSString:_usernameTextField.text];
        NSMutableString* password = [self sanitizeNSString:_passwordTextField.text];
        
        NSString* postString = [NSString stringWithFormat:@"action=login&username=%@&password=%@", username, password];
        
        //send the actual request asyncronously
        dispatch_queue_t queue = dispatch_get_global_queue(0,0);
        dispatch_async(queue, ^{
            NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];\
            NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig];
            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.vmutti.com/handler.php"]];
            request.HTTPMethod = @"POST";
            request.HTTPBody = [postString dataUsingEncoding:NSUTF8StringEncoding];
            NSURLSessionDataTask* dt = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
                if (httpResp.statusCode == 200)
                {
                    if(!error)
                    {
                        NSError* jsonError;
                        NSDictionary* loginResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments error:&jsonError];
                        //NSLog([loginResponse description]);
                        if(!jsonError && loginResponse)
                        {
                            if(![loginResponse[@"token"] isEqual:@"-1"])
                            {
                                [[NSUserDefaults standardUserDefaults] setObject:loginResponse[@"token"] forKey:@"sessionId"];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                    [_activityIndicator stopAnimating];
                                    [self performSegueWithIdentifier:@"LoginSuccess" sender:self];
                                });
                            }
                            else
                            {
                                NSLog(@"-1 TOKEN!");
                            }
                        }
                            else
                            {
                                //error!
                                //NSLog([jsonError description]);
                            }
                    }
                    else
                    {
                        //NSLog([error description]);
                    }
                }
                else
                {
                    //NSLog([response description]);
                }
            }];
            [dt resume];
        });
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Check the login status of the user
    //use the sessionId NSUserDefault.  If it exists, user should be logged in.
    NSString* sessionId = [[NSUserDefaults standardUserDefaults] stringForKey:@"sessionId"];
    if(sessionId)
    {
        //we're logged in, send the sessionId as the sender
        [self performSegueWithIdentifier:@"LoginSuccess" sender:self];
    }
    
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
}
@end
