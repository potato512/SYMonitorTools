//
//  SYMonitorSQLite.h
//  DemoMonitor
//
//  Created by zhangshaoyu on 2021/2/24.
//  Copyright © 2021 Herman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYMonitorDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface SYMonitorSQLite : NSObject

/// 建表/删表/插入、更新、删除数据
- (BOOL)executeSQLite:(NSString *)sqlString;
/// 查询
- (NSArray *)selectSQLite:(NSString *)sqlString;

@end

NS_ASSUME_NONNULL_END
