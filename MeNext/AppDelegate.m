//
//  AppDelegate.m
//  MeNext
//
//  Created by Jim Boulter on 6/8/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworkActivityIndicatorManager.h"
#import <FacebookSDK/FacebookSDK.h>
#import "MasterViewController.h"
#import "LoginViewController.h"
#import "SharedData.h"

@implementation AppDelegate
{
    BOOL didRelog;
}

#pragma mark - Login

-(void)setLogin
{
    //take us to the app
    //[(UINavigationController*)self.window.rootViewController setViewControllers:@[[[MasterViewController alloc] init]]];
    
    [UIView transitionWithView:self.window.rootViewController.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [(UINavigationController*)self.window.rootViewController setViewControllers:@[[[MasterViewController alloc] init]]];}
                    completion:nil];
}

-(void)setLogout
{
    //if FB knows we're logged in we can just tell MeNext our FB token again to re-login
    //MAYBE PUT THIS IN THE LOGIN CONTROLLER???
    
    //take us to login
    //[(UINavigationController*)self.window.rootViewController setViewControllers:@[[[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"Login"]]];
    
    [UIView transitionWithView:self.window.rootViewController.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [(UINavigationController*)self.window.rootViewController setViewControllers:@[[[LoginViewController alloc] init]]];}
                    completion:nil];
    
}

-(BOOL)relogWithFB
{
    //Private Class Variable because we have to set it in the block
    didRelog = false;
    if([[[FBSession activeSession] accessTokenData] accessToken] != nil)
    {
        [[[SharedData sharedData] sessionManager] POST:@"handler.php" parameters:@{@"action":@"fbLogin", @"accessToken":[[[FBSession activeSession] accessTokenData] accessToken], @"userId":[[[FBSession activeSession] accessTokenData] userID]} success:^(NSURLSessionDataTask *task, id responseObject) {
            if([responseObject[@"status"] isEqualToString:@"success"])
            {
                //if success
                didRelog = true;
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
                [alert show];
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error Logging In"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }];
    }
    return didRelog;
}

#pragma mark - AppDelegate Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
//        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
//        splitViewController.delegate = (id)navigationController.topViewController;
//    }
    
    //let the app know about these things / enable these things
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    [FBLoginView class];
    
    //Make Navigation Controller
    UINavigationController* nav = [[UINavigationController alloc] init];
    nav.navigationBar.barTintColor = [UIColor colorWithRed:239/255.0 green:35/255.0 blue:53/255.0 alpha:1];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.tintColor = [UIColor whiteColor];
    [nav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    nav.navigationBar.barStyle = UIBarStyleBlack;
    
    //Create Splashview
    [SharedData sharedData].splashView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [SharedData sharedData].splashView.image = [UIImage imageNamed:[SharedData getLaunchImageName]];
    
    //Make Splash visible
    [nav.view addSubview:[SharedData sharedData].splashView];
    [nav.view bringSubviewToFront:[SharedData sharedData].splashView];
    
    
    //Set up window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = nav;
    
    
    //if FB says we're logged in
    if([[[FBSession activeSession] accessTokenData] accessToken] != nil)
    {
        //take us to the app
        [self setLogin];
    }
    else
    {
        //take us to the login vc
        [self setLogout];
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}

@end
