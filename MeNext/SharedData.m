//
//  SharedData.m
//  MeNext
//
//  Created by Jim Boulter on 7/15/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import "SharedData.h"

@implementation SharedData
@synthesize sessionManager;
@synthesize youtubeSessionManager;
@synthesize KEY;

-(SharedData*) init{
    sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.menext.me/"]];
    sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    sessionManager.responseSerializer.acceptableContentTypes = [sessionManager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    youtubeSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://www.googleapis.com/youtube/v3/"]];
    youtubeSessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    youtubeSessionManager.responseSerializer.acceptableContentTypes = [youtubeSessionManager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
     KEY = @"AIzaSyAbh1CseUDq0NKangT-QRIeyOoZLz6jCII";//MeNext Youtube iOS API Key
    
    return self;
}

+(NSMutableString *) sanitizeNSString:(NSString *)string {
    NSMutableString *sanitized = [[string stringByReplacingOccurrencesOfString:@"&" withString:@""] copy];
    sanitized = [[sanitized stringByReplacingOccurrencesOfString:@"=" withString:@""] copy];
    sanitized = [[sanitized stringByReplacingOccurrencesOfString:@"?" withString:@""] copy];
    
    return sanitized;
}

@end
