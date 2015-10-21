//
//  SharedData.h
//  MeNext
//
//  Created by Jim Boulter on 7/15/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <FBSDKCoreKit.h>
#import <FBSDKLoginKit.h>
#import "AFHTTPSessionManager.h"
#import "AppDelegate.h"
#import <Masonry.h>
#import "RLMLoginCredential.h"
#import "UIColor+MeNext.h"

@interface SharedData : NSObject
@property (readonly) NSString* KEY;

+(NSMutableString *) sanitizeNSString:(NSString *)string;

+(SharedData*) sharedData;
+(AFHTTPSessionManager*) sessionManager;
+(AFHTTPSessionManager*) youtubeSessionManager;
+(FBSDKLoginManager*) fbLoginManager;


+(AppDelegate*) appDel;
+(NSString*)youtubeKey;
+(void) loginCheck:(id)responseObject withCompletion:(void(^)(void))block;
+(NSString*)getLaunchImageName;

@end
