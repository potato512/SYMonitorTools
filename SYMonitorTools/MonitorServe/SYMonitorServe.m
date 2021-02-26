//
//  SYMonitorServe.m
//  DemoMonitor
//
//  Created by zhangshaoyu on 2021/2/24.
//  Copyright © 2021 Herman. All rights reserved.
//

#import "SYMonitorServe.h"
//
#import "BmobSDK.framework/Headers/Bmob.h"

static NSString *const kAppKey = @"e9d47506a346a6f118c0d38346d7498b";

#pragma mark - 数据model

@implementation SYServerModel

- (NSString *)logDeviceTypeName
{
    NSString *text = @"未定义";
    switch (self.logDeviceType.integerValue) {
        case 1: text = @"iPhone"; break;
        case 2: text = @"Android"; break;
        default:
            break;
    }
    return text;
}

- (NSString *)logTypeName
{
    NSString *title = @"未知";
    switch (self.logType.integerValue) {
        case SYMonitorTypeCrash: {
            title = @"崩溃";
        } break;
        case SYMonitorTypeCPU: {
            title = @"CPU";
        } break;
        case SYMonitorTypeMemory: {
            title = @"内存";
        } break;
        case SYMonitorTypeScrolling: {
            title = @"卡顿";
        } break;
        case SYMonitorTypeEnergy: {
            title = @"耗电";
        } break;
        case SYMonitorTypeNetwork: {
            title = @"流量";
        } break;
        case SYMonitorTypeLaunchTime: {
            title = @"启动";
        } break;
        default: break;
    }
    return title;
}

- (NSString *)logStateName
{
    // （1未修改，2已修复）
    NSString *title = @"未修改";
    if (self.logState.integerValue == 2) {
        title = @"已修复";
    }
    return title;
}

@end

#pragma mark - 数据服务

@interface SYMonitorServe ()

@property (nonatomic, strong) NSString *serveTable;

@end

@implementation SYMonitorServe

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

NSString *logValidText(NSString *text)
{
    if ([text isKindOfClass:NSString.class] && text.length > 0) {
        return text;
    }
    return @"--";
}

- (NSString *)serveTable
{
    if (_serveTable == nil) {
        NSArray *array = [kMonitorAppIdentifier componentsSeparatedByString:@"."];
        NSMutableString *text = [[NSMutableString alloc] init];
        for (NSString *string in array) {
            NSString *tmp = string.capitalizedString;
            [text appendString:tmp];
        }
        [text appendString:@"Table"];
        if (text.length > 20) {
            text = (NSMutableString *)[text substringFromIndex:(text.length - 20)];
        }
        _serveTable = [NSString stringWithString:text];
    }
    return _serveTable;
}

/// 初始化
- (void)serveInitialize
{
    [Bmob registerWithAppKey:kAppKey];
}

/// 保存数据
- (void)serveSaveWithModel:(SYServerModel *)model complete:(void (^)(BOOL isSuccessful, NSError *error))complete
{
    if (model == nil) {
        if (complete) {
            complete(NO, nil);
        }
        return;
    }
    
    // 在 包名_table 创建一条数据，如果当前没 AppCrashTable 表，则会创建 包名_table 表
    BmobObject *crashObject = [BmobObject objectWithClassName:self.serveTable];
    // 保存信息
    NSString *logAppName = model.logAppName;
    NSString *logAppVersion = model.logAppVersion;
    NSString *logDeviceName = model.logDeviceName;
    NSString *logDeviceType = model.logDeviceType;
    NSString *logDeviceSystem = model.logDeviceSystem;
    NSString *logDeviceSystemV = model.logDeviceSystemV;
    NSString *logUploadTime = model.logUploadTime;
    NSString *logType = model.logType;
    NSString *logTime = model.logTime;
    NSString *logTitle = model.logTitle;
    NSString *logMessage = model.logMessage;
    //
    [crashObject setObject:logValidText(logAppName) forKey:@"logAppName"];
    [crashObject setObject:logValidText(logAppVersion) forKey:@"logAppVersion"];
    [crashObject setObject:logValidText(logDeviceType) forKey:@"logDeviceType"];
    [crashObject setObject:logValidText(logDeviceSystem) forKey:@"logDeviceSystem"];
    [crashObject setObject:logValidText(logDeviceSystemV) forKey:@"logDeviceSystemV"];
    [crashObject setObject:logValidText(logUploadTime) forKey:@"logUploadTime"];
    [crashObject setObject:logValidText(logMessage) forKey:@"logMessage"];
    [crashObject setObject:logValidText(logDeviceName) forKey:@"logDeviceName"];
    [crashObject setObject:logValidText(logType) forKey:@"logType"];
    [crashObject setObject:logValidText(logTime) forKey:@"logTime"];
    [crashObject setObject:logValidText(logTitle) forKey:@"logTitle"];
    [crashObject setObject:logValidText(@"") forKey:@"logMark"];
    [crashObject setObject:logValidText(@"1") forKey:@"logState"];
    
    // 异步保存到服务器
    [crashObject saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (complete) {
            complete(isSuccessful, error);
        }
    }];
}

