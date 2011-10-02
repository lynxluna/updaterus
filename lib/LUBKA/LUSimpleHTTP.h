//
//  LUSimpleHTTP.h
//  Updaterus for iPad
//
//  Created by Muhammad Noor on 10/2/11.
//  Copyright 2011 lynxluna@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LUSimpleHTTP : NSURLConnection {
    NSMutableData *_data;
    NSString *_identifier;
    NSURL *_URL;
    NSHTTPURLResponse *_response;
    NSDate *_date;
}

@property(nonatomic, retain) NSData *data;
@property(nonatomic, retain) NSString *identifier;
@property(nonatomic, retain) NSURL *URL;
@property(nonatomic, retain) NSHTTPURLResponse *response;
@property(nonatomic, retain) NSDate *date;

- (void) resetDataLength;
- (void) appendData: (NSData*) data;

@end
