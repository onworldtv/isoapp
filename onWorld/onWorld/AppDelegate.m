//
//  AppDelegate.m
//  OnWorld
//
//  Created by yestech1 on 6/22/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "AppDelegate.h"
#import "YTNetWorkManager.h"
#import "ListViewController.h"
#import "YTHomeViewController.h"
#import "MHTabBarController.h"
#import "YTGridViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    ListViewController *listViewController1 = [[ListViewController alloc] initWithStyle:UITableViewStylePlain];
    ListViewController *listViewController2 = [[ListViewController alloc] initWithStyle:UITableViewStylePlain];
    YTGridViewController *listViewController3 = [[YTGridViewController alloc] initWithNibName:@"YTGridViewController" bundle:nil];
    
    listViewController1.title = @"Tab 1";
    listViewController2.title = @"Tab 2";
    listViewController3.title = @"Tab 3";
    
    NSArray *viewControllers = @[listViewController1, listViewController2, listViewController3];
    YTHomeViewController *tabBarController = [[YTHomeViewController alloc] initWithNibName:@"YTHomeViewController" bundle:nil];
    
    tabBarController.viewControllers = viewControllers;
    
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}


@end
