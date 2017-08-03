//
//  SHSQLiteManager.m
//  G4Image
//
//  Created by LHY on 2017/4/11.
//  Copyright © 2017年 SmartHomeGroup. All rights reserved.
/*
 SQL语句使用注意:
    1.在执行DDL语句，由于我拉放在字符串中，可以不加''来包含字段名和表名，但使用了字符串的值虽然使用的拼接，但在SQL中还要在用''来包括
        所得出的字符串。
 */

#import "SHSQLiteManager.h"
#import "FileTools.h"

#import <FMDB.h>

@interface SHSQLiteManager ()

/**
 全局操作队列
 */
@property (nonatomic, strong) FMDatabaseQueue *queue;

@end

@implementation SHSQLiteManager

#pragma mark - 实际的操作

/// 删除已经存在按钮
- (void)deleteButton:(SHButton *)button {
    
    // 准备SQL
    NSString *sql = sql = [NSString stringWithFormat:@"DELETE FROM DeviceButtonForZone WHERE zoneID = %zd and buttonID = %zd",button.zoneID,button.buttonID];
    
    // 执行sql
    [self insetData:sql];
}

/// 将新创建的按钮保存在数据库中
- (void)inserNewButton:(SHButton *)button {
 
    NSString * sql = [NSString stringWithFormat:@"INSERT INTO DeviceButtonForZone (zoneID, buttonID, subnetID, deviceID, deviceType, buttonRectSaved, buttonPara1, buttonPara2, buttonPara3, buttonPara4, buttonPara5, buttonPara6) VALUES (%zd, %zd, %d, %d, %d, '%@', %d, %d, %d, %d, %d, %d);",  button.zoneID, button.buttonID, button.subNetID, button.deviceID, button.deviceType, NSStringFromCGRect(button.frame), button.buttonPara1, button.buttonPara2, button.buttonPara3, button.buttonPara4, button.buttonPara5, button.buttonPara6];
    
    // 执行SQL
    [self insetData:sql];
}

/// 获得最大的按钮ID
- (NSUInteger)getMaxButtonID {
    
    // 获得结果ID
    id resID = [[[self selectProprty:@"select max(buttonID) from DeviceButtonForZone"] lastObject] objectForKey:@"max(buttonID)"];
    return (resID == [NSNull null]) ? 0 : [resID integerValue];
}

/// 获得当前区域的所有按钮
- (NSMutableArray *)getAllButtonsForCurrentZone:(SHZone *)zone {
    
    NSString *selectSql = [NSString stringWithFormat:@"SELECT zoneID, buttonID, subnetID, deviceID, deviceType, buttonRectSaved, buttonPara1, buttonPara2, buttonPara3, buttonPara4, buttonPara5, buttonPara6 FROM DeviceButtonForZone WHERE zoneID = %zd;", zone.zoneID];
    
    NSMutableArray *resArr = [self selectProprty:selectSql];
    NSMutableArray *allButtons = [NSMutableArray arrayWithCapacity:resArr.count];
    
    for (NSDictionary *dict in resArr) {
        SHButton *button = [SHButton buttonWithDictionary:dict];
        [allButtons addObject:button];
    }
 
    return allButtons;
}

#pragma mark - 区域表格

/// 获得最大的区域ID
- (NSUInteger)getMaxZoneID {
    
    // 获得结果ID
    id resID = [[[self selectProprty:@"select max(zoneID) from zones"] lastObject] objectForKey:@"max(zoneID)"];
    return (resID == [NSNull null]) ? 0 : [resID integerValue];
}

/// 删除当前区域
- (void)deleteCurrntZone:(SHZone *)zone {

    // 删除区域
    NSString *deleteZoneSql = [NSString stringWithFormat:@"DELETE FROM zones WHERE zoneID = %zd;", zone.zoneID];
    
    [self insetData:deleteZoneSql];
    
    // 删除同一个区域中的所有按钮
    NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM DeviceButtonForZone WHERE zoneID = %zd;", zone.zoneID];
    
    [self insetData:deleteSql];
}


/// 判断一个区域是否存在
- (BOOL)isCurrentZoneExist:(SHZone *)zone {
    
    // 搜索这个区域存在
    NSMutableArray *allZones =  [self searchAllZones];
    for (SHZone *searchZone in allZones) {
        if (zone.zoneID == searchZone.zoneID) {
            return YES;
        }
    }
    return NO;
}

/// 更新区域信息
- (BOOL)updateZone:(SHZone *)zone {
    
    NSString *upSql = [NSString stringWithFormat:@"UPDATE zones SET imageScale = %g, zoneName = '%@' WHERE zoneID = %lu", zone.imageScale, zone.zoneName,(unsigned long)zone.zoneID];
   return [self insetData:upSql];
}

/// 保存一个新的区域 
- (BOOL)inserNewZone:(SHZone *)zone {
    
    // 搜索这个区域存在是否
    if ([self isCurrentZoneExist:zone]) {
        
        return [self updateZone:zone];
    }
   
    // 不存在新创建
    NSString *saveSql = [NSString stringWithFormat:@"INSERT  INTO zones (zoneID, zoneName, imageScale) VALUES (%zd, '%@', %g);", zone.zoneID, zone.zoneName, zone.imageScale];
    
    return [self insetData:saveSql];
}

