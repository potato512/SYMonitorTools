//
//  SYMonitorFile.h
//  DemoMonitor
//
//  Created by zhangshaoyu on 2021/2/24.
//  Copyright © 2021 Herman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SYMonitorDefine.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 数据模型

@interface SYMonitorModel : NSObject

@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong, readonly) NSString *typeName;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
//
@property (nonatomic, assign) CGFloat height;

- (instancetype)initWithContent:(NSString *)text title:(NSString *)key type:(NSInteger)type;

@end

#pragma mark - 文件管理

@interface SYMonitorFile : NSObject

- (void)saveWithType:(SYMonitorType)type title:(NSString *)title content:(NSString *)content;

- (void)read:(void (^)(NSArray <SYMonitorModel *> *array))complete;
- (void)clear;
/// 条件删除（key = model.time）
- (void)clearWithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
