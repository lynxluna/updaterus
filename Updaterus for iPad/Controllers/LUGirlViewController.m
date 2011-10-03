//
//  LUGirlViewController.m
//  Updaterus for iPad
//
//  Created by Muhammad Noor on 10/2/11.
//  Copyright 2011 lynxluna@gmail.com. All rights reserved.
//

#import "LUGirlViewController.h"
#import "Reachability.h"
#import "LUBackend.h"
#import "GADBannerView.h"
#import "LUFullWebController.h"
#import "LUCuteCaptcha.h"

@interface LUGirlViewController (Private)
- (void) fetchGirl: (NSTimer*) timer;
@end

@implementation LUGirlViewController
@synthesize socialTableView = _socialTableView;
@synthesize cuteButton = _cuteButton;
@synthesize photoView = _photoView;
@synthesize nameLabel = _nameLabel;
@synthesize cuteCountLabel = _cuteCountLabel;
@synthesize paused = _paused;
@synthesize timer = _timer;
@synthesize fetcher = _fetcher;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _backend = [[LUBackend alloc] initWithAPIDomain:@"updaterus.com" delegate:self];
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        _hud.animationType = MBProgressHUDAnimationZoom;
        _hud.delegate = self;
        _firstTime = NO;
        _girlData = [NSDictionary dictionary];
        _fetcher  = [[LUImageFetcher alloc] initWithDelegate:self];
        _adView = [[GADBannerView alloc] initWithFrame:CGRectMake(0.0,
                                                                  self.view.frame.size.height -
                                                                  GAD_SIZE_728x90.height,
                                                                  GAD_SIZE_728x90.width,
                                                                  GAD_SIZE_728x90.height)];
        
        NSDate *fistFireDate = [[NSDate date] addTimeInterval:2.0f];
        _timer = [[NSTimer alloc] initWithFireDate:fistFireDate 
                                          interval:60.0f 
                                            target:self 
                                          selector:@selector(fetchGirl:) 
                                          userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
        _imageIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _webController = [[LUFullWebController alloc] initWithNibName:@"LUFullWebController" bundle:nil];
        _paused = NO;
    }
    return self;
}

- (void) cancelAllRequests
{
    [_backend cancel];
    [_fetcher cancel];
}

- (void) fetchGirl:(NSTimer *)timer
{
    [_backend getGirlForNow];
}

- (void) hudWasHidden
{
    [_hud removeFromSuperview];
}

- (void) captchaDialogSucceded
{
    NSInteger currentCute = [[_girlData objectForKey:@"cute"] integerValue];
    ++currentCute;
    
    NSMutableDictionary *dict = [_girlData mutableCopy];
    [dict setValue:[NSString stringWithFormat:@"%d", currentCute] forKey:@"cute"];
    [_girlData release];
    _girlData = [dict retain];
    [dict release];
    
    self.cuteCountLabel.text = [_girlData objectForKey:@"cute"];
    self.cuteButton.enabled = NO;
}

- (void) dealloc
{
    [_backend cancel];
    [_fetcher cancel];
    [_timer release];
    [_imageIndicator release];
    [_webController release];
    [_backend release];
    [_hud release];
    [_socialTableView release];
    [_cuteButton release];
    [_photoView release];
    [_nameLabel release];
    [_cuteCountLabel release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.photoView addSubview:_imageIndicator];
    _imageIndicator.hidesWhenStopped = YES;
    [_imageIndicator stopAnimating];
    
    
    _adView.adUnitID = @"a14e8895eddb20d";
    _adView.rootViewController = self;
    [self.view addSubview:_adView];
    GADRequest *request = [GADRequest request];
    
    request.testDevices = [NSArray arrayWithObjects:
                           GAD_SIMULATOR_ID,                               // Simulator
                           @"0c3411d7be96f9787620ad7c7fc80e89199994eb",
                           nil];
    [_adView loadRequest:request];
}

- (BOOL)isReachable
{
    Reachability * r = [Reachability reachabilityWithHostName:@"updaterus.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if (internetStatus == NotReachable) {
        return NO;
    }
    return YES;
}

- (BOOL) checkConnections 
{
    BOOL reach = NO;
    reach = [self isReachable];
    if (!reach) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Error", @"Network Error Title")
                                                            message:NSLocalizedString(@"Network is unreachable, please check your internet connection.", @"Network reach error message") 
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"Try Again", @"Try Again Button")
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    return reach;
}

- (void) requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
    [_hud hide:YES];
    if ([self checkConnections]) {
        [_backend getGirlForNow];
    }
    
}

- (void) imageReceived:(NSString *)urlString toCache:(NSString *)cachePath
{
    NSString *userId   = [_girlData objectForKey:@"id"];
    NSString *photoSeq = [_girlData objectForKey:@"photo_seq"];
    NSString *url      = [NSString stringWithFormat:@"http://www.updaterus.com/images/users/%@/%@.jpg", userId, photoSeq];
    if ([urlString isEqualToString:url]) {
        self.photoView.image = [UIImage imageWithContentsOfFile:cachePath];
    }
    [_imageIndicator stopAnimating];
}

- (void) connectionStarted:(NSString *)connectionIdentifier
{
    if (!_firstTime) {
        _firstTime = YES;
        _hud.mode = MBProgressHUDModeIndeterminate;
        _hud.labelText = @"Getting new Data..";
        [_hud show:YES];
    }
}

