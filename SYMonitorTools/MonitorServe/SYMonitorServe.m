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
static NSString *const kAppDomin = @"https://open-vip.bmob.cn";

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

@end

@implementation SYMonitorServe

+ (instancetype)share
{
    static SYMonitorServe *manager;
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
        [self serveInitialize];
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
- (NSString *)logTableName:(NSString *)defaultTable
{
    NSAssert(defaultTable != nil, @"表名不能为空，且小于20个字符");
    NSString *table = defaultTable;
    if (table == nil || table.length <= 0) {
        //
        return nil;
        
//        NSArray *array = [kMonitorAppIdentifier componentsSeparatedByString:@"."];
//        NSMutableString *text = [[NSMutableString alloc] init];
//        for (NSString *string in array) {
//            NSString *tmp = string.capitalizedString;
//            [text appendString:tmp];
//        }
//        [text appendString:@"Table"];
//        if (text.length > 20) {
//            text = (NSMutableString *)[text substringFromIndex:(text.length - 20)];
//        }
//        table = [NSString stringWithString:text];
    }
    return table;
}

/// 初始化
- (void)serveInitialize
{
    // SDK初始化
    [Bmob registerWithAppKey:kAppKey];
    // 数据SDK重新设置请求域名的Api
    [Bmob resetDomain:kAppDomin];
}

#pragma mark 数据处理

/// 保存数据（表名）
- (void)serveSaveWithModel:(SYServerModel *)model table:(NSString *)tableName complete:(void (^)(BOOL isSuccessful, NSError *error))complete
{
    if (model == nil) {
        if (complete) {
            complete(NO, nil);
        }
        return;
    }
    
    // 在 包名_table 创建一条数据，如果当前没 AppCrashTable 表，则会创建 包名_table 表
    NSString *table = [self logTableName:tableName];
    BmobObject *object = [BmobObject objectWithClassName:table];
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
    [object setObject:logValidText(logAppName) forKey:@"logAppName"];
    [object setObject:logValidText(logAppVersion) forKey:@"logAppVersion"];
    [object setObject:logValidText(logDeviceType) forKey:@"logDeviceType"];
    [object setObject:logValidText(logDeviceSystem) forKey:@"logDeviceSystem"];
    [object setObject:logValidText(logDeviceSystemV) forKey:@"logDeviceSystemV"];
    [object setObject:logValidText(logUploadTime) forKey:@"logUploadTime"];
    [object setObject:logValidText(logMessage) forKey:@"logMessage"];
    [object setObject:logValidText(logDeviceName) forKey:@"logDeviceName"];
    [object setObject:logValidText(logType) forKey:@"logType"];
    [object setObject:logValidText(logTime) forKey:@"logTime"];
    [object setObject:logValidText(logTitle) forKey:@"logTitle"];
    [object setObject:logValidText(@"") forKey:@"logMark"];
    [object setObject:logValidText(@"1") forKey:@"logState"];
    
    // 异步保存到服务器
    [object saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (complete) {
            complete(isSuccessful, error);
        }
    }];
}

/// 修改数据（更新备注，表名）
- (void)serveUpdateWithModel:(SYServerModel *)model table:(NSString *)tableName complete:(void (^)(BOOL isSuccessful, NSError *error))complete
{
    if (model == nil) {
        if (complete) {
            complete(NO, nil);
        }
        return;
    }
   
    // 查找 包名_table 表
    NSString *table = [self logTableName:tableName];
    BmobQuery *bquery = [BmobQuery queryWithClassName:table];
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
/// 获取数据（表名）
- (void)serveReadWithPage:(NSInteger)page size:(NSInteger)size table:(NSString *)tableName  complete:(void (^)(NSArray <SYServerModel *>*array, NSError *error))complete
{
    // 查找 包名_table 表的数据
    NSString *table = [self logTableName:tableName];
    BmobQuery *cacheBquery = [BmobQuery queryWithClassName:table];
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
/// 删除数据（表名）
- (void)serveDeleteWith:(SYServerModel *)model table:(NSString *)tableName complete:(void (^)(BOOL isSuccessful, NSError *error))complete
{
    
}

#pragma mark 文件管理

/// 保存文件（表名）
- (void)serveSaveWithFilePath:(NSString *)filePath table:(NSString *)tableName progress:(void (^)(int index, float progress))uploadProgress complete:(void (^)(BOOL isSuccessful, NSError *error))complete
{
    if (filePath == nil || filePath.length <= 0) {
        if (complete) {
            complete(NO, nil);
        }
        return;
    }
    
    NSArray *filePaths = @[filePath];
    [BmobFile filesUploadBatchWithPaths:filePaths progressBlock:^(int index, float progress) {
        if (uploadProgress) {
            uploadProgress(index, progress);
        }
    } resultBlock:^(NSArray *array, BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            // 存放文件URL的数组
            BmobFile *file = array.lastObject;
            NSString *fileUrlPath = file.url;
            //
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
            //
            SYServerModel *model = [[SYServerModel alloc] init];
            model.logAppName = logAppName;
            model.logAppVersion = logAppVersion;
            model.logUploadTime = logTime;
            model.logDeviceType = logDeviceType;
            model.logDeviceSystem = logDeviceSystem;
            model.logDeviceSystemV = logDeviceSystemV;
            model.logDeviceName = logDeviceName;
            model.logType = @"";
            model.logTime = @"";
            model.logTitle = [NSString stringWithFormat:@"操作日志"];
            model.logMessage = fileUrlPath;
            //
            [self serveSaveWithModel:model table:tableName complete:complete];
        } else {
            if (complete) {
                complete(isSuccessful, error);
            }
        }
    }];
}

/// 获取文件（表名）
- (void)serveReadFileWithModel:(SYServerModel *)model table:(NSString *)tableName complete:(void (^)(id file, NSError *error))complete
{
    if (model == nil) {
        if (complete) {
            complete(nil, nil);
        }
        return;
    }
    
    NSString *talbe = [self logTableName:tableName];
    NSString *fileId = model.logID;
    //
    BmobQuery *query = [BmobQuery queryWithClassName:talbe];
    [query getObjectInBackgroundWithId:fileId block:^(BmobObject *object, NSError *error) {
        if (complete) {
            BmobFile *file = (BmobFile *)[object objectForKey:@"filetype"];
            NSLog(@"%@",file.url);
            //
            complete(object, error);
        }
    }];
}

/// 删除文件
- (void)serveDeleteFileWithModel:(SYServerModel *)model table:(NSString *)tableName complete:(void (^)(BOOL isSuccessful, NSError *error))complete
{
    if (model == nil) {
        if (complete) {
            complete(nil, nil);
        }
        return;
    }
    
//    NSString *talbe = logTableName(tableName);
//    NSString *fileId = model.logID;
//    //
//    BmobObject *obj = [[BmobObject alloc] initWithClassName:talbe];
//    [obj deleteInBackgroundWithBlock:^(BOOL isSuccessful, NSError *error) {
//
//    }];
}

@end
