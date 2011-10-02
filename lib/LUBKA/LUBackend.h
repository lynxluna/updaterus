//
//  LUBackend.h
//  Updaterus for iPad
//
//  Created by Muhammad Noor on 10/2/11.
//  Copyright 2011 lynxluna@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LUBackend : NSObject {
    id _delegate;
    NSMutableDictionary *_connections;
    NSString *_APIDomain;
}

- (id) initWithAPIDomain: (NSString*) domainName delegate: (id) delegate;
- (void) cancel;
- (void) getGirlForDate: (NSDate*) date;
- (void) getGirlForNow;

@property(nonatomic, assign, readonly) NSDictionary *connections;
@property(nonatomic, retain) NSString *APIDomain;

@end