- (void) requestSucceeded:(NSString *)connectionIdentifier
{
    if (_hud.isHidden == NO) {
        _hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
        _hud.mode = MBProgressHUDModeCustomView;
        _hud.labelText = @"Done";
        [_hud hide:YES afterDelay:1];
    }
}

- (void) girlReceived:(NSArray *)girlData forDate:(NSDate *)date
{
    
    
    if (girlData && girlData.count > 0) {
        self.cuteButton.enabled = YES;
        [_girlData release];
        _girlData = [[girlData objectAtIndex:0] retain];
        self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [_girlData objectForKey:@"firstname"],
                               [_girlData objectForKey:@"lastname"]];
        [self.socialTableView reloadData];
        
        NSString *userId   = [_girlData objectForKey:@"id"];
        NSString *photoSeq = [_girlData objectForKey:@"photo_seq"];
        NSString *url      = [NSString stringWithFormat:@"http://www.updaterus.com/images/users/%@/%@.jpg", userId, photoSeq];
        self.cuteCountLabel.text = [_girlData objectForKey:@"cute"];
        [_fetcher fetchImage:url cached:YES];
        [self.photoView setImage:[UIImage imageNamed:@"no-photo.jpg"]];
        [_imageIndicator startAnimating];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        return;
    }
    
    [self checkConnections];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self checkConnections];
}

- (void)viewDidUnload
{
    [self setSocialTableView:nil];
    [self setCuteButton:nil];
    [self setPhotoView:nil];
    [self setNameLabel:nil];
    [self setCuteCountLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID;
    UITableViewCellStyle cellStyle;
    if (indexPath.row == 3 && indexPath.row == 4) {
        cellID = @"SubtitleCell";
        cellStyle  = UITableViewCellStyleSubtitle;
    }
    else {
        cellID = @"Value2Cell";
        cellStyle = UITableViewCellStyleValue2;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:cellStyle 
                                       reuseIdentifier:cellID] autorelease];
    }
    
    if (!_girlData || _girlData.count == 0) {
        return  cell;
    }
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Name";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", [_girlData objectForKey:@"firstname"],
                                         [_girlData objectForKey:@"lastname"]];
            break;
        case 1:
            cell.textLabel.text = @"Location";
            cell.detailTextLabel.text = [_girlData objectForKey:@"location"];
            break;
        case 2:
            cell.textLabel.text = @"Hobby";
            cell.detailTextLabel.text = [_girlData objectForKey:@"hobby"];
            break;
        case 3:
            cell.textLabel.text = @"Facebook";
            cell.detailTextLabel.text = [_girlData objectForKey:@"facebook"];
            break;
        case 4:
            {
                cell.textLabel.text = @"Twitter";
                NSString *twitterURL = [_girlData objectForKey:@"twitter"];
                NSString *twitterUName = [[twitterURL pathComponents] lastObject];
                if (twitterUName && twitterUName.length > 0) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"@%@", twitterUName];
                }
                else {
                    cell.detailTextLabel.text = @"N/A";
                }
            }
            break;
        case 5:
            cell.textLabel.text = @"Birth Day";
            cell.detailTextLabel.text = [_girlData objectForKey:@"birthday"];
            break;
        case 6:
            cell.textLabel.text = @"Website";
            cell.detailTextLabel.text = [_girlData objectForKey:@"website"];
            break;
        default:
            break;
    }
    return  cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (NSInteger) tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return 1;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *openedURL = nil;
    switch (indexPath.row) {
        case 3:
            openedURL = [_girlData objectForKey:@"facebook"];
            break;
        case 4:
            openedURL = [_girlData objectForKey:@"twitter"];        
            break;
        case 6:
            openedURL = [_girlData objectForKey:@"website"];
            break;
        default:
            break;
    }
    
    if (!openedURL || openedURL.length == 0) {
        return;
    }
    
    if ([openedURL rangeOfString:@"http://"].location == NSNotFound) {
        openedURL = [NSString stringWithFormat:@"http://%@", openedURL];
    }
    
    NSURL *dataURL = [NSURL URLWithString:openedURL];
    
    if (dataURL) {
        NSURLRequest *req = [NSURLRequest requestWithURL:dataURL];
        [_webController.webView loadRequest:req];
        [self presentModalViewController:_webController animated:YES];
        
        // [[UIApplication sharedApplication] openURL:dataURL];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (UIInterfaceOrientationIsLandscape(interfaceOrientation) ? NO : YES);
}

- (IBAction)cuteButtonTappe:(id)sender {
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGSize cuteSize = CGSizeMake(400.0f, 200.0f);
    CGPoint cutePos = CGPointMake((screenSize.width - cuteSize.width) * 0.5f,
                                  (screenSize.height - cuteSize.height) * 0.5f);
    
    NSString *uid = [_girlData objectForKey:@"id"];
    if (uid && uid.length > 0) {
    
        LUCuteCaptcha *capchaBox = [[[LUCuteCaptcha alloc] initWithFrame:CGRectMake(cutePos.x, cutePos.y, cuteSize.width, cuteSize.height) delegate:self] autorelease];
        [capchaBox show:uid];
    }
}
@end
