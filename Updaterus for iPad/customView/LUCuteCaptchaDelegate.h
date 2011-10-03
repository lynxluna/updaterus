//
//  LUCuteCaptchaDelegate.h
//  Updaterus for iPad
//
//  Created by Muhammad Noor on 10/4/11.
//  Copyright 2011 lynxluna@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LUCuteCaptcha;
@protocol LUCuteCaptchaDelegate <NSObject>
@optional

- (void) cuteCaptcha: (LUCuteCaptcha*) dialog cuteGivenToUserWithId: (NSString*) userId;

@end