/// 修改数据（更新备注）
- (void)serveUpdateWithModel:(SYServerModel *)model complete:(void (^)(BOOL isSuccessful, NSError *error))complete
{
    if (model == nil) {
        if (complete) {
            complete(NO, nil);
        }
        return;
    }
   
    // 查找 包名_table 表
    BmobQuery *bquery = [BmobQuery queryWithClassName:self.serveTable];
    // 查找 包名_table 表里面id为 model.logID 的数据
    [bquery getObjectInBackgroundWithId:model.logID block:^(BmobObject *object, NSError *error){
      // 没有返回错误
      if (!error) {
          // 对象存在
          if (object) {
              BmobObject *result = [BmobObject objectWithoutDataWithClassName:object.className objectId:object.objectId];
              // 设置备注
              NSString *logMark = model.logMark;
              NSString *logState = model.logState;
              [result setObject:logMark forKey:@"logMark"];
              [result setObject:logState forKey:@"logState"];
              // 异步更新数据
              [result updateInBackgroundWithResultBlock:complete];
          }
      } else {
          // 进行错误处理
          if (complete) {
              complete(NO, error);
          }
      }
    }];
}

/// 获取数据
- (void)serveReadWithPage:(NSInteger)page size:(NSInteger)size complete:(void (^)(NSArray <SYServerModel *>*array, NSError *error))complete
{
    // 查找 包名_table 表的数据
    BmobQuery *cacheBquery = [BmobQuery queryWithClassName:self.serveTable];
    // 分页查询
    cacheBquery.limit = size;
    cacheBquery.skip = ((page - 1) * size);
    // 异步查找
    [cacheBquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (complete) {
            NSMutableArray *list = [[NSMutableArray alloc] init];
            for (BmobObject *object in array) {
                NSString *logAppName = [object objectForKey:@"logAppName"];
                NSString *logAppVersion = [object objectForKey:@"logAppVersion"];
                NSString *logDeviceName = [object objectForKey:@"logDeviceName"];
                NSString *logDeviceType = [object objectForKey:@"logDeviceType"];
                NSString *logDeviceSystem = [object objectForKey:@"logDeviceSystem"];
                NSString *logDeviceSystemV = [object objectForKey:@"logDeviceSystemV"];
                NSString *logUploadTime = [object objectForKey:@"logUploadTime"];
                NSString *logMessage = [object objectForKey:@"logMessage"];
                NSString *logType = [object objectForKey:@"logType"];
                NSString *logTime = [object objectForKey:@"logTime"];
                NSString *logTitle = [object objectForKey:@"logTitle"];
                NSString *logID = [object objectForKey:@"objectId"];
                NSString *logMark = [object objectForKey:@"logMark"];
                NSString *logState = [object objectForKey:@"logState"];
                //
                SYServerModel *model = [[SYServerModel alloc] init];
                model.logType = logType;
                model.logAppName = logAppName;
                model.logAppVersion = logAppVersion;
                model.logDeviceName = logDeviceName;
                model.logDeviceType = logDeviceType;
                model.logDeviceSystem = logDeviceSystem;
                model.logDeviceSystemV = logDeviceSystemV;
                model.logUploadTime = logUploadTime;
                model.logMessage = logMessage;
                model.logTime = logTime;
                model.logTitle = logTitle;
                model.logID = logID;
                model.logMark = logMark;
                model.logState = logState;
                //
                [list addObject:model];
            }
            complete(list, error);
        }
    }];
}

@end
