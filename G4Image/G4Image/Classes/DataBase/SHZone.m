//
//  SSModel.m
//  G4Image
//
//  Created by Firas on 3/3/14.
//  Copyright (c) 2014 SH. All rights reserved.
//

#import "SHZone.h"

@implementation SHZone


/// 保证外界访问时有值
- (NSMutableArray *)allDeviceButtonInCurrentZone {

    if (!_allDeviceButtonInCurrentZone) {
        _allDeviceButtonInCurrentZone = [NSMutableArray array];
    }
    return _allDeviceButtonInCurrentZone;
}


/**
 字典转换为模型
 */
+ (instancetype)zoneWithDictionary:(NSDictionary *)dictionary {
    
    id obj = [[self alloc] init];
    
    [obj setValuesForKeysWithDictionary:dictionary];
    
    return obj;
}
@end
