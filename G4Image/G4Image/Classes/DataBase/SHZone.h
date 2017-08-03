//
//  SSModel.h
//  G4Image
//
//  Created by Firas on 3/3/14.
//  Copyright (c) 2014 SH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHZone : NSObject


/// 区域ID
@property (assign,nonatomic)NSUInteger zoneID;

/// 区域名称
@property (copy, nonatomic) NSString *zoneName;

/// 图片缩放比例
@property (nonatomic, assign) CGFloat imageScale;


/// 字典转换为模型
+ (instancetype)zoneWithDictionary:(NSDictionary *)dictionary;


/// 当前所有的设备按钮
@property (nonatomic, strong) NSMutableArray *allDeviceButtonInCurrentZone;

@end
