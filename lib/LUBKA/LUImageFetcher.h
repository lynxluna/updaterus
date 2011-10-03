//
//  MTImageFetcher.h
//  MindTalk
//
//  Created by Muhammad Noor on 9/17/11.
//  Copyright 2011 lynxluna@gmail.com. All rights reserved.
//

#include <Foundation/Foundation.h>

@protocol LUImageFetcherDelegate <NSObject>
- (void) imageReceived: (NSString*) urlString toCache: (NSString*) cachePath;
@optional
- (void) imageFailed: (NSString*) urlString withError: (NSError*) error;
- (void) imageCancelled: (NSString*) urlString;

@end

@interface LUImageFetcher : NSObject {
    NSMutableDictionary *_connections;
    id _delegate;
    NSUInteger _maxFetch;
    NSMutableArray *_queue;
    BOOL _working;
    BOOL _canceled;
    
}

- (id)initWithDelegate:(id)delegate;
- (void) fetchImage: (NSString*) imageURL cached: (BOOL) cached;
- (void) fetchImages: (NSArray*) imageUrls cached: (BOOL) cached;
- (void) clearCaches;
- (BOOL) fileExistsInCache: (NSString*) fullURL;
- (NSString*) cacheFileForURL: (NSString*) fullURL;
- (void) cancel;
- (void) activate;

@property (nonatomic, assign, readonly) BOOL isCacheEmpty;
@end
