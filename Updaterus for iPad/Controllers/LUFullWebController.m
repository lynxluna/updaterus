//
//  LUFullWebController.m
//  Updaterus for iPad
//
//  Created by Muhammad Noor on 10/3/11.
//  Copyright 2011 lynxluna@gmail.com. All rights reserved.
//

#import "LUFullWebController.h"

@implementation LUFullWebController
@synthesize webView;
@synthesize navBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) closeBrowser
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeBrowser)];
    self.navBar.leftBarButtonItem = backButton;
    [backButton release];
    
    _loadView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    _loadView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [_loadView sizeToFit];
    [_loadView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
    _loadView.hidesWhenStopped = YES;
    [_loadView stopAnimating];
    UIBarButtonItem *loadingItem = [[UIBarButtonItem alloc] initWithCustomView:_loadView];
    self.navBar.rightBarButtonItem = loadingItem;
    [loadingItem release];
}

- (void) webViewDidStartLoad:(UIWebView *)theWebView
{
    if (theWebView == webView) {
        [_loadView startAnimating];
    }
}

- (void) webViewDidFinishLoad:(UIWebView *)theWebView
{
    if (theWebView == webView) {
        [_loadView stopAnimating];
    }
}

- (void) webView:(UIWebView *)theWebView didFailLoadWithError:(NSError *)error
{
    if (theWebView == webView) {
        [_loadView stopAnimating];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Navigation Error", @"Navigation Error Title")
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Cancel" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setNavBar:nil];
    [self setNavBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)dealloc {
    [_loadView release];
    [webView release];
    [navBar release];
    [navBar release];
    [super dealloc];
}
@end
