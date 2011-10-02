//
//  LUGirlViewController.h
//  Updaterus for iPad
//
//  Created by Muhammad Noor on 10/2/11.
//  Copyright 2011 lynxluna@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LUBackendDelegate.h"
#import "MBProgressHUD.h"
@class LUBackend;
@class MBProgressHUD;
@interface LUGirlViewController : UIViewController<LUBackendDelegate, UIAlertViewDelegate, MBProgressHUDDelegate, UITableViewDataSource, UITableViewDelegate> {
    LUBackend *_backend;
    MBProgressHUD *_hud;
    BOOL _firstTime;
    NSDictionary *_girlData;
    UITableView *_socialTableView;
    UIButton *_cuteButton;
    UIImageView *_photoView;
    UILabel *_nameLabel;
    NSTimer *_timer;
}
@property (nonatomic, retain) IBOutlet UITableView *socialTableView;
@property (nonatomic, retain) IBOutlet UIButton *cuteButton;
@property (nonatomic, retain) IBOutlet UIImageView *photoView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;

@end
