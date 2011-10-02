//
//  LUBackendDelegate.h
//  Updaterus for iPad
//
//  Created by Muhammad Noor on 10/2/11.
//  Copyright 2011 lynxluna@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LUBackendDelegate <NSObject>

@optional

- (void) requestSucceeded: (NSString*) connectionIdentifier;
- (void) requestFailed: (NSString*) connectionIdentifier withError: (NSError*) error;

- (void) connectionStarted: (NSString*) connectionIdentifier;
- (void) connectionFinished: (NSString*) connectionIdentifier;

- (void) girlReceived: (NSArray*) girlData forDate: (NSDate*) date;

@end
