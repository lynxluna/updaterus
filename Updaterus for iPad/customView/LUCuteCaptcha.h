//
//  LUCuteCaptcha.h
//  Updaterus for iPad
//
//  Created by Muhammad Noor on 10/3/11.
//  Copyright 2011 lynxluna@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LUCuteCaptcha;
@protocol LUCuteCaptchaDelegate <NSObject>

- (void) captchaDialogSucceded;

@end

@interface LUCuteCaptcha : UIView<UIWebViewDelegate> {
    UIWebView *_captchaView;
    NSString *_currId;
    id _delegate;
}

- (void) show: (NSString*) userId;
- (id)initWithFrame:(CGRect)frame delegate: (id) delegate;
@end
