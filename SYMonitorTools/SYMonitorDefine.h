//
//  SYMonitorDefine.h
//  DemoMonitor
//
//  Created by zhangshaoyu on 2021/2/24.
//  Copyright © 2021 Herman. All rights reserved.
//

#ifndef SYMonitorDefine_h
#define SYMonitorDefine_h

#import <UIKit/UIKit.h>

/// 监控类型
typedef NS_ENUM(NSInteger, SYMonitorType) {
    /// 监控类型 崩溃
    SYMonitorTypeCrash,
    /// 监控类型 卡顿
    SYMonitorTypeScrolling,
    /// 监控类型 CPU
    SYMonitorTypeCPU,
    /// 监控类型 Memory
    SYMonitorTypeMemory,
    /// 监控类型 电量
    SYMonitorTypeEnergy,
    /// 监控类型 流量
    SYMonitorTypeNetwork,
    /// 监控类型 启动时间
    SYMonitorTypeLaunchTime
};


/// 屏幕宽
#define kMonitorScreenWidth UIScreen.mainScreen.bounds.size.width
/// 屏幕高
#define kMonitorScreenHeight UIScreen.mainScreen.bounds.size.height
/// 间隔
#define kMonitorScreenOrigin 10

/// 设备信息 类型
#define kMonitorDeviceModel UIDevice.currentDevice.model
/// 设备信息 系统
#define kMonitorDeviceSystem UIDevice.currentDevice.systemName
/// 设备信息 系统版本
#define kMonitorDeviceVersion UIDevice.currentDevice.systemVersion
/// 设备信息 设备名称
#define kMonitorDeviceName UIDevice.currentDevice.name
/// 设备信息 电池状态
#define kMonitorDeviceBatteryState {if (UIDevice.currentDevice.batteryState == UIDeviceBatteryStateUnknown) { return @"UIDeviceBatteryStateUnknown"; } else if (UIDevice.currentDevice.batteryState == UIDeviceBatteryStateUnplugged) { return @"UIDeviceBatteryStateUnplugged"; } else if (UIDevice.currentDevice.batteryState == UIDeviceBatteryStateCharging) { return @"UIDeviceBatteryStateCharging"; } else if (UIDevice.currentDevice.batteryState == UIDeviceBatteryStateFull) { return @"UIDeviceBatteryStateFull"; } else { return @"未知";}}
/// 设备信息 电池电量
#define kMonitorDeviceBatteryLevel UIDevice.currentDevice.batteryLevel

/// 应用信息 标识
#define kMonitorAppIdentifier [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleIdentifier"]
/// 应用信息 名称
#define kMonitorAppName [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleDisplayName"]
/// 应用信息 版本
#define kMonitorAppVersion [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"]

/// 存储数据库
#define kMonitorDBName [NSString stringWithFormat:@"monitor_%@_db.db", [NSString stringWithFormat:@"%@", [kMonitorAppIdentifier stringByReplacingOccurrencesOfString:@"." withString:@""].uppercaseString]]
/// 存储表
#define kMonitorTableName [NSString stringWithFormat:@"monitor_%@_table", [NSString stringWithFormat:@"%@", [kMonitorAppIdentifier stringByReplacingOccurrencesOfString:@"." withString:@""].uppercaseString]]

#endif /* SYMonitorDefine_h */
