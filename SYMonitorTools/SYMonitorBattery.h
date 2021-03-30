//
//  SYMonitorBattery.h
//  DemoMonitor
//
//  Created by zhangshaoyu on 2021/3/3.
//  Copyright © 2021 Herman. All rights reserved.
//  耗电量检测

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYMonitorBattery : NSObject

@property (nonatomic, assign) NSInteger monitorBattery;

@end

NS_ASSUME_NONNULL_END

/*
 影响 iOS 电量的因素，几个典型的耗电场景如下：
 1、定位，尤其是调用GPS定位
 2、网络传输，尤其是非Wifi环境
 3、cpu频率
 4、内存调度频度
 5、后台运行
 
 */
