//
//  SYMonitorCrash.m
//  DemoMonitor
//
//  Created by zhangshaoyu on 2021/2/24.
//  Copyright © 2021 Herman. All rights reserved.
//

#import "SYMonitorCrash.h"
#import "SYMonitorTools.h"

@implementation SYMonitorCrash

- (void)catchCrash
{
    NSSetUncaughtExceptionHandler(&readException);
}

// 获得异常的C函数
void readException(NSException *exception)
{
    // 设备信息
    NSString *deviceModel = kMonitorDeviceModel;
    NSString *deviceSystem = kMonitorDeviceSystem;
    NSString *deviceVersion = kMonitorDeviceVersion;
    NSString *deviceName = kMonitorDeviceName;
    NSString *deviceBatteryState = @"";// kMonitorDeviceBatteryState;
    NSString *deviceBatteryLevel = [NSString stringWithFormat:@"%f", kMonitorDeviceBatteryLevel];
    // 应用信息
    NSString *appID = kMonitorAppIdentifier;
    NSString *appName = kMonitorAppName;
    NSString *appVersion = kMonitorAppVersion;
    // 异常信息
    NSString *errorName = [NSString stringWithFormat:@"异常名称：%@", exception.name];
    NSString *errorReason = [NSString stringWithFormat:@"异常原因：%@",exception.reason];
    NSString *errorUser = [NSString stringWithFormat:@"用户信息：%@",exception.userInfo];
    NSString *errorAddress = [NSString stringWithFormat:@"栈内存地址：%@",exception.callStackReturnAddresses];
    NSArray *symbols = exception.callStackSymbols;
    NSMutableString *errorSymbol = [[NSMutableString alloc] initWithString:@"异常描述："];
    for (NSString *item in symbols) {
        [errorSymbol appendString:@"\n"];
        [errorSymbol appendString:item];
    }
    [errorSymbol appendString:@"\n"];
    //
    NSArray *array = @[appID, appName, appVersion, deviceModel, deviceSystem, deviceVersion, deviceName, deviceBatteryState, deviceBatteryLevel, errorName, errorReason, errorUser, errorAddress, errorSymbol];
    NSMutableString *crashString = [[NSMutableString alloc] init];
    for (NSString *string in array) {
        [crashString appendString:string];
        [crashString appendString:@"\n"];
    }
    //
    SYMonitorSave(SYMonitorTypeCrash, errorReason, crashString);
}

@end
