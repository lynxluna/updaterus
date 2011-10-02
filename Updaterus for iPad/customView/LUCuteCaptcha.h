//
//  LUCuteCaptcha.h
//  Updaterus for iPad
//
//  Created by Muhammad Noor on 10/3/11.
//  Copyright 2011 lynxluna@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LUCuteCaptcha : UIView<UIWebViewDelegate> {
    UIWebView *_captchaView;
    NSString *_currId;
}

- (void) show: (NSString*) userId;
@end
