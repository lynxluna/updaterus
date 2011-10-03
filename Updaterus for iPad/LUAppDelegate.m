//
//  Updaterus_for_iPadAppDelegate.m
//  Updaterus for iPad
//
//  Created by Muhammad Noor on 10/1/11.
//  Copyright 2011 lynxluna@gmail.com. All rights reserved.
//

#import "LUAppDelegate.h"
#import "LUGirlViewController.h"

@implementation LUAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    LUGirlViewController *girlViewController = [[LUGirlViewController alloc] initWithNibName:@"LUGirlViewController" bundle:nil];
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = girlViewController;
    [girlViewController release];
    [self.window makeKeyAndVisible];
    
    [TestFlight takeOff:@"cf33818437b9fa294f9f57050a60ee4b_MzIzODQyMDExLTEwLTAyIDE5OjE5OjIwLjMxMjYwOQ"];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    /* cancel all requests to prevent crashes */
    if ([[_window rootViewController] isKindOfClass:[LUGirlViewController class]]) {
        LUGirlViewController *girlViewC = (LUGirlViewController*) _window.rootViewController;
        [girlViewC cancelAllRequests];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    if ([[_window rootViewController] isKindOfClass:[LUGirlViewController class]]) {
        LUGirlViewController *girlViewC = (LUGirlViewController*) _window.rootViewController;
        [girlViewC.fetcher activate];
        [girlViewC refresh];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

@end
