//
//  LUBackend.m
//  Updaterus for iPad
//
//  Created by Muhammad Noor on 10/2/11.
//  Copyright 2011 lynxluna@gmail.com. All rights reserved.
//

#import "LUBackend.h"
#import "LUSimpleHTTP.h"
#import "LUBackendDelegate.h"
#import "JSONKit.h"
#import "NSDictionary+QueryString.h"

@interface LUBackend (Private)
- (void) sendRequestWithMethod: (NSString*) method
                          path: (NSString*) path
               queryParameters: (NSDictionary*) params;
@end

@implementation LUBackend
@synthesize connections = _connections;
@synthesize APIDomain = _APIDomain;

- (id)initWithAPIDomain:(NSString *)domainName delegate:(id)delegate
{
    self = [super init];
    if (self) {
        _APIDomain = [domainName retain];
        _delegate = delegate;
    }
    
    return self;
}

- (void) getGirlForNow 
{
    return [self getGirlForDate:[NSDate date]];
}

- (void) getGirlForDate:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:(kCFCalendarUnitHour | kCFCalendarUnitMinute) fromDate:date];
    NSString *path = [NSString stringWithFormat:@"index/at_time/%d/%d", components.hour, components.minute];
    [self sendRequestWithMethod:nil 
                           path:path
                queryParameters:nil];
    [calendar release];
}

- (void) cancel
{
    NSEnumerator *ke = [_connections keyEnumerator];
    NSString *key;
    while ((key = [ke nextObject])) {
        [[_connections objectForKey:key] cancel];
    }
    [_connections removeAllObjects];
}

