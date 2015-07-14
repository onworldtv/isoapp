//
//  AppDelegate.m
//  OnWorld
//
//  Created by yestech1 on 6/22/15.
//  Copyright (c) 2015 OnWorld. All rights reserved.
//

#import "AppDelegate.h"
#import "YTPlayerViewController.h"
#import "YTTimelineViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    
//    [DATA_MANAGER advInfoWithURLString:@"http://tracker.onworldtv.com/www/delivery/fc.php?script=bannerTypeHtml:vastInlineBannerTypeHtml:vastInlineHtml&nz=1&format=vast&zones=overlay:0.0-0%3D20"];
//    DATA_MANAGER;
//    
//    [[DATA_MANAGER pullAllMetaData] continueWithBlock:^id(BFTask *task) {
//        return [DATA_MANAGER pullGroupContent];
//    }];
    
    YTPlayerViewController *playerView = [[YTPlayerViewController alloc]initWithNibName:@"YTPlayerViewController" bundle:nil];
    NSURL *ulrPath = [NSURL URLWithString:@"http://origin.onworldtv.com:1935/liveorigin/stream_lstv/playlist.m3u8?worldtokenstarttime=1436411142&worldtokenendtime=1436495742&worldtokenhash=OceWL9xxvx_vjoca1ju-njEW6FjyqxbqToo8TI4gSWY="];
//    [playerView setUrlPath:ulrPath];
    [self.window setRootViewController:playerView];
    [self.window makeKeyAndVisible] ;
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
