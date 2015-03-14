//
//  SharedData.h
//  MeNext
//
//  Created by Jim Boulter on 7/15/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import "AppDelegate.h"

@interface SharedData : NSObject

@property AFHTTPSessionManager* sessionManager;
@property AFHTTPSessionManager* youtubeSessionManager;
@property (readonly) NSString* KEY;
@property UIImageView* splashView;
@property UIColor* meNextRed;
@property UIColor* meNextPurple;
@property UIColor* fbBlue;

+(NSMutableString *) sanitizeNSString:(NSString *)string;

+(SharedData*) sharedData;
-(SharedData*) init;
+(AppDelegate*) appDel;
+(void) loginCheck:(id)responseObject;
+(NSString*)getLaunchImageName;

@end