- (void) connection:(LUSimpleHTTP *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([connection isKindOfClass:[LUSimpleHTTP class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
        connection.response = httpResponse;
        NSInteger statusCode = httpResponse.statusCode;
        
        if (statusCode > 304) {
            [connection cancel];
            NSString *identifier = connection.identifier;
            [_connections removeObjectForKey:identifier];
            if (_delegate && [_delegate respondsToSelector:@selector(connectionFinished:)]) {
                [_delegate performSelector:@selector(connectionFinished:) withObject:identifier];
            }
        }
        
    }
}

- (void) connection:(LUSimpleHTTP *)connection didReceiveData:(NSData *)data
{
    if ([connection isKindOfClass:[LUSimpleHTTP class]]) {
        [connection appendData:data];
    }
}

- (void) connection:(LUSimpleHTTP *)connection didFailWithError:(NSError *)error
{
    if ([connection isKindOfClass:[LUSimpleHTTP class]]) { 
        NSString *ident = connection.identifier;
        
        if (_delegate && [_delegate respondsToSelector:@selector(requestFailed:withError:)]) {
            [_delegate performSelector:@selector(requestFailed:withError:) withObject:ident withObject:error];
        }
        
        [_connections removeObjectForKey:ident];
        
        if (_delegate && [_delegate respondsToSelector:@selector(connectionFinished:)]) {
            [_delegate performSelector:@selector(connectionFinished:) withObject:ident];
        }
    }
}

- (void) connectionDidFinishLoading:(LUSimpleHTTP *)connection
{
    NSInteger statusCode = connection.response.statusCode;
    
    if (statusCode > 400) {
        NSData *receivedData = connection.data;
        NSString * body = receivedData.length > 0 ? [NSString stringWithUTF8String:receivedData.bytes] : @"";
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[connection response], @"response",
                                  body, @"body",
                                  nil];
        
        NSError *error = [NSError errorWithDomain:@"HTTP"
                                             code:statusCode 
                                         userInfo:userInfo];
        
        if (_delegate && [_delegate respondsToSelector:@selector(requestFailed:withError:)]) {
            [_delegate performSelector:@selector(requestFailed:withError:) 
                            withObject:connection.identifier
                            withObject:error];
        }
        
        [connection cancel];
        NSString *ident = [connection identifier];
        [_connections removeObjectForKey:ident];
        if (_delegate && [_delegate respondsToSelector:@selector(connectionFinished:)]) {
            [_delegate performSelector:@selector(connectionFinished:) withObject:ident];
        }
        
        return;
    }
    
    NSString *connid = connection.identifier;
    
    if (_delegate && [_delegate respondsToSelector:@selector(requestSucceeded:)]) {
        [_delegate performSelector:@selector(requestSucceeded:) withObject:connid];
    }
    NSData *receivedData = connection.data;
    
    if (receivedData) {
        NSString *jsonString = [NSString stringWithUTF8String:receivedData.bytes];
        id parsedObject = [jsonString objectFromJSONString];
        if (parsedObject) {
            NSArray *parsedObjects;
            if ([parsedObject isKindOfClass:[NSDictionary class]]) {
                parsedObjects = [NSArray arrayWithObject:parsedObject];
            }
            else if ([parsedObject isKindOfClass:[NSArray class]]) {
                parsedObjects = parsedObject;
            }
            
            if (_delegate && [_delegate respondsToSelector:@selector(girlReceived:forDate:)]) {
                [_delegate performSelector:@selector(girlReceived:forDate:)
                                withObject:parsedObjects
                                withObject:connection.date];
            }
        }
    }
    
    [_connections removeObjectForKey:connid];
    if (_delegate && [_delegate respondsToSelector:@selector(connectionFinished:)]) {
        [_delegate performSelector:@selector(connectionFinished:) withObject:connid];
    }
}

- (void) sendRequestWithMethod:(NSString *)method path:(NSString *)path queryParameters:(NSDictionary *)params
{
    NSString *contentType = [params objectForKey:@"Content-Type"];
    if (contentType) {
        params = [params dictionaryByRemovingObjectForKey:@"Content-Type"];
    }
    else {
        contentType = ( [method isEqualToString:@"POST"] ? @"application/x-www-form-urlencoded" : @"application/json" );
    }
    
    NSMutableDictionary *qsDict = nil;
    if (params) {
        qsDict = [[params mutableCopy] autorelease];
    }
    else {
        qsDict = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    
    NSString *fullPath = [path stringByAddingPercentEscapesUsingEncoding:NSNonLossyASCIIStringEncoding];
    
    if (qsDict && qsDict.count > 0 && ![method isEqualToString:@"POST"]) {
        fullPath = [qsDict queryStringWithBase:fullPath];
    }
    
    NSString *finalString = [NSString stringWithFormat:@"http://%@/%@", _APIDomain, fullPath];
    NSURL *finalURL = [NSURL URLWithString:finalString];
    
    if (!finalURL) {
        return;
    }
    
    NSMutableURLRequest *_request = [NSMutableURLRequest requestWithURL:finalURL];
    
    if (method) {
        _request.HTTPMethod = method;
    }
    
    _request.HTTPShouldHandleCookies = NO;
    [_request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [_request setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [_request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];  
    
    // User agent to the evil ones - mua ha ha!
    [_request setValue:@"Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322) Maxthon" forHTTPHeaderField:@"User-Agent"];
    NSString *padVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"CFBundleVersion"];
    [_request setValue:padVersion forHTTPHeaderField:@"X-HTTP-Pad-Version"];
    
    if (method && [method isEqualToString:@"POST"]) {
        [_request setHTTPBody:[[qsDict queryString] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    
    LUSimpleHTTP *httpConnection = [[LUSimpleHTTP alloc] initWithRequest:_request delegate:self];
    if (!httpConnection) {
        return;
    }
    
    [_connections setObject:httpConnection forKey:httpConnection.identifier];
    
    if ( _delegate && [_delegate respondsToSelector:@selector(connectionStarted:)] ) {
        [_delegate performSelector:@selector(connectionStarted:) withObject:httpConnection.identifier];
    }
}

- (void) dealloc
{
    [_APIDomain release];
    [super dealloc];
}

@end
