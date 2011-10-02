//
//  NSDictionary+MindTalk.m
//  MindTalk
//
//  Created by Muhammad Noor on 9/17/11.
//  Copyright 2011 lynxluna@gmail.com. All rights reserved.
//

#import "NSDictionary+QueryString.h"
#import "NSString+QueryString.h"

@implementation NSDictionary (QueryString)
- (NSString*) queryString
{
    NSMutableString *qs = [NSMutableString stringWithCapacity:0];
    
    if ([self count] == 0) {
        return nil;
    }
    
    NSArray *sortedArrays = [[self allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    for (NSString *key in sortedArrays) {
        id val = [self valueForKey:key];
        if (val == nil) {
            continue;
        }
        NSString *strVal = nil;
        
        if ([val isKindOfClass:[NSNumber class]]) {
            strVal = [val performSelector:@selector(stringValue)];
        }
        else if ([val isKindOfClass:[NSString class]]) {
            strVal = (NSString*) val;
        }
        else {
            strVal = nil;
        }
        
        if ([key isKindOfClass:[NSString class]] && ( strVal && strVal.length > 0 ) ) {
            [qs appendString:[NSString stringWithFormat:@"%@=%@&", 
                              [key percentEncoded], 
                              [strVal percentEncoded]]];
        }
    }
    
    return [qs chop];
}

- (NSString*) queryStringWithBase:(NSString*) baseURL
{
    return [NSString stringWithFormat:@"%@?%@", baseURL, [self queryString]];
}

- (NSDictionary*) dictionaryByRemovingObjectForKey:(NSString *)key
{
    NSDictionary *result = self;
    if (key) {
        NSMutableDictionary *newParams = [[self mutableCopy] autorelease];
        [newParams removeObjectForKey:key];
        result = [[newParams copy] autorelease];
    }
    return result;
}

+ (NSDictionary*) dictionaryFromQueryString:(NSString *)queryString
{
    NSArray *chunks = [[queryString percentDecoded] componentsSeparatedByString:@"&"];
    NSMutableDictionary *ret = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
    
    if ([chunks count] <=0) {
        return nil;
    }
    
    for (NSString *chunk in chunks) {
        NSArray *kvp = [chunk componentsSeparatedByString:@"="];
        [ret setObject:[kvp objectAtIndex:1] forKey:[kvp objectAtIndex:0]];
    }
    
    return ret;
}
@end
