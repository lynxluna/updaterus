//
//  NSDictionary+MindTalk.h
//  MindTalk
//
//  Created by Muhammad Noor on 9/17/11.
//  Copyright 2011 lynxluna@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (QueryString)

- (NSString*) queryString;
- (NSString*) queryStringWithBase: (NSString*) baseURL;
+ (NSDictionary*) dictionaryFromQueryString: (NSString*) queryString;
- (NSDictionary*) dictionaryByRemovingObjectForKey: (NSString*) key;

@end
