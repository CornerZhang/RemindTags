//
//  NXAppDelegate.m
//  RemindTags
//
//  Created by CornerZhang on 12/5/14.
//  Copyright (c) 2014 NeXtreme.com. All rights reserved.
//

#import "NXAppDelegate.h"
#import "NXRemindCenter.h"
#import "NXMusicItem.h"

@interface NXAppDelegate ()

@end

static NXAppDelegate* only = nil;

@implementation NXAppDelegate

+ (instancetype) sharedInstance {
    @synchronized(self) {
        if (only==nil) {
            only = [[NXAppDelegate alloc] init];
        }
    }
    return only;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if (only == nil) {
        only = self;
    }
    
    NXRemindCenter* remindCenter = [NXRemindCenter sharedInstance];
    [remindCenter initForNotificaions:application withAppDelegate:self withOptions:launchOptions];
    
    [NXMusicItem buildLibrayItems];

//    NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;

    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    NSString *itemName = notification.userInfo[kRemindItemNameKey];
    
    if ([itemName length] > 0){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Handling the local notification"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        if (application.applicationIconBadgeNumber>0) {
            application.applicationIconBadgeNumber -= 1;
        }
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[NXRemindCenter sharedInstance] saveContext];

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [[NXRemindCenter sharedInstance] saveContext];
    
    [[NXRemindCenter sharedInstance] cancelAllItems];
}

@end
