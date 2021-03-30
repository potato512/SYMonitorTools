//
//  SYMonitorCrash.m
//  DemoMonitor
//
//  Created by zhangshaoyu on 2021/2/24.
//  Copyright © 2021 Herman. All rights reserved.
//

#import "SYMonitorCrash.h"
#import "SYMonitorTools.h"
#include <execinfo.h>

@implementation SYMonitorCrash

#pragma mark - Unix信号

// 信息注册
void RegisterSignalHandler(void)
{
    /*
    SIGABRT–程序中止命令中止信号
    SIGALRM–程序超时信号
    SIGFPE–程序浮点异常信号
    SIGILL–程序非法指令信号
    SIGHUP–程序终端中止信号
    SIGINT–程序键盘中断信号
    SIGKILL–程序结束接收中止信号
    SIGTERM–程序kill中止信号
    SIGSTOP–程序键盘中止信号
    SIGSEGV–程序无效内存中止信号
    SIGBUS–程序内存字节未对齐中止信号
    SIGPIPE–程序Socket发送失败中止信号
    */
    
    signal(SIGABRT, HandleSignalException);
    signal(SIGALRM, HandleSignalException);
    signal(SIGFPE, HandleSignalException);
    signal(SIGILL, HandleSignalException);
    signal(SIGHUP, HandleSignalException);
    signal(SIGINT, HandleSignalException);
    signal(SIGKILL, HandleSignalException);
    signal(SIGTERM, HandleSignalException);
    signal(SIGSTOP, HandleSignalException);
    signal(SIGSEGV, HandleSignalException);
    signal(SIGBUS, HandleSignalException);
    signal(SIGPIPE, HandleSignalException);
}

// #include <execinfo.h>
void HandleSignalException(int signal)
{
    //
    NSMutableString *errorSymbol = [[NSMutableString alloc] initWithString:@"异常描述："];
    void *callstack[128];
    int i, frames = backtrace(callstack, 128);
    char** traceChar = backtrace_symbols(callstack, frames);
    for (i = 0; i <frames; ++i) {
        [errorSymbol appendFormat:@"%s\n", traceChar[i]];
    }
    [errorSymbol appendString:@"\n"];
    //
    NSArray *list = SYMonitorCrash.crashAppInfos;
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:list];
    NSMutableString *crashString = [[NSMutableString alloc] init];
    for (NSString *string in array) {
        [crashString appendString:string];
        [crashString appendString:@"\n"];
    }
    [crashString appendFormat:@"%@\n", errorSymbol];
    //
    NSString *errorReason = [NSString stringWithFormat:@"信号signal（%d）: %@", signal, singleTitle(signal)];
    SYMonitorSave(SYMonitorTypeCrash, errorReason, crashString);
}

NSString *singleTitle(int signal)
{
    NSString *title = @"--";
    switch (signal) {
        case SIGABRT: {
            title = @"SIGABRT 程序中止命令中止信号";
        } break;
        case SIGALRM: {
            title = @"SIGALRM 程序超时信号";
        } break;
        case SIGFPE: {
            title = @"SIGFPE 程序浮点异常信号";
        } break;
        case SIGILL: {
            title = @"SIGILL 程序非法指令信号";
        } break;
        case SIGHUP: {
            title = @"SIGHUP 程序终端中止信号";
        } break;
        case SIGINT: {
            title = @"SIGINT 程序键盘中断信号";
        } break;
        case SIGKILL: {
            title = @"SIGKILL 程序结束接收中止信号";
        } break;
        case SIGTERM: {
            title = @"SIGTERM 程序kill中止信号";
        } break;
        case SIGSTOP: {
            title = @"SIGSTOP 程序键盘中止信号";
        } break;
        case SIGSEGV: {
            title = @"SIGSEGV 程序无效内存中止信号";
        } break;
        case SIGBUS: {
            title = @"SIGBUS 程序内存字节未对齐中止信号";
        } break;
        case SIGPIPE: {
            title = @"SIGPIPE 程序Socket发送失败中止信号";
        } break;
        default:
            break;
    }
    return title;
}

#pragma mark - Mach异常

// 获得异常的C函数
void readMonitorCrashException(NSException *exception)
{
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
    NSArray *list = SYMonitorCrash.crashAppInfos;
    NSArray *listTmp = @[errorName, errorReason, errorUser, errorAddress, errorSymbol];
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:list];
    [array addObjectsFromArray:listTmp];
    NSMutableString *crashString = [[NSMutableString alloc] init];
    for (NSString *string in array) {
        [crashString appendString:string];
        [crashString appendString:@"\n"];
    }
    //
    SYMonitorSave(SYMonitorTypeCrash, errorReason, crashString);
}

#pragma mark -
 
+ (NSArray *)crashAppInfos
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
    //
    NSArray *array = @[appID, appName, appVersion, deviceModel, deviceSystem, deviceVersion, deviceName, deviceBatteryState, deviceBatteryLevel];
    return array;
}

void SYMonitorCrashInitialize(void)
{
    RegisterSignalHandler();
    NSSetUncaughtExceptionHandler(&readMonitorCrashException);
}

@end
