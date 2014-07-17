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

-(SharedData*) init{
    sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.vmutti.com/"]];
    sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    sessionManager.responseSerializer.acceptableContentTypes = [sessionManager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    return self;
}

+(NSMutableString *) sanitizeNSString:(NSString *)string {
    NSMutableString *sanitized = [[string stringByReplacingOccurrencesOfString:@"&" withString:@""] copy];
    sanitized = [[sanitized stringByReplacingOccurrencesOfString:@"=" withString:@""] copy];
    sanitized = [[sanitized stringByReplacingOccurrencesOfString:@"?" withString:@""] copy];
    
    return sanitized;
}

@end
