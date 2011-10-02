//
//  LUBackendTest.h
//  Updaterus for iPad
//
//  Created by Muhammad Noor on 10/2/11.
//  Copyright 2011 lynxluna@gmail.com. All rights reserved.
//


#import <GHUnit.h>
#import "LUBackendDelegate.h"

@class LUBackend;
@interface LUBackendTest : GHAsyncTestCase<LUBackendDelegate> {
    LUBackend *_backend;
}

@end
