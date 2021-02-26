//
//  AppDelegate.m
//  DemoMonitor
//
//  Created by Herman on 2021/2/23.
//  Copyright © 2021 Herman. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "SYMonitorTools.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    ViewController *rootVC = [[ViewController alloc] init];
    UINavigationController *rootNav = [[UINavigationController alloc] initWithRootViewController:rootVC];
    //
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = rootNav;
    self.window.backgroundColor = UIColor.whiteColor;
    [self.window makeKeyAndVisible];
    
    SYMonitorConfig *config = [SYMonitorConfig new];
    config.enable = YES;
    SYMonitorTools.share.config = config;
    //
    [SYMonitorTools.share monitorSend];
    
    return YES;
}


@end
