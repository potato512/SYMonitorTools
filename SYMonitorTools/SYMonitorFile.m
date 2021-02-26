//
//  SYMonitorFile.m
//  DemoMonitor
//
//  Created by zhangshaoyu on 2021/2/24.
//  Copyright © 2021 Herman. All rights reserved.
//

#import "SYMonitorFile.h"
#import "SYMonitorSQLite.h"
#import <pthread/pthread.h>

#pragma mark - 数据模型

@interface SYMonitorModel ()

@end

@implementation SYMonitorModel

- (instancetype)initWithContent:(NSString *)text title:(NSString *)key type:(NSInteger)type
{
    self = [super init];
    if (self) {
        self.type = type;
        self.content = text;
        self.title = ([key isKindOfClass:NSString.class] && (key.length > 0)) ? key : @"";
        //
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        NSString *time = [formatter stringFromDate:NSDate.date];
        self.time = time;
        //
        CGFloat height = [SYMonitorModel heightWithText:text];
        self.height = height;
    }
    return self;
}

/// 内部使用
+ (SYMonitorModel *)modelWithType:(NSInteger)type title:(NSString *)title content:(NSString *)content time:(NSString *)time
{
    SYMonitorModel *model = [SYMonitorModel new];
    model.type = type;
    model.title = title;
    model.content = content;
    model.time = time;
    CGFloat height = [SYMonitorModel heightWithText:content];
    model.height = height;
    return model;
}

+ (CGFloat)heightWithText:(NSString *)text
{
    CGFloat heightText = 50;
    CGFloat widthText = (kMonitorScreenWidth - kMonitorScreenOrigin * 2);
    //
    CGFloat heigt = heightText;
    if (text && [text isKindOfClass:NSString.class] && text.length > 0) {
        if (7.0 <= [UIDevice currentDevice].systemVersion.floatValue) {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:15], NSParagraphStyleAttributeName:paragraphStyle.copy};
            
            CGSize size = [text boundingRectWithSize:CGSizeMake(widthText, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
            CGFloat heightTmp = size.height;
            heightTmp += 25;
            if (heightTmp < heightText) {
                heightTmp = heightText;
            }
            heigt = heightTmp;
        }
    }
    return heigt;
}

- (NSString *)typeName
{
    NSString *title = @"未知";
    switch (self.type) {
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

@end

#pragma mark - 文件管理

@interface SYMonitorFile () {
    pthread_mutex_t mutexLock;
}

@property (nonatomic, strong) SYMonitorSQLite *sqlite;

@end

@implementation SYMonitorFile

- (instancetype)init
{
    self = [super init];
    if (self) {
        pthread_mutex_init(&mutexLock, NULL);
        
        [self initializeSQLiteTable];
    }
    return self;
}

- (void)dealloc
{
    pthread_mutex_destroy(&mutexLock);
}

- (void)saveWithType:(SYMonitorType)type title:(NSString *)title content:(NSString *)content
{
    pthread_mutex_lock(&mutexLock);
    //
    SYMonitorModel *model = [[SYMonitorModel alloc] initWithContent:content title:title type:type];
    [self saveLog:model];
    //
    pthread_mutex_unlock(&mutexLock);
}

- (void)read:(void (^)(NSArray <SYMonitorModel *> *array))complete
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        pthread_mutex_lock(&self->mutexLock);
        NSArray *array = [self readLog];
        //
        NSMutableArray *list = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in array) {
            NSString *type = dict[@"type"];
            NSString *time = dict[@"time"];
            NSString *title = dict[@"title"];
            NSString *content = dict[@"content"];
            SYMonitorModel *model = [SYMonitorModel modelWithType:type.integerValue title:title content:content time:time];
            [list addObject:model];
        }
        pthread_mutex_unlock(&self->mutexLock);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(list);
            }
        });
    });
}

- (void)clear
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        pthread_mutex_lock(&self->mutexLock);
        [self deleteLog];
        pthread_mutex_unlock(&self->mutexLock);
    });
}
/// 条件删除（key = model.time）
- (void)clearWithKey:(NSString *)key
{
    if (key == nil || ([key isKindOfClass:NSString.class] && key.length <= 0)) {
        return;
    }
    pthread_mutex_lock(&mutexLock);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self deleteLogWithKey:key];
    });
    pthread_mutex_unlock(&mutexLock);
}

#pragma mark 存储

- (SYMonitorSQLite *)sqlite
{
    if (_sqlite == nil) {
        _sqlite = [[SYMonitorSQLite alloc] init];
    }
    return _sqlite;
}

- (void)initializeSQLiteTable
{
    // ID, type, time, title, content
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(ID INT TEXTPRIMARY KEY, type TEXT, time TEXT, title TEXT, content TEXT NO NULL)", kMonitorTableName];
    [self.sqlite executeSQLite:sql];
}

- (void)saveLog:(SYMonitorModel *)model
{
    if (model == nil) {
        NSLog(@"没有数据");
        return;
    }
    
    // ID, type, time, title, content
    NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (ID, type, time, title, content) VALUES (NULL, '%@', '%@', '%@', '%@')", kMonitorTableName, [NSString stringWithFormat:@"%ld", model.type], model.time, model.title, model.content];
    [self.sqlite executeSQLite:sql];
}

- (void)deleteLog
{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", kMonitorTableName];
    [self.sqlite executeSQLite:sql];
}
- (void)deleteLogWithKey:(NSString *)key
{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE time = '%@'", kMonitorTableName, key];
    [self.sqlite executeSQLite:sql];
}

- (NSArray *)readLog
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", kMonitorTableName];
    NSArray *array = [self.sqlite selectSQLite:sql];
    return array;
}

@end
