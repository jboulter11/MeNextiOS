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
#import "Realm/Realm.h"

@interface LoginViewController () <UITextFieldDelegate>{
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
@property NSMutableArray* textFields;

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
@synthesize textFields;

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
        [passwordTextField becomeFirstResponder];
    }
    else
    {
        [usernameTextField becomeFirstResponder];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    textFields = [[NSMutableArray alloc] init];
    
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
    continueButton.backgroundColor = (actionRegistration ? [UIColor meNextPurpleColor] : [UIColor meNextRedColor]);
    continueButton.layer.cornerRadius = 6;
    continueButton.clipsToBounds = YES;
    [continueButton setTitle:(actionRegistration ? @"Sign up" : @"Log in") forState:UIControlStateNormal];
    [continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [continueButton addTarget:self
                       action:(actionRegistration ?
                               @selector(registerButtonPressed:) :
                               @selector(loginButtonPressed:))
             forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continueButton];
    
    //Username
    usernameTextField = [[UITextField alloc] init];
    usernameTextField.placeholder = @"Username";
    usernameTextField.delegate = self;
    usernameTextField.tag = 0;
    usernameTextField.returnKeyType = UIReturnKeyNext;
    [textFields addObject:usernameTextField];
    [baseView addSubview:usernameTextField];
    
    //Divider between username and password
    divider1 = [[UIView alloc] init];
    divider1.backgroundColor = [UIColor colorWithWhite:200/255.0 alpha:.5];
    [baseView addSubview:divider1];
    
    //Password
    passwordTextField = [[UITextField alloc] init];
    passwordTextField.secureTextEntry = YES;
    passwordTextField.placeholder = @"Password";
    passwordTextField.delegate = self;
    passwordTextField.tag = 1;
    passwordTextField.returnKeyType = (actionRegistration ? UIReturnKeyNext : UIReturnKeyDone);
    [textFields addObject:passwordTextField];
    [baseView addSubview:passwordTextField];
    
    if(actionRegistration)
    {
        //Divider between password and confirm
        divider2 = [[UIView alloc] init];
        divider2.backgroundColor = [UIColor colorWithWhite:200/255.0 alpha:.5];
        [baseView addSubview:divider2];
        
        //Confirm Password
        confirmTextField = [[UITextField alloc] init];
        confirmTextField.secureTextEntry = YES;
        confirmTextField.placeholder = @"Confirm";
        confirmTextField.delegate = self;
        confirmTextField.tag = 2;
        confirmTextField.returnKeyType = UIReturnKeyDone;
        [textFields addObject:confirmTextField];
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
            make.top.equalTo(divider2.mas_bottom);
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
    [[SharedData sessionManager] POST:@"handler.php" parameters:postDictionary progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if([responseObject[@"status"] isEqualToString:@"success"])
        {
            [activityIndicator stopAnimating];
            [[SharedData appDel] setLogin];
        }
        else
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error logging in"
                                                                           message:responseObject[@"status"]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [activityIndicator stopAnimating];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error logging in"
                                                                       message:[error localizedDescription]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [activityIndicator stopAnimating];
        [self presentViewController:alert animated:YES completion:nil];        
    }];
}

- (void)handleRequest:(NSString*)action
{
    //only proceed if we have credentials for login
    if(usernameTextField.text.length != 0 && passwordTextField.text.length != 0)
    {
        if(actionRegistration && ![confirmTextField.text isEqualToString:passwordTextField.text]){
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Password fields don't match"
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        [activityIndicator startAnimating];
        
        //SANITIZE INPUTS
        NSMutableString* username = [SharedData sanitizeNSString:usernameTextField.text];
        NSMutableString* password = [SharedData sanitizeNSString:passwordTextField.text];
        
        postDictionary = @{@"action":action, @"username":username, @"password":password};
        [self sendRequest];
    }
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    if (textFields.count > nextTag) {
        // Found next responder, so set it.
        [textFields[nextTag] becomeFirstResponder];
    } else {
        // Not found, so try to login/register.
        [self handleRequest:(actionRegistration ? @"register" : @"login")];
    }
    return NO; // We do not want UITextField to insert line-breaks.
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

@end
