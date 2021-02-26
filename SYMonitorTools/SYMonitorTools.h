//
//  SYMonitorTools.h
//  DemoMonitor
//
//  Created by zhangshaoyu on 2021/2/24.
//  Copyright © 2021 Herman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYMonitorDefine.h"
#import "SYMonitorFile.h"
#import "SYMonitorCrash.h"
#import "SYMonitorServe.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^SYMonitorReadHandle)(NSArray <SYMonitorModel *>*array);

#pragma mark - 配置

@interface SYMonitorConfig : NSObject

/// 开启功能
@property (nonatomic, assign) BOOL enable;

@end

#pragma mark - 管理

@interface SYMonitorTools : NSObject

+ (instancetype)share;

/// 配置
@property (nonatomic, strong) SYMonitorConfig *config;

#pragma mark 记录

void SYMonitorSave(SYMonitorType type, NSString *title, NSString *text);
void SYMonitorRead(SYMonitorReadHandle handle);

#pragma mark 服务

/// 上传记录
- (void)monitorSend;

/// 获取上传log日志
- (void)monitorReadWithPage:(NSInteger)page size:(NSInteger)size complete:(void (^)(NSArray <SYServerModel *>*array, NSError *error))complete;

@end

NS_ASSUME_NONNULL_END
