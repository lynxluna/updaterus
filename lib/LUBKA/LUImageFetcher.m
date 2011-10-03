//
//  MTImageFetcher.m
//  MindTalk
//
//  Created by Muhammad Noor on 9/17/11.
//  Copyright 2011 lynxluna@gmail.com. All rights reserved.
//

#import "LUImageFetcher.h"
#import "LUSimpleHTTP.h"

@interface LUImageFetcher (PrivateMethods)
- (void) fetchOne: (NSString *)urlString;
+ (NSString*) imageCacheDirectory;
@end

@implementation LUImageFetcher

+ (NSString*) imageCacheDirectory
{
    NSString *imageCacheDir = nil;
    NSString *documentDirectory = [NSTemporaryDirectory() stringByExpandingTildeInPath];
    imageCacheDir = [documentDirectory stringByAppendingPathComponent:@"LUImageCache"];
    return  imageCacheDir;
}

- (NSString*) cacheFileForURL: (NSString*) fullURL
{
    NSArray  *pathComponents = [[NSURL URLWithString:fullURL] pathComponents];
    NSString *photoId        = [pathComponents lastObject];
    NSString *userId         = [pathComponents objectAtIndex:pathComponents.count-2];
    NSString *fileName       = [NSString stringWithFormat:@"%@-%@", userId, photoId];
    NSString *fullCachePath = [[LUImageFetcher imageCacheDirectory] stringByAppendingPathComponent:fileName];
    return [[fullCachePath copy] autorelease];
}


- (BOOL) fileExistsInCache: (NSString*) fullURL
{
    NSFileManager *fm  = [NSFileManager defaultManager];
    NSString *cacheFilePath = [self cacheFileForURL:fullURL];
    return [fm fileExistsAtPath:cacheFilePath];
}

- (void) clearCaches
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [fm enumeratorAtPath:[LUImageFetcher imageCacheDirectory]];
    NSError *error = nil;
    BOOL res;
    
    NSString *fileName;
    while ((fileName = [dirEnum nextObject])) {
        NSString *fullPath = [[LUImageFetcher imageCacheDirectory] stringByAppendingPathComponent:fileName];
        res = [fm removeItemAtPath:fullPath error:&error];
        if (!res && error) {
            NSLog(@"[Error when clearing caches: %@", [error localizedDescription]);
        }
    }
}

- (BOOL) isCacheEmpty
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *contents = [fm contentsOfDirectoryAtPath:[LUImageFetcher imageCacheDirectory] error:&error];
    
    return  (!contents || [contents count] <= 0 ? YES : NO);
}
   
- (id)init 
{
    return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id)delegate
{
    self = [super init];
    if (self) {
        _connections = [[NSMutableDictionary alloc] initWithCapacity:0];
        _queue       = [[NSMutableArray alloc] initWithCapacity:0];
        _delegate = delegate;
        _maxFetch = 4;
        _canceled = NO;
    }
    
    return self;
}

- (void) fetchImage:(NSString *)imageURL cached:(BOOL)cached
{
    if (imageURL && imageURL.length>0) {
        /* hack, bug on the cdn vs digaku.com server */
        
        if ([[imageURL substringToIndex:1] isEqualToString:@"/"]) {
            NSString *digakuOldURL = @"http://digaku.com";
            imageURL = [digakuOldURL stringByAppendingPathComponent:imageURL];
        }
        
        ///////////////////////////////////////////////
        
        if ([NSURL URLWithString:imageURL] == nil) {
            NSError *error = nil;
            if (_delegate && [_delegate respondsToSelector:@selector(imageFailed:withError:)]) {
                [_delegate performSelector:@selector(imageFailed:withError:) 
                                withObject:imageURL
                                withObject:error];
            }
            return;
        }
        if (![self fileExistsInCache:imageURL]) {
        
            if ([_connections count] >= _maxFetch) {
                [_queue addObject:imageURL];
            }
            else {
                [self fetchOne:imageURL];
            }
        }
        else {
            if ( _delegate && [_delegate respondsToSelector:@selector(imageReceived:toCache:)]) {
                [_delegate performSelector:@selector(imageReceived:toCache:)
                                withObject:imageURL
                                withObject:[self cacheFileForURL:imageURL]];
            }
        }
    }
}

- (void) fetchImages:(NSArray *)imageUrls cached:(BOOL)cached
{
    for (NSString *image in imageUrls) {
        [self fetchImage:image cached:cached];
    }
}

