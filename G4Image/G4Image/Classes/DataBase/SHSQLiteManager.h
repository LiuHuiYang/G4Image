//
//  SHSQLiteManager.h
//  G4Image
//
//  Created by LHY on 2017/4/11.
//  Copyright © 2017年 SmartHomeGroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"

@interface SHSQLiteManager : NSObject

#pragma mark - 设备按钮列表

/// 删除已经存在按钮
- (void)deleteButton:(SHDeviceButton *)button;

/// 将新创建的按钮保存在数据库中
- (void)inserNewButton:(SHDeviceButton *)button;

/// 获得最大的按钮ID
- (NSUInteger)getMaxButtonID;


/// 获得当前区域的所有按钮
- (NSMutableArray *)getAllButtonsForCurrentZone:(SHZone *)zone;

#pragma mark - 区域表

/// 保存一个新的区域
- (BOOL)inserNewZone:(SHZone *)zone;

/// 获得最大的区域ID
- (NSUInteger)getMaxZoneID;

/// 搜索所有的区域
- (NSMutableArray *)searchAllZones;

/// 删除当前区域
- (void)deleteCurrntZone:(SHZone *)zone;

/// 存储当前的区域
- (void)saveCurrentZonesButtons:(SHZone *)zone;

SingletonInterface(SHSQLiteManager)

@end
