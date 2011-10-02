//
//  LUBackendTest.m
//  Updaterus for iPad
//
//  Created by Muhammad Noor on 10/2/11.
//  Copyright 2011 lynxluna@gmail.com. All rights reserved.
//

#import "LUBackendTest.h"
#import "LUBackend.h"

@implementation LUBackendTest

- (void) setUpClass 
{
    _backend = [[LUBackend alloc] initWithAPIDomain:@"updaterus.com" delegate:self];
}

- (void) tearDownClass 
{
    [_backend release];
}

- (void) testGetGirl
{
    [self prepare];
    [_backend getGirlForNow];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0f];
}

- (void) girlReceived:(NSArray *)girlData forDate:(NSDate *)date
{
    if (girlData && girlData.count > 0) {
        GHTestLog(@"Received Data \n%@", [girlData objectAtIndex:0]);
        [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testGetGirl)];
    }
}

@end