/// 存储当前的区域
- (void)saveCurrentZonesButtons:(SHZone *)zone {
    
    // 更新缩放比例
    [self updateZone:zone];
    
    // 更新所有的按钮
    for (SHButton *button in zone.allDeviceButtonInCurrentZone) {
        
        // 由于按钮已经保存过，此时就更新一下就可以了
        NSString * sql = [NSString stringWithFormat:@"UPDATE DeviceButtonForZone SET subnetID = %d, deviceID = %d, buttonRectSaved = '%@', buttonPara1 = %d, buttonPara2 = %d, buttonPara3 = %d, buttonPara4 = %d, buttonPara5 = %d, buttonPara6 = %d WHERE zoneID = %lu AND buttonID = %lu ;", button.subNetID, button.deviceID, NSStringFromCGRect(button.frame), button.buttonPara1, button.buttonPara2, button.buttonPara3, button.buttonPara4, button.buttonPara5, button.buttonPara6,  (unsigned long)button.zoneID, (unsigned long)button.buttonID];
        
        // 执行SQL
        [self insetData:sql];

    }
}

/// 搜索所有的区域
- (NSMutableArray *)searchAllZones {
    
    // 获得字典数组
    NSArray *resultZones = [self selectProprty:@"select zoneID, zoneName, imageScale from zones order by zoneID;"];
    
    // 将字典数组转换成模型
    NSMutableArray *allZones = [NSMutableArray arrayWithCapacity:resultZones.count];
    for (NSDictionary *dict in resultZones) {
        
        [allZones addObject: [SHZone zoneWithDictionary:dict]];
    }
    
    return allZones;
}

#pragma mark - 插入语句

/// 插入语句
- (BOOL)insetData:(NSString *)sql {
    
    __block BOOL res = YES;
    
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        if (![db executeUpdate:sql]) {
            res = NO;
        }
    }];
    
    return res;
}

#pragma mark - 查询语句

/// 查询语句
- (NSMutableArray *)selectProprty:(NSString *)sql  {
    
    // 准备一个数组来存储所有内容
    __block NSMutableArray *array = [NSMutableArray array];
    
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        // 获得全部的记录
        FMResultSet *resultSet = [db executeQuery:sql];
        
        // 遍历结果
        while (resultSet.next) {
            
            // 准备一个字典
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            
            // 获得列数
            int count = [resultSet columnCount];
            
            // 遍历所有的记录
            for (int i = 0; i < count; i++) {
                
                // 获得字段名称
                NSString *name = [resultSet columnNameForIndex:i];
                
                // 获得字段值
                NSString *value = [resultSet objectForColumnName:name];
                
                // 存储在字典中
                dict[name] =  value;
            }
            
            // 添加到数组
            [array addObject:dict];
        }
    }];
    
    return array;
}

#pragma mark - 创建相关的表格

/// 创建当前区域的设备按钮表格
- (void)crateDeviceButtonForZones {
    
    /*
     'zoneID' 			区域ID
     'buttonID' 		按钮ID
     'subnetID' 	按钮子网ID
     'deviceID' 	按钮设备ID
     'deviceType'   按钮的类型
     'buttonRectSaved' 	按钮的位置
     'buttonPara1' 	 	不同设备的参数1
     'buttonPara2' 	 	不同设备的参数2
     'buttonPara3'      不同设备的参数3
     'buttonPara4' 	 	不同设备的参数4
     'buttonPara5' 	 	不同设备的参数5
     'buttonPara6'      不同设备的参数6
     */
    NSString *buttonSql = @"CREATE TABLE IF NOT EXISTS 'DeviceButtonForZone' (\
    'zoneID' INTEGER NOT NULL DEFAULT (0),\
    'buttonID' INTEGER PRIMARY KEY NOT NULL DEFAULT (1),\
    'subnetID' INTEGER NOT NULL DEFAULT (1),\
    'deviceID' INTEGER NOT NULL DEFAULT (0),\
    'deviceType' INTEGER NOT NULL DEFAULT (0), \
    'buttonRectSaved' TEXT,\
    'buttonPara1' INTEGER NOT NULL DEFAULT (0),\
    'buttonPara2' INTEGER NOT NULL DEFAULT (0),\
    'buttonPara3' INTEGER NOT NULL DEFAULT (0),\
    'buttonPara4' INTEGER NOT NULL DEFAULT (0),\
    'buttonPara5' INTEGER NOT NULL DEFAULT (0),\
    'buttonPara6' INTEGER NOT NULL DEFAULT (0)\
    );";
    
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        if ([db executeStatements:buttonSql]) {
            SHLog(@"设备按钮表格创建成功");
        }
    }];
}

/// 创建区域表格
- (void)createZones {
    
    /*
     注意：区域模型有2个属性，存前5个就可以了，因为图片我们单独存在一个文件夹，不放在数据库.
     字段对应属性 -- SHZone的五个属性
     zoneID          区域ID
     zoneName        区域名称
     */
    
    // 创建区域表格
    NSString *zoneSql = @"CREATE TABLE IF NOT EXISTS 'zones' (\
    'zoneID' INTEGER PRIMARY KEY NOT NULL ,\
    'zoneName' TEXT, \
    'imageScale' REAL\
    );";
    
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        if ([db executeStatements:zoneSql]) {
            SHLog(@"创建区域成功");
        }
    }];
}

///  创建表格
- (void)createSqlTables {
    
    // 创建区域表格
    [self createZones];
    
    // 创建设备按钮
    [self crateDeviceButtonForZones];
}

/// 创建数据库
- (instancetype)init {
    if (self = [super init]) {
        
        // 数据库路径
        NSString *filePath = [[FileTools documentPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", [FileTools appName]]];
        
        // 如果数据库不存在，会建立数据库，然后，再创建队列，并且打开数据库
        // 如果数据库存在，会直接创建队列且打开数据库
        self.queue = [FMDatabaseQueue databaseQueueWithPath:filePath];
        
        // 创建表格
        [self createSqlTables];
    }
    return self;
}

#pragma mark - 单例

SingletonImplementation(SHSQLiteManager)

@end
