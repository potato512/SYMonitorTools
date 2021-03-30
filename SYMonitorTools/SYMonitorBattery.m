//
//  SYMonitorBattery.m
//  DemoMonitor
//
//  Created by zhangshaoyu on 2021/3/3.
//  Copyright © 2021 Herman. All rights reserved.
//

#import "SYMonitorBattery.h"
#import <UIKit/UIDevice.h>

@implementation SYMonitorBattery

- (NSInteger)monitorBattery
{
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    // UIDevice返回的batteryLevel的范围在0到1之间。
    NSUInteger level = device.batteryLevel * 100;
    return level;
}

@end
