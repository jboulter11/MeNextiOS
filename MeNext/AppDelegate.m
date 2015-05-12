//
//  AppDelegate.m
//  MeNext
//
//  Created by Jim Boulter on 6/8/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworkActivityIndicatorManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "MasterViewController.h"
#import "InitialViewController.h"
#import "SharedData.h"

@implementation AppDelegate
{
    UINavigationController* nav;
}

#pragma mark - Login

-(void)setLogin
{
    //take us to the app
    nav.navigationBarHidden = NO;
    
    [UIView transitionWithView:self.window.rootViewController.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [(UINavigationController*)self.window.rootViewController setViewControllers:@[[[MasterViewController alloc] init]]];}
                    completion:nil];
}

-(void)setLogout
{
    //TODO: get rid of navigation controller
    nav.navigationBarHidden = YES;
    
    //Kill the current Access Token
    [FBSDKAccessToken setCurrentAccessToken:nil];
    
    [UIView transitionWithView:self.window.rootViewController.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [(UINavigationController*)self.window.rootViewController setViewControllers:@[[[InitialViewController alloc] init]]];}
                    completion:nil];
    
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
    
    //Let AFNetworking deal with our networking activity indicator
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    //Status Bar Config
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:239/255.0 green:35/255.0 blue:53/255.0 alpha:1]];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    
    //Make Navigation Controller
    nav = [[UINavigationController alloc] init];
    
    //Create Splashview
    [SharedData sharedData].splashView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [SharedData sharedData].splashView.image = [UIImage imageNamed:[SharedData getLaunchImageName]];
    
    //Make Splash visible
    [nav.view addSubview:[SharedData sharedData].splashView];
    [nav.view bringSubviewToFront:[SharedData sharedData].splashView];
    
    
    //Set up window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = nav;
    
    BOOL didFBFinishLaunching = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                         didFinishLaunchingWithOptions:launchOptions];
    
    //TODO: Check if logged in with MeNext, not FB, use Realm?
    //if FB says we're logged in
    if([FBSDKAccessToken currentAccessToken])
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
    
    return didFBFinishLaunching;
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
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];;
}

@end
