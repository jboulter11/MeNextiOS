//
//  RLMLoginCredential.h
//  MeNext
//
//  Created by Jim Boulter on 5/14/15.
//  Copyright (c) 2015 Jim Boulter. All rights reserved.
//

#import <Realm/Realm.h>

RLM_ARRAY_TYPE(RLMLoginCredential)
@interface RLMLoginCredential : RLMObject
@property BOOL loggedIn;
@end
