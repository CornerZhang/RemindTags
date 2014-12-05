//
//  NXAppDelegate.h
//  RemindTags
//
//  Created by CornerZhang on 12/5/14.
//  Copyright (c) 2014 NeXtreme.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NXAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (instancetype)	sharedInstance;

- (void)            application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;

@end

