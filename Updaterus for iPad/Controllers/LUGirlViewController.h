//
//  LUGirlViewController.h
//  Updaterus for iPad
//
//  Created by Muhammad Noor on 10/2/11.
//  Copyright 2011 lynxluna@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LUBackendDelegate.h"
#import "LUImageFetcher.h"

#import "MBProgressHUD.h"
#import "LUCuteCaptchaDelegate.h"
@class LUBackend;
@class MBProgressHUD;
@class GADBannerView;
@class LUFullWebController;
@interface LUGirlViewController : UIViewController<LUBackendDelegate, UIAlertViewDelegate, MBProgressHUDDelegate, UITableViewDataSource, UITableViewDelegate, LUImageFetcherDelegate, LUCuteCaptchaDelegate> {
    LUBackend *_backend;
    MBProgressHUD *_hud;
    BOOL _firstTime;
    NSDictionary *_girlData;
    NSDictionary *_nextGirlData;
    UITableView *_socialTableView;
    UIButton *_cuteButton;
    UIImageView *_photoView;
    UILabel *_nameLabel;
    UILabel *_cuteCountLabel;
    NSTimer *_timer;
    LUImageFetcher *_fetcher;
    UILabel *_versionLabel;
    UIActivityIndicatorView *_loadingIndicator;
    UILabel *_fetchingProgressLabel;
    UIImageView *_logoView;
    UILabel *_descLabel;
    UIImageView *_arrowLabel;
    UIActivityIndicatorView *_imageIndicator;
    GADBannerView *_adView;
    LUFullWebController *_webController;
    BOOL _paused;
}
@property (nonatomic, retain) IBOutlet UITableView *socialTableView;
@property (nonatomic, retain) IBOutlet UIButton *cuteButton;
@property (nonatomic, retain) IBOutlet UIImageView *photoView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *cuteCountLabel;
@property (nonatomic, assign) BOOL     paused;
@property (nonatomic, retain, readonly) NSTimer *timer;
@property (nonatomic, retain, readonly) LUImageFetcher *fetcher;
@property (nonatomic, retain) IBOutlet UILabel *versionLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) IBOutlet UILabel *fetchingProgressLabel;
@property (nonatomic, retain) IBOutlet UIImageView *logoView;
@property (nonatomic, retain) IBOutlet UILabel *descLabel;
@property (nonatomic, retain) IBOutlet UIImageView *arrowLabel;

- (IBAction)cuteButtonTappe:(id)sender;
- (void) cancelAllRequests;
- (void) refresh;
@end
