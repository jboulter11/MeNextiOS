//
//  SharedData.h
//  MeNext
//
//  Created by Jim Boulter on 7/15/14.
//  Copyright (c) 2014 Jim Boulter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

@interface SharedData : NSObject

@property AFHTTPSessionManager* sessionManager;
@property AFHTTPSessionManager* youtubeSessionManager;

+(NSMutableString *) sanitizeNSString:(NSString *)string;

-(SharedData*) init;

@end
