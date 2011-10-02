//
//  LUFullWebController.h
//  Updaterus for iPad
//
//  Created by Muhammad Noor on 10/3/11.
//  Copyright 2011 lynxluna@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LUFullWebController : UIViewController<UIWebViewDelegate> {

    UIWebView *webView;
    UINavigationItem *navBar;
    UIActivityIndicatorView *_loadView;
}
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UINavigationItem *navBar;


@end
