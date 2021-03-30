//
//  SYMonitorServe.h
//  DemoMonitor
//
//  Created by zhangshaoyu on 2021/2/24.
//  Copyright © 2021 Herman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYMonitorDefine.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 数据model

@interface SYServerModel : NSObject

/// 应用名称
@property (nonatomic, strong) NSString *logAppName;
/// 应用版本
@property (nonatomic, strong) NSString *logAppVersion;
/// 应用设备类型（1 iPhone，2 Android）
@property (nonatomic, strong) NSString *logDeviceType;
/// 应用设备系统（iOS，Android）
@property (nonatomic, strong) NSString *logDeviceSystem;
/// 应用设备系统版本，iOS14
@property (nonatomic, strong) NSString *logDeviceSystemV;
/// 应用设备名称
@property (nonatomic, strong) NSString *logDeviceName;

/// 上传时间
@property (nonatomic, strong) NSString *logUploadTime;
/// 上传发生类型 SYMonitorType
@property (nonatomic, strong) NSString *logType;
@property (nonatomic, strong, readonly) NSString *logTypeName;
/// 上传发生时间
@property (nonatomic, strong) NSString *logTime;
/// 上传标题
@property (nonatomic, strong) NSString *logTitle;
/// 上传内容
@property (nonatomic, strong) NSString *logMessage;
/// 状态（1未修改，2已修复）
@property (nonatomic, strong) NSString *logState;
@property (nonatomic, strong, readonly) NSString *logStateName;
/// 备注
@property (nonatomic, strong) NSString *logMark;

/// 自定义 应用设备类型（1 iPhone，2 Android）
@property (nonatomic, strong, readonly) NSString *logDeviceTypeName;
/// 自定义 系统id
@property (nonatomic, strong) NSString *logID;


@end

#pragma mark - 数据服务

@interface SYMonitorServe : NSObject

+ (instancetype)share;
- (instancetype)init;

@property (nonatomic, strong) NSString *crashTable;
@property (nonatomic, strong) NSString *logTable;

#pragma mark 数据处理

/// 保存数据（表名）
- (void)serveSaveWithModel:(SYServerModel *)model table:(NSString *)tableName complete:(void (^)(BOOL isSuccessful, NSError *error))complete;

/// 修改数据（更新备注，表名）
- (void)serveUpdateWithModel:(SYServerModel *)model table:(NSString *)tableName complete:(void (^)(BOOL isSuccessful, NSError *error))complete;
/// 获取数据（表名）
- (void)serveReadWithPage:(NSInteger)page size:(NSInteger)size table:(NSString *)tableName  complete:(void (^)(NSArray <SYServerModel *>*array, NSError *error))complete;
/// 删除数据（表名）
- (void)serveDeleteWith:(SYServerModel *)model table:(NSString *)tableName complete:(void (^)(BOOL isSuccessful, NSError *error))complete;

#pragma mark 文件管理

/// 保存文件（表名）
- (void)serveSaveWithFilePath:(NSString *)filePath table:(NSString *)tableName progress:(void (^)(int index, float progress))uploadProgress complete:(void (^)(BOOL isSuccessful, NSError *error))complete;

/// 获取文件（表名）
- (void)serveReadFileWithModel:(SYServerModel *)model table:(NSString *)tableName complete:(void (^)(id file, NSError *error))complete;

/// 删除文件
- (void)serveDeleteFileWithModel:(SYServerModel *)model table:(NSString *)tableName complete:(void (^)(BOOL isSuccessful, NSError *error))complete;

@end

NS_ASSUME_NONNULL_END

/*
 1)将BmobSDK引入项目:

 在你的XCode项目工程中，添加BmobSDK.framework

 2)添加使用的系统framework:

 在你的XCode工程中Project ->TARGETS -> Build Phases->Link Binary With Libraries引入
 2.1)CoreLocation.framework
 2.2)Security.framework
 2.3)CoreGraphics.framework
 2.4)MobileCoreServices.framework
 2.5)CFNetwork.framework
 2.6)CoreTelephony.framework
 2.7)SystemConfiguration.framework
 2.8)libz.1.2.5.tbd
 2.9)libicucore.tbd
 2.10)libsqlite3.tbd
 2.11)libc++.tbd
 2.12)photos.framework
 
 */
