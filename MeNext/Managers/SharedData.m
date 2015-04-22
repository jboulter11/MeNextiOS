//
//  SharedData.m
//  MeNext
//
//  Created by Jim Boulter on 7/15/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import "SharedData.h"

@implementation SharedData
@synthesize KEY;
@synthesize splashView;
@synthesize meNextRed;
@synthesize meNextPurple;
@synthesize fbBlue;

#pragma mark - Singleton

+(SharedData*) sharedData {
    static SharedData* sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

+(AFHTTPSessionManager*) sessionManager {
    static AFHTTPSessionManager* sessionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://www.menext.me/"]];
        sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        sessionManager.responseSerializer.acceptableContentTypes = [sessionManager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    });
    return sessionManager;
}

+(AFHTTPSessionManager*) youtubeSessionManager {
    static AFHTTPSessionManager* youtubeSessionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        youtubeSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://i.ytimg.com/vi/"]];
        youtubeSessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        youtubeSessionManager.responseSerializer.acceptableContentTypes = [youtubeSessionManager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    });
    return youtubeSessionManager;
}

+(FBSDKLoginManager*) fbLoginManager {
    static FBSDKLoginManager* fbLoginManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fbLoginManager = [[FBSDKLoginManager alloc] init];
    });
    return fbLoginManager;
}

#pragma mark - AppDelagate

+(AppDelegate*)appDel
{
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

#pragma mark - Init

-(SharedData*) init
{
    if(self = [super init])
    {
        KEY = @"AIzaSyAbh1CseUDq0NKangT-QRIeyOoZLz6jCII";//MeNext Youtube iOS API Key
        splashView = nil;
        
        meNextRed = [UIColor colorWithRed:239/255.0 green:35/255.0 blue:53/255.0 alpha:1];
        meNextPurple = [UIColor colorWithRed:136/255.0 green:44/255.0 blue:215/255.0 alpha:1];
        fbBlue = [UIColor colorWithRed:59/255.0 green:89/255.0 blue:152/255.0 alpha:1];
    }
    
    return self;
}

#pragma mark - Shared Functions

+(NSMutableString *) sanitizeNSString:(NSString *)string
{
    NSMutableString *sanitized = [[string stringByReplacingOccurrencesOfString:@"&" withString:@""] copy];
    sanitized = [[sanitized stringByReplacingOccurrencesOfString:@"=" withString:@""] copy];
    sanitized = [[sanitized stringByReplacingOccurrencesOfString:@"?" withString:@""] copy];
    
    return sanitized;
}

+(void)loginCheck:(id)responseObject withCompletion:(void(^)(void))block;
{
    if([((NSArray*)[responseObject objectForKey:@"errors"])[0] isEqual: @"user must be logged in to perform this action"])
    {
        if([FBSDKAccessToken currentAccessToken] != nil)
        {
            [[SharedData sessionManager] POST:@"handler.php" parameters:@{@"action":@"fbLogin", @"accessToken":[[FBSDKAccessToken currentAccessToken] tokenString], @"userId":[[FBSDKAccessToken currentAccessToken] userID]} success:^(NSURLSessionDataTask *task, id responseObject) {
                if([responseObject[@"status"] isEqualToString:@"success"])
                {
                    if(block)
                    {
                        block();
                    }
                }
                else
                {
                    [[SharedData appDel] setLogout];
                }
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Oops, looks like you're logged out"
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                [[SharedData appDel] setLogout];
            }];
        }
    }
}

+(NSString*)getLaunchImageName
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

@end
