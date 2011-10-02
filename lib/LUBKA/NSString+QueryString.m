//
//  NSString+UUID.m
//  MindTalk
//
//  Created by Muhammad Noor on 9/17/11.
//  Copyright 2011 lynxluna@gmail.com. All rights reserved.
//

#import "NSString+QueryString.h"

@implementation NSString (QueryString)

+ (NSString*) stringWithNewUUID
{
    CFUUIDRef uuidQbj = CFUUIDCreate(nil);
    NSString *newUUID = (NSString*) CFUUIDCreateString(nil, uuidQbj);
    CFRelease(uuidQbj);
    
    return [newUUID autorelease];
}

- (NSString*) percentEncoded
{
    NSString *result = (NSString*) CFURLCreateStringByAddingPercentEscapes(nil, 
                                                                           (CFStringRef) self, 
                                                                           nil,                
                                                                           (CFStringRef)@";/?:@&=$+{}<>,",
                                                                           kCFStringEncodingUTF8);
    return [result autorelease];
    
}

- (NSString*) percentDecoded
{
    NSString *result = [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

- (NSString*) chop
{
    return [self substringToIndex:[self length] -1];
}
@end
