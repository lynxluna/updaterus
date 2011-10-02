//
//  LUSimpleHTTP.m
//  Updaterus for iPad
//
//  Created by Muhammad Noor on 10/2/11.
//  Copyright 2011 lynxluna@gmail.com. All rights reserved.
//

#import "LUSimpleHTTP.h"
#import "NSString+QueryString.h"
#import "NSDictionary+QueryString.h"


@implementation LUSimpleHTTP
@synthesize data = _data;
@synthesize identifier = _identifier;
@synthesize URL = _URL;
@synthesize response = _response;
@synthesize date = _date;

- (id) initWithRequest:(NSURLRequest *)request delegate:(id)delegate
{
    self = [super initWithRequest:request delegate:delegate];
    if (self) {
        _data = [[NSMutableData alloc] initWithLength:0];
        _identifier = [[NSString stringWithNewUUID] retain];
        _URL =[[request URL] retain];
    }
    
    return self;
}

- (void) resetDataLength
{
    [_data setLength:0];
}

- (void) appendData: (NSData*) data
{
    [_data appendData:data];
}

- (void) dealloc
{
    [_data release];
    [_identifier release];
    [_URL release];
    [super dealloc];
}

@end
