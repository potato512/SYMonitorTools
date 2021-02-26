//
//  SYMonitorTools.m
//  DemoMonitor
//
//  Created by zhangshaoyu on 2021/2/24.
//  Copyright © 2021 Herman. All rights reserved.
//

#import "SYMonitorTools.h"

#pragma mark - 配置

@implementation SYMonitorConfig

@end

#pragma mark - 管理

@interface SYMonitorTools ()

@property (nonatomic, strong) SYMonitorFile *monitorFile;
@property (nonatomic, strong) SYMonitorCrash *monitorCrash;
@property (nonatomic, strong) SYMonitorServe *monitorServe;

@end

@implementation SYMonitorTools

+ (instancetype)share
{
    static SYMonitorTools *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)setConfig:(SYMonitorConfig *)config
{
    _config = config;
    //
    if (!_config.enable) {
        return;
    }
    
    [self.monitorCrash catchCrash];
    [self.monitorServe serveInitialize];
}

#pragma mark 文件管理

- (SYMonitorFile *)monitorFile
{
    if (_monitorFile == nil) {
        _monitorFile = [[SYMonitorFile alloc] init];
    }
    return _monitorFile;
}

- (void)save:(SYMonitorType)type title:(NSString *)title content:(NSString *)content
{
    if (!self.config.enable) {
        return;
    }
    
    [self.monitorFile saveWithType:type title:title content:content];
}
- (void)read:(void (^)(NSArray *array))complete
{
    if (!self.config.enable) {
        if (complete) {
            complete(nil);
        }
        return;
    }
    
    [self.monitorFile read:complete];
}

#pragma mark 闪退

- (SYMonitorCrash *)monitorCrash
{
    if (_monitorCrash == nil) {
        _monitorCrash = [[SYMonitorCrash alloc] init];
    }
    return _monitorCrash;
}

#pragma mark 记录

void SYMonitorSave(SYMonitorType type, NSString *title, NSString *text)
{
    [SYMonitorTools.share save:type title:title content:text];
}

void SYMonitorRead(SYMonitorReadHandle handle)
{
    [SYMonitorTools.share read:^(NSArray<SYMonitorModel *> * _Nonnull array) {
        if (handle) {
            handle(array);
        }
    }];
}

#pragma mark 服务管理

- (SYMonitorServe *)monitorServe
{
    if (_monitorServe == nil) {
        _monitorServe = [[SYMonitorServe alloc] init];
    }
    return _monitorServe;
}

- (void)monitorSend
{
    if (!SYMonitorTools.share.config.enable) {
        return;
    }
    
    // 上传 应用名称
    NSString *logAppName = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleDisplayName"];
    // 上传 应用版本
    NSString *logAppVersion = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"];
    // 上传 日志时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy年MM月dd日 HH:mm";
    NSString *logTime = [formatter stringFromDate:NSDate.date];
    // 上传 设备类型（1 iPhone，2 Android）
    NSString *logDeviceType = @"1";
    // 上传 设备系统（iOS，Android）
    NSString *logDeviceSystem = UIDevice.currentDevice.systemName;
    // 上传 设备系统版本，如：iOS14
    NSString *logDeviceSystemV = UIDevice.currentDevice.systemVersion;
    // 上传 设备名称
    NSString *logDeviceName = UIDevice.currentDevice.name;
    // 上传 日志信息
    __weak SYMonitorTools *weak = self;
    [self.monitorFile read:^(NSArray<SYMonitorModel *> * _Nonnull array) {
        NSLog(@"日志上传：%@", array.count <= 0 ? @"没有记录" : [NSString stringWithFormat:@"有 %ld 条记录", array.count]);
        //
        for (SYMonitorModel *modelCache in array) {
            NSString *type = [NSString stringWithFormat:@"%ld", modelCache.type];
            NSString *title = modelCache.title;
            NSString *time = modelCache.time;
            NSString *content = modelCache.content;
            //
            SYServerModel *model = [[SYServerModel alloc] init];
            model.logAppName = logAppName;
            model.logAppVersion = logAppVersion;
            model.logUploadTime = logTime;
            model.logDeviceType = logDeviceType;
            model.logDeviceSystem = logDeviceSystem;
            model.logDeviceSystemV = logDeviceSystemV;
            model.logDeviceName = logDeviceName;
            model.logType = type;
            model.logTime = time;
            model.logTitle = title;
            model.logMessage = content;
            //
            [weak.monitorServe serveSaveWithModel:model complete:^(BOOL isSuccessful, NSError * _Nonnull error) {
                if (isSuccessful) {
                    [weak.monitorFile clearWithKey:time];
                }
                NSLog(@"crash日志上传：%@（error = %@）", (isSuccessful ? @"成功" : @"失败"), error);
            }];
        }
    }];
}

/// 获取上传log日志
- (void)monitorReadWithPage:(NSInteger)page size:(NSInteger)size complete:(void (^)(NSArray <SYServerModel *>*array, NSError *error))complete
{
    [self.monitorServe serveReadWithPage:page size:size complete:^(NSArray<SYServerModel *> * _Nonnull array, NSError * _Nonnull error) {
        NSLog(@"日志记录：%@", array.count <= 0 ? @"没有记录" : [NSString stringWithFormat:@"有 %ld 条记录", array.count]);
        if (complete) {
            complete(array, error);
        }
    }];
}

@end
