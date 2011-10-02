//
//  NSString+UUID.h
//  MindTalk
//
//  Created by Muhammad Noor on 9/17/11.
//  Copyright 2011 lynxluna@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (QueryString)

+ (NSString*) stringWithNewUUID;
- (NSString*) percentEncoded;
- (NSString*) percentDecoded;
- (NSString*) chop;

@end