- (void) nextImage
{
    if (_queue.count > 0) {
        NSString *nextImage = [_queue objectAtIndex:0];
        [self fetchOne:nextImage];
        [_queue removeObjectAtIndex:0];
    }
}

- (void) fetchOne:(NSString *)urlString
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setValue:@"MTEngine-ImageFetcher" forHTTPHeaderField:@"X-MT-Fetcher-Software"];
    
    LUSimpleHTTP *conn = [[LUSimpleHTTP alloc] initWithRequest:request delegate:self];
    [_connections setValue:conn forKey:conn.identifier];
    [conn release];
    [request release];
}

- (void) connection:(LUSimpleHTTP *)connection didReceiveResponse:(NSURLResponse *)response
{
    [connection resetDataLength];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
    [connection setResponse:httpResponse];
    NSInteger statusCode = [httpResponse statusCode];
    
    if (statusCode == 304) {
        [connection cancel];
        NSString *ident = [connection identifier];
        [_connections removeObjectForKey:ident];
        [self nextImage];
    }
}

- (void) connection:(LUSimpleHTTP *)connection didReceiveData:(NSData *)data
{
    [connection appendData:data];
}

- (void) connection:(LUSimpleHTTP *)connection didFailWithError:(NSError *)error
{
    NSString *imageURL   = [[[connection response] URL] absoluteString];
    
    [_connections removeObjectForKey:[connection identifier]];
    [self nextImage];
    
    if (_delegate && [_delegate respondsToSelector:@selector(imageFailed:withError:)]) {
        [_delegate performSelector:@selector(imageFailed:withError:) 
                        withObject:imageURL
                        withObject:error];
    }
}

- (void) cancel
{
    _canceled = YES;
    NSString *key;
    NSEnumerator *enumerator = [_connections keyEnumerator];
    while ((key = [enumerator nextObject])) {
        [[_connections objectForKey:key] close];
    }
    [_connections removeAllObjects];
    [_queue removeAllObjects];
}

- (void) connectionDidFinishLoading:(LUSimpleHTTP *)connection
{
    NSInteger statusCode = [[connection response] statusCode];
    NSString *imageURL   = [[[connection response] URL] absoluteString];
    
    if (_canceled) {
        return;
    }
    
    if (statusCode > 400) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[connection response], @"response",
                                  imageURL, @"url",
                                  nil];
        
        NSError *error = [NSError errorWithDomain:@"HTTP"
                                             code:statusCode 
                                         userInfo:userInfo];
        
        if (_delegate && [_delegate respondsToSelector:@selector(imageFailed:withError:)]) {
            [_delegate performSelector:@selector(imageFailed:withError:) 
                            withObject:imageURL
                            withObject:error];
        }
        
        [connection cancel];
        
        NSString *ident = [connection identifier];
        [_connections removeObjectForKey:ident];
        [self nextImage];
        return;
    }
    
    NSString *connid = [connection identifier];
    NSData *receivedData = [connection data];
    
    /* creating Directory first */
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL dirCreate = [fm createDirectoryAtPath:[LUImageFetcher imageCacheDirectory]
                         withIntermediateDirectories:YES 
                                    attributes:nil 
                                         error:&error];
    if (dirCreate == YES) {
    
        if (receivedData) {
            NSString *fileName = [[imageURL componentsSeparatedByString:@"/"] lastObject];
            NSString *imagePath = [NSString stringWithFormat:@"%@/%@", 
                                   [LUImageFetcher imageCacheDirectory], 
                                   fileName];
            BOOL saveSuccess = [receivedData writeToFile:imagePath atomically:YES];
            
            if (!_canceled) {
                if (saveSuccess && _delegate && _delegate != [NSNull null] && [_delegate respondsToSelector:@selector(imageReceived:toCache:)]) {
                    [_delegate performSelector:@selector(imageReceived:toCache:)
                                withObject:imageURL
                                withObject:imagePath];
                }
            }
        }
    }
    
    [_connections removeObjectForKey:connid];
    [self nextImage];
    if (!_canceled) {
        if (_delegate && [_delegate respondsToSelector:@selector(connectionFinished:)]) {
            [_delegate performSelector:@selector(connectionFinished:) withObject:connid];
        }
    }
}

- (void) activate
{
    _canceled = NO;
}

- (void) dealloc
{
    NSEnumerator *enumerator = [_connections keyEnumerator];
    NSString *key;
    while ((key = [enumerator nextObject])) {
        [[_connections objectForKey:key] close];
    }
    [_connections removeAllObjects];
    
    [_queue release];
    [_connections release];
    [super dealloc];
}


@end
